# CI’da kullanılan repolar – Build and push prebuilt image

## Özet

| Bileşen | Repo | Branch | Bizim mi? | Nerede ayarlı |
|--------|------|--------|-----------|----------------|
| **Frontend (web)** | `rifatsekerariot/beaver-iot-web` | `main` | ✅ Evet | Workflow Clone step env, `ci-clone-web.sh` |
| **API** | `Milesight-IoT/beaver-iot` | `origin/release` | ❌ Hayır (upstream) | `create-build-env.sh` → `.env` |
| **Integrations (JAR)** | `rifatsekerariot/beaver-iot-integrations` | `main` | ✅ Evet | `ci-build-jar.sh` (sabit) |
| **Docker / Compose** | `rifatsekerariot/beaver-iot-docker` | `main` | ✅ Evet | `actions/checkout` |

## Frontend (widget’lar) nereden geliyor?

1. **Clone:** Workflow → `WEB_GIT_REPO_URL=https://github.com/rifatsekerariot/beaver-iot-web.git`, `CI_CLONE_WEB_DEST=beaver-iot-web` → `ci-clone-web.sh` **workspace root**’a `beaver-iot-web/` clone ediyor.
2. **Build:** `build-prebuilt.sh` → `docker build -f beaver-iot-web-local.dockerfile` context = workspace root, **COPY beaver-iot-web/**.
3. **Dockerfile:** `beaver-iot-web-local.dockerfile` sadece **COPY** kullanıyor, **git clone yok**. Kaynak = clone edilmiş `beaver-iot-web/`.

**Önemli:** Compose’taki **web** servisi (`beaver-iot-web.dockerfile`, container içinde clone) **kullanılmıyor**. Web sadece **local** dockerfile + **bizim** clone ile build ediliyor.

## API nereden geliyor?

- `create-build-env.sh` → `.env`: `API_GIT_REPO_URL=https://github.com/Milesight-IoT/beaver-iot.git`, `API_GIT_BRANCH=origin/release`.
- Compose **api** servisi `beaver-iot-api.dockerfile` ile build ediliyor; Dockerfile içinde **git clone** bu URL ile yapılıyor.
- Yani API = **Milesight** (upstream). Widget’lar frontend’de olduğu için bu değişmez.

## Olası karışıklık noktaları

1. **Compose `web` servisi:** `docker-compose.yaml` içinde `web` için `beaver-iot-web.dockerfile` (clone) ve `WEB_GIT_REPO_URL` / `WEB_GIT_BRANCH` var. CI **web’i compose ile build etmiyor**; sadece **api** ve **monolith** compose ile build ediliyor. Web **build-prebuilt** içinde **standalone** `docker build` ile **local** dockerfile’dan üretiliyor.
2. **`.env` WEB_*:** `create-build-env` WEB’i de yazıyor; bunlar compose **web** build’i için. O build **çalıştırılmadığı** için frontend kaynağını etkilemiyor.
3. **Cache:** Web build’te `--no-cache` yoksa eski katmanlar kullanılabilir. CI runner’lar her seferinde sıfır olsa da, web build’e `--no-cache` eklemek daha net.

## Sonuç

- **Frontend:** Kesinlikle **rifatsekerariot/beaver-iot-web** (main), **beaver-iot-web-local.dockerfile** + **COPY**.
- **API:** Milesight upstream.
- **JAR:** Bizim integrations repo.

Eğer widget’lar hâlâ yoksa, olası nedenler:
- `rifatsekerariot/beaver-iot-web` **main**’de **components.ts** / **useFilterPlugins** düzeltmeleri yok veya geri alınmış.
- Clone başarısız / yanlış branch (örn. `main` değil).
- Web build’te hata var ama CI’da yakalanmıyor.

Bu yüzden CI’a **web kaynağı doğrulama** adımı (clone sonrası, build öncesi) eklendi:

- **verify-web-source.sh:** Clone’un **rifatsekerariot/beaver-iot-web** olduğunu, **components.ts** (control-panel glob) ve **useFilterPlugins** (return pluginsControlPanel) düzeltmelerinin varlığını kontrol eder. Eksikse CI fail eder.
- **Web build:** `--no-cache` eklendi; eski katman kullanımı engellendi.
