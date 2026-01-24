# job-logs.txt analizi – GHCR imajında Alarm/Map yok

## Kaynak

`job-logs.txt`: GitHub Actions **Build and push prebuilt image** workflow’unun son build logları.

## Özet

- Workflow **yeşil** bitti, imaj **push** edildi.
- Verify web source **geçti** (bizim repo, components.ts + useFilterPlugins fix’leri var).
- Verify web image **geçti** (milesight/beaver-iot-web:latest’te Alarm/Map chunk’ları var).
- Buna rağmen sunucuda `docker run ... grep -E '^Alarm-|^Map-'` **boş** → push edilen **monolith** imajında Alarm/Map **yok**.

## Kök neden

1. **Web** build: `docker build` → **docker driver** (host daemon). İmaj `milesight/beaver-iot-web:latest` host’ta; Alarm/Map **var**.
2. **Api + monolith** build: `docker compose build` → **buildx** (docker-container builder). Buildx, host daemon’dan **bağımsız** çalışıyor.
3. Monolith Dockerfile: `FROM ${BASE_WEB_IMAGE}` → `milesight/beaver-iot-web:latest`. Buildx bu referansı **kendi** ortamında çözer; host’taki imajı **görmez**. Bu yüzden **Docker Hub**’daki **upstream** `milesight/beaver-iot-web:latest` çekiliyor (bizim fix’ler **yok**).
4. **Verify web image**: Host’taki **bizim** web imajını kontrol ediyor → Alarm/Map var → **geçiyor**.
5. **Tag-push**: Buildx ile üretilen **monolith** (içinde **upstream** web) push ediliyor → GHCR’daki monolith’ta Alarm/Map **yok**.

Özet: **Verify** bizim web’e bakıyor, **push** edilen monolith ise **upstream** web ile build ediliyor.

## Çözüm (uygulandı)

1. Web build sonrası **bizim** web imajını **GHCR**’a push et:  
   `ghcr.io/rifatsekerariot/beaver-iot-web:latest`
2. Compose ile monolith build’den **önce** `BASE_WEB_IMAGE=ghcr.io/rifatsekerariot/beaver-iot-web:latest` olacak şekilde **.env**’e yaz (compose’ta `BASE_WEB_IMAGE` opsiyonel yapıldı).
3. Monolith build artık **FROM** için GHCR’daki **bizim** web imajını çeker → Alarm/Map monolith’a girer.
4. **build-prebuilt.sh** buna göre güncellendi: web build → web’i GHCR’a push → `.env`’e `BASE_WEB_IMAGE` ekle → compose build api monolith.

## Log referansları

- Web build: `#0 building with "default" instance using docker driver`
- Buildx: `docker buildx create ... docker-container ... --use`
- Api/monolith: compose build (buildx kullanır)
- Verify + tag-push: geçti; push `latest: digest: sha256:aff65433...`

## Doğrulama

Yeni workflow çalıştıktan sonra sunucuda:

```bash
docker run --rm --entrypoint sh ghcr.io/rifatsekerariot/beaver-iot:latest -c "ls /web/assets/js | grep -E '^Alarm-|^Map-'"
```

**Alarm-*.js** ve **Map-*.js** satırları çıkmalı.
