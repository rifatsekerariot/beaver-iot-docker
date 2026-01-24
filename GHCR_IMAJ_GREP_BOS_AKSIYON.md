# GHCR imajında Alarm/Map yok (sunucuda grep boş) – aksiyon planı

## Durum

Sunucuda:
```bash
docker run --rm --entrypoint sh ghcr.io/rifatsekerariot/beaver-iot:latest -c "ls /web/assets/js | grep -E '^Alarm-|^Map-'"
```
**Boş** dönüyor → GHCR’daki imaj **Alarm/Map** widget chunk’larını **içermiyor**.

## Kök neden

**Workflow hiç yeşil bitmemiş** (veya yanlış build) → **yeni** imaj **push edilmemiş** → sunucu **eski** GHCR imajını çekiyor.

- **Verify web image** adımı Alarm/Map chunk’larını kontrol ediyor; **eksikse** CI **fail** ediyor, **push** yapılmıyor.
- Yani **başarılı** push = imajda Alarm/Map **var** demek. **Grep boş** = **hiç** başarılı push **olmamış** (veya çok eski bir push kullanılıyor).

## Yapılacaklar

1. **Workflow’u manuel çalıştır**
   - **beaver-iot-docker** → **Actions** → **Build and push prebuilt image** → **Run workflow** (Run workflow dropdown).

2. **Tüm adımların yeşil geçmesini sağla**
   - **Verify web source** fail → **beaver-iot-web** main’de `components.ts` + `useFilterPlugins` fix’lerini kontrol et.
   - **Build web + api + monolith** fail → Actions log’una bak; JAR, compose, Docker build hatalarını gider.
   - **Log web image widget chunks** → `/web/assets/js` listesi ve Alarm/Map satırları log’da görünür. Alarm/Map yoksa **Verify web image** fail eder.
   - **Verify web image** fail → Web build Alarm/Map üretmemiş; yukarıdaki adımları ve **beaver-iot-web** kaynağını tekrar kontrol et.

3. **Workflow yeşil olduktan sonra sunucuda zero-touch’u tekrar çalıştır**
   ```bash
   curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default"
   ```
   Script **pull** + **up** yapar; **yeni** GHCR imajı çekilir.

4. **Doğrulama**
   ```bash
   docker run --rm --entrypoint sh ghcr.io/rifatsekerariot/beaver-iot:latest -c "ls /web/assets/js | grep -E '^Alarm-|^Map-'"
   ```
   **Alarm-*.js** ve **Map-*.js** çıkmalı.

## Workflow’a eklenen teşhis adımı

**Log web image widget chunks (diagnostic):**
- `/web/assets/js` içindeki ilk 60 dosyayı ve **Alarm-** / **Map-** ile başlayanları log’a yazar.
- **Verify web image** fail ederse, bu log’dan web imajında **ne** olduğu görülür.

Bu adım **Verify web image**’dan hemen önce çalışır.
