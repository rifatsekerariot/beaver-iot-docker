# ChirpStack HTTP – Veri Gelmiyor: Düzeltme Özeti

## Sorun

ChirpStack HTTP integration tarafında **veriler gelmiyor**. Son yapılan değişiklikler (verify-web-image, workflow) **backend/webhook koduna dokunmuyor**; build de doğru (JAR imaja gömülü).

## Kök neden

**`CHIRPSTACK_DEFAULT_TENANT_ID` boştu.** Webhook controller tenant olmadan isteği reddediyor (`400 "tenant not configured"`). ChirpStack uplink gönderiyor ama Beaver 400 dönüyor → veri kaydedilmiyor.

- Zero-touch **`--tenant-id` verilmeden** çalıştırılırsa `TENANT_ID` boş kalıyordu.
- Compose env: `CHIRPSTACK_DEFAULT_TENANT_ID=${CHIRPSTACK_DEFAULT_TENANT_ID:-}` → container’a boş geçiyordu.

## Yapılan düzeltmeler

1. **`scripts/deploy-zero-touch.sh`**
   - `export CHIRPSTACK_DEFAULT_TENANT_ID="${TENANT_ID:-default}"` → `--tenant-id` yoksa **`default`** kullanılıyor.
   - Log: `Tenant ID: default (use --tenant-id to override)`.

2. **`examples/chirpstack-prebuilt.yaml`**
   - `CHIRPSTACK_DEFAULT_TENANT_ID=${CHIRPSTACK_DEFAULT_TENANT_ID:-default}` → compose env yoksa **`default`**.

3. **`examples/chirpstack.yaml`**
   - Aynı `:-default` eklendi ( volume’lu kurulum için ).

## Sonrasında yapmanız gerekenler

1. **Yeniden deploy**
   - Zero-touch:  
     `curl -sSL .../deploy-zero-touch.sh | sudo sh -s --`  
     (veya `--tenant-id <id>` ile kendi tenant’ınız).
   - Manuel compose: `CHIRPSTACK_DEFAULT_TENANT_ID=default` (veya kendi tenant) geçtiğinizden emin olun.

2. **Cihazı Beaver’da tanımlayın**
   - ChirpStack integration → Add device; **identifier = devEui** (ChirpStack’tekiyle aynı).
   - Webhook sadece **mevcut cihazlar** için uplink işliyor.

3. **ChirpStack HTTP Integration**
   - Event URL: `http://<host>:9080/public/integration/chirpstack/webhook` (veya host:port sizin kuruluma göre).
   - İsteğe bağlı: `X-Tenant-Id` header ile tenant override.

## Doğrulama

```bash
# Webhook'a test (tenant default, event=up)
curl -s -w "\nHTTP %{http_code}" -X POST "http://localhost:9080/public/integration/chirpstack/webhook?event=up" \
  -H "Content-Type: application/json" \
  -d '{"deviceInfo":{"devEui":"0102030405060708"},"fPort":1}'
# 200 + "ok" beklenir (cihaz yoksa veri kaydedilmez ama tenant hatası olmaz).
```

Özet: **Kod/build değişmedi**; eksik olan tenant varsayılanıydı. Varsayılan `default` yapıldı; yeniden deploy + cihaz ekleme sonrası veri akışı düzelir.
