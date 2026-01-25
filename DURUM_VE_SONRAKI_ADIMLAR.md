# ChirpStack + Beaver Docker – Güncel Durum ve Sonraki Adımlar

## ✅ Tamamlananlar

1. **ChirpStack integration JAR**  
   - `c:\Projeler\beaver\integrations\chirpstack-integration\target\chirpstack-integration-1.3.0-SNAPSHOT.jar`  
   - Build: `mvn package -DskipTests -pl integrations/chirpstack-integration -am` (Docker Maven ile yapıldı).

2. **JAR Docker volume’a kopyalandı**  
   - `c:\Projeler\beaver-iot-docker\examples\target\chirpstack\integrations\chirpstack-integration-1.3.0-SNAPSHOT.jar`

3. **Beaver API Docker build**  
   - Arka planda çalışıyor: `build-docker` içinde `docker compose build --no-cache api`  
   - Log: `beaver-iot-docker\api-build.log`

## ⏳ Build tamamlanınca yapılacaklar

### 1. Build’in bittiğini kontrol et

```powershell
docker images milesight/beaver-iot-api
# milesight/beaver-iot-api   latest   ...   görünmeli
```

Build hâlâ sürüyorsa `api-build.log` veya terminal çıktısına bakın.

### 2. Web ve Monolith image’larını build et

```powershell
cd c:\Projeler\beaver-iot-docker\build-docker
docker compose build --no-cache web
docker compose build --no-cache monolith
```

### 3. ChirpStack compose’u çalıştır

```powershell
cd c:\Projeler\beaver-iot-docker\examples
docker compose -f chirpstack.yaml up -d
docker compose -f chirpstack.yaml logs -f
```

`ChirpStack HTTP integration started` log’unu görünce `Ctrl+C` ile log takibinden çıkın.

### 4. Webhook testleri

```powershell
cd c:\Projeler\beaver-iot-docker\scripts
.\test-webhook.ps1 -BaseUrl "http://localhost:8080" -TenantId "default"
```

### 5. Log inceleme

```powershell
docker compose -f chirpstack.yaml logs monolith
```

---

## Hızlı özet

| Adım | Durum | Komut / not |
|------|--------|-------------|
| ChirpStack JAR build | ✅ | `beaver` projesinde Maven/Docker Maven |
| JAR → `target/chirpstack/integrations/` | ✅ | Kopyalandı |
| Beaver API image build | 🔄 Arka planda | `build-docker` + `docker compose build api` |
| Web + Monolith build | ⏳ | API bitince sırayla |
| `chirpstack.yaml` up | ⏳ | `examples` içinde |
| Webhook test | ⏳ | `test-webhook.ps1` |

---

## Alternatif: Hazır Beaver image

`milesight/beaver-iot:latest` Docker Hub’da varsa:

```powershell
docker pull milesight/beaver-iot:latest
```

Sonra doğrudan `examples` içinde `docker compose -f chirpstack.yaml up -d` çalıştırılabilir (Web/Monolith build gerekmez; tek image kullanılır).
