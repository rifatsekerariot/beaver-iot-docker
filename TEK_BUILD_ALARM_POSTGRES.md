# Tek Build: Alarm + ChirpStack + PostgreSQL

**Hedef:** `ghcr.io/rifatsekerariot/beaver-iot:latest` — indirip `chirpstack-prebuilt-postgres.yaml` ile çalıştırdığınızda **Alarm backend**, **ChirpStack v4**, **PostgreSQL** (t_alarm dahil) ve **özel widget’lar** (Alarm, Report, Map, vb.) çalışır.

---

## 1. Yapılan Değişiklikler

### create-build-env.sh
- **API:** `rifatsekerariot/beaver-iot` (branch `origin/main`) — Alarm backend bu repoda olmalı.
- Override: `API_GIT_REPO_URL`, `API_GIT_BRANCH` env ile değiştirilebilir.

### build-push-prebuilt.yaml (tek workflow)
- Build: web (rifatsekerariot/beaver-iot-web) + **API (rifatsekerariot/beaver-iot, alarm-service)** + ChirpStack JAR + monolith.
- **PostgreSQL smoke test:** Build sonrası `chirpstack-prebuilt-postgres.yaml` ile `up -d` → 90 sn bekleme → `GET /` 200/302 → `down -v`. Böylece aynı imajın PostgreSQL + t_alarm migration ile ayağa kalktığı doğrulanır.
- Push: `ghcr.io/rifatsekerariot/beaver-iot:latest`.

### push-alarm-to-beaver-iot-fork.ps1
- `beaver-iot-main` içindeki **alarm-service**, **t_alarm (v1.4.0)**, **changelog** ve **pom** güncellemelerini `rifatsekerariot/beaver-iot` fork’una uygular.  
- **Kullanım:** Önce bu script’i çalıştırın, ardından fork’ta `git push origin main`.

---

## 2. Alarm’ı rifatsekerariot/beaver-iot’a Ekleme (İlk Kez)

`rifatsekerariot/beaver-iot` fork’unda `services/alarm` yoksa bu adımlar gerekir:

```powershell
# beaver-iot-docker klasöründe
.\scripts\push-alarm-to-beaver-iot-fork.ps1 -BeaverIotMain "c:\Projeler\beaver-iot-main"

# Script clone/commit yapar. Push sizin:
cd $env:TEMP\beaver-iot-fork   # veya -ForkPath ile verdiğiniz klasör
git push origin main
```

Veya fork’u kendiniz klonlayıp `-ForkPath` ile verin:

```powershell
.\scripts\push-alarm-to-beaver-iot-fork.ps1 -BeaverIotMain "c:\Projeler\beaver-iot-main" -ForkPath "c:\Projeler\beaver-iot"
cd c:\Projeler\beaver-iot
git push origin main
```

---

## 3. CI ile Tek Build

1. **beaver-iot-docker**’da Actions’ı etkinleştirin (fork ise: Settings → Actions → Allow).
2. **Build tetikleme:**
   - **Actions** → **Build and push prebuilt image** → **Run workflow**, veya
   - `main`’e `build-docker/**`, `scripts/**`, `examples/**` veya bu workflow dosyasında değişiklik push’u.

3. Workflow sırası:
   - Checkout, restructure, ChirpStack JAR build
   - **create-build-env** → API = `rifatsekerariot/beaver-iot` `origin/main`
   - beaver-iot-web clone, web + **api (alarm dahil)** + monolith build
   - Verify web, **PostgreSQL smoke test** (compose up → HTTP 200/302 → down)
   - Tag + GHCR push → `ghcr.io/rifatsekerariot/beaver-iot:latest`

---

## 4. İndirip Çalıştırma (PostgreSQL)

```bash
# Örnek: beaver-iot-docker/examples
export BEAVER_IMAGE=ghcr.io/rifatsekerariot/beaver-iot:latest
docker compose -f chirpstack-prebuilt-postgres.yaml up -d
# UI: http://localhost:9080
# PostgreSQL: t_alarm, scheduler, diğer tablolar. DB_TYPE=postgres, SPRING_DATASOURCE_* compose’ta.
```

Zero-touch (Linux):

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --postgres
```

---

## 5. Özet: Tek İmajda Neler Var?

| Bileşen | Kaynak |
|---------|--------|
| **Alarm backend** (/alarms/search, export, claim; t_alarm) | rifatsekerariot/beaver-iot (main) |
| **ChirpStack v4** (JAR) | rifatsekerariot/beaver-iot-integrations (main) |
| **Web** (Alarm sayfası, widget, Report, özel widget’lar, ARIOT, BackendReadyCheck) | rifatsekerariot/beaver-iot-web (main) |
| **PostgreSQL** | Aynı imaj; `chirpstack-prebuilt-postgres.yaml` ile DB_TYPE=postgres, harici postgres container. t_alarm migration v1.4.0 uygulanır. |

---

## 6. Sorun Giderme

- **API build hatası (alarm-service bulunamadı):** `rifatsekerariot/beaver-iot` içinde `services/alarm` ve `application-standard`’da `alarm-service` dependency olmalı. `push-alarm-to-beaver-iot-fork.ps1` ile ekleyip push edin.
- **PostgreSQL smoke test fail:** Monolith log’una bakın (`docker compose logs monolith`). `t_alarm` veya changelog v1.4.0 eksikse fork’a alarm + changelog v1.4.0 ekleyin.
- **H2 kullanmak isterseniz:** `chirpstack-prebuilt.yaml` (PostgreSQL’siz) ile aynı imajı kullanın; `DB_TYPE`/`SPRING_DATASOURCE_*` verilmezse H2 kullanılır.
