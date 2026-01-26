# Report Page – E2E Test ve 200 Doğrulama

## Özet

- **Docker:** `chirpstack-prebuilt` ile Beaver IoT ayağa kalkar.
- **API testi:** `scripts/test-report-api.ps1` ile register/login, dashboard, device, **entity advanced-search (DEVICE_ID EQ)**, main canvas, **getDrawingBoardDetail** hepsi **200** doğrulanır.
- **Rapor:** Report sayfası dashboard seçimi → tarih aralığı → Generate PDF akışı için kullanılır.

## 1. Docker ile Çalıştırma

```powershell
cd c:\Projeler\beaver-iot-docker
docker compose -f examples/chirpstack-prebuilt.yaml up -d
```

~45 saniye bekleyin (backend Liquibase + Spring boot).

## 2. 200 Doğrulama Script’i

```powershell
.\scripts\test-report-api.ps1 -BaseUrl "http://localhost:9080"
```

**İlk çalıştırma (temiz DB):** Register 200 → Login 200.  
**Sonraki çalıştırmalar:** Register 500 (tenant_user_inited) → Login 200.

Script şunları kontrol eder:

- Register (veya 500 devam)
- Login → token
- Dashboard search → 200
- Device search → 200
- Cihaz yoksa ChirpStack test cihazı ekleme denemesi; yine yoksa **entity advanced-search (DEVICE_ID EQ)** “probe” ile 200 doğrulaması
- Main canvas → 200
- **getDrawingBoardDetail** (GET /api/v1/canvas/:id) → 200

**Entity advanced-search:** Device Entity Data ile aynı format: `DEVICE_ID: { operator: "EQ", values: [deviceId] }`, `ENTITY_TYPE: "PROPERTY"`. **ANY_EQUALS** + çoklu device 400 verdiği için rapor tarafı **cihaz başına EQ** kullanıyor.

## 3. Rapor UI Testi (Manuel)

1. **http://localhost:9080** → Login (örn. `report-test@test.local` / `Test1234!`).
2. **Report** menüsüne gir.
3. Dashboard seç → Tarih aralığı → **Generate PDF**.

Cihaz yoksa “No devices available” alınır; bu durumda:

- **Device → Add → ChirpStack HTTP** ile cihaz ekleyin (örn. DevEUI `0102030405060708`, sensor model `em500-udl`).
4. Rapor sayfasında tekrar deneyin.

## 4. Temiz DB ile Yeniden Test

```powershell
docker compose -f examples/chirpstack-prebuilt.yaml down -v
docker compose -f examples/chirpstack-prebuilt.yaml up -d
# ~45 sn bekle
.\scripts\test-report-api.ps1 -BaseUrl "http://localhost:9080"
```

## 5. Doğrulanan Noktalar

- `POST /api/v1/oauth2/token` (login) → 200  
- `POST /api/v1/dashboard/search` → 200  
- `POST /api/v1/device/search` → 200  
- `POST /api/v1/entity/advanced-search` (**DEVICE_ID EQ**, ENTITY_TYPE PROPERTY) → **200** (içerik boş olabilir)  
- `GET /api/v1/dashboard/main-canvas` → 200  
- `GET /api/v1/canvas/:id` (getDrawingBoardDetail) → 200  

Rapor sayfası bu endpoint’leri kullanır; 400/500 almadan çalışması beklenir.
