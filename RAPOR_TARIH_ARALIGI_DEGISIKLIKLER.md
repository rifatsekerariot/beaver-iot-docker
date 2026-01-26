# Rapor Tarih Aralığı – Yapılan Değişiklikler

## Amaç

Rapor oluştururken seçilen **tarih aralığı**ndaki değerlerin (MIN/MAX/AVG/LAST) kullanılması. "En son değer" yerine aralığa ait agregaların getirilmesi ve buna yönelik kontrollerin eklenmesi.

---

## Yapılan Değişiklikler

### 1. Test prosedürü

- **`TEST_PLAN_REPORT_DATE_RANGE.md`** eklendi.
- Manuel UI testleri (tarih zorunluluğu, geçersiz aralık, geçerli aralık, konsol logları).
- API seviyesi testleri (`entity/history/aggregate` 200, tarih aralığı ile aggregate).
- Başarı kriterleri tanımlandı.

### 2. Rapor sayfası (beaver-iot-web)

- **Tarih aralığı validasyonu:**
  - `end <= start` ise hata: **"End date must be after start date"** (locale: `report.message.invalid_date_range`).
  - Toast gösterilir, PDF oluşturulmaz.
- **End-of-day uzatması:**
  - Bitiş tarihi **00:00:00.000** ise, aynı gün **23:59:59.999** olacak şekilde uzatılır.
  - Böylece "son gün dahil" davranışı sağlanır.
- **API çağrıları:**
  - `getAggregateHistory` her zaman **`startMs`** ve **`endMs`** (ms) ile çağrılıyor.
  - Bu değerler PDF’teki "Date range" metninde de kullanılıyor.
- **Locale:** `report.message.invalid_date_range` (EN/CN) eklendi.

### 3. Test scripti (beaver-iot-docker)

- **Step 7:** Cihaz/entity varsa `POST /entity/history/aggregate` çağrısı.
  - `start_timestamp` / `end_timestamp`: 2 gün önce 00:00 – 1 gün önce 23:59:59.999 (ms).
  - `aggregate_type: "LAST"`.
  - 200 beklenir.

---

## Test Sonucu (Lokal Docker)

- `test-report-api.ps1` çalıştırıldı.
- Tüm 200 kontrolleri geçti (login, dashboard, device, entity advanced-search, main canvas, getDrawingBoardDetail).
- Step 7, entity olmadığı için atlandı; entity varken aggregate (tarih aralığı) 200 ile doğrulanacak.

---

## Kullanım

1. Report sayfasına git.
2. Dashboard seç, **tarih aralığı** seç (başlangıç < bitiş).
3. "Generate PDF" tıkla.
4. PDF’te **Date range** alanı seçilen aralığı gösterir; LAST/MIN/MAX/AVG bu aralığa göre istenir (backend doğru uyguladığı sürece).

---

## Özet

| Konu | Durum |
|------|--------|
| Tarih aralığı zorunlu | Var (mevcut) |
| Bitiş > başlangıç kontrolü | Eklendi |
| Bitiş 00:00 → 23:59:59.999 | Eklendi |
| API’ye start/end (ms) gönderimi | startMs / endMs kullanılıyor |
| Test prosedürü | TEST_PLAN_REPORT_DATE_RANGE.md |
| API testi (aggregate) | test-report-api.ps1 Step 7 |
