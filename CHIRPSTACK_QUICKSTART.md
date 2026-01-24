# ChirpStack v4 + Beaver IoT – Hızlı Başlangıç

**Önce Docker Desktop’ı başlatın.**

## 1. Build ve çalıştırma

```powershell
# 1) Integrations build (Maven gerekir; yoksa Docker ile)
cd c:\Projeler\beaver
mvn clean package -DskipTests -pl integrations/chirpstack-integration -am

# 2) JAR'ı docker hedefine kopyala
mkdir -p c:\Projeler\beaver-iot-docker\examples\target\chirpstack\integrations
Copy-Item "c:\Projeler\beaver\integrations\chirpstack-integration\target\chirpstack-integration-*.jar" "c:\Projeler\beaver-iot-docker\examples\target\chirpstack\integrations\" -Exclude "*original*"

# 3) Beaver Docker image'ları (ilk seferde)
cd c:\Projeler\beaver-iot-docker\build-docker
Copy-Item .env.example .env   # gerekirse düzenle
docker compose build --no-cache api web monolith

# 4) ChirpStack örnek compose
cd c:\Projeler\beaver-iot-docker\examples
docker compose -f chirpstack.yaml up -d
docker compose -f chirpstack.yaml logs -f
```

## 2. Webhook testi

```powershell
cd c:\Projeler\beaver-iot-docker\scripts
.\test-webhook.ps1 -BaseUrl "http://localhost:9080" -TenantId "default"
```

## 3. Zero touch (Linux sunucuda tek komut)

**Sadece Linux.** Tek komutla kurulum:

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default"
```

Ayrıntılar: **[ZERO_TOUCH_DEPLOY.md](ZERO_TOUCH_DEPLOY.md)**.

## 4. Log kontrolü

```powershell
docker compose -f chirpstack.yaml logs monolith
```

`ChirpStack HTTP integration started`, `ChirpStack uplink` vb. arayın.

---

Detaylı adımlar: **beaver** projesinde `RUNBOOK_CHIRPSTACK_DOCKER.md` ve `TEST_PLAN_CHIRPSTACK.md`.  
**Zero touch:** `ZERO_TOUCH_DEPLOY.md`.
