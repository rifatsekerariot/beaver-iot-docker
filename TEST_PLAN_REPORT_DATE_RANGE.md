# Test Plan: Rapor Tarih Aralığı (Date Range)

## Amaç

Rapor oluştururken seçilen **tarih aralığı**ndaki değerlerin (MIN/MAX/AVG/LAST) getirildiğini doğrulamak. "En son değer" yerine aralığa ait agregaların kullanıldığından emin olunacak.

---

## Ön koşullar

- Beaver IoT Docker çalışıyor (`http://localhost:9080` veya sunucu).
- En az bir dashboard, cihaz ve entity verisi var.
- Report sayfası açılabiliyor, dashboard seçilebiliyor.

---

## 1. Manuel UI testi

### 1.1 Tarih aralığı zorunluluğu

1. Report sayfasına git.
2. Sadece dashboard seç, **tarih aralığı seçme**.
3. "Generate PDF" tıkla.
4. **Beklenen:** "Please select a date range" benzeri hata; PDF oluşmaz.

### 1.2 Geçersiz aralık (bitiş ≤ başlangıç)

1. Dashboard seç.
2. **Start date:** 2025-01-10 12:00, **End date:** 2025-01-10 11:00 (bitiş < başlangıç).
3. "Generate PDF" tıkla.
4. **Beklenen:** Hata mesajı; PDF oluşmaz.

### 1.3 Geçerli aralık – değerler aralığa ait olmalı

1. Dashboard seç.
2. **Start date:** Bilinen veri olduğu bir gün/saat (örn. dün 00:00).
3. **End date:** Bugün 23:59 veya veri olan bir bitiş.
4. Rapor başlığı gir, "Generate PDF" tıkla.
5. **Beklenen:**
   - PDF indirilir.
   - PDF içinde **"Date range"** alanı seçilen aralığı gösterir (örn. "2025-01-09 – 2025-01-10").
   - Tabloda **Last / Min / Max / Avg** değerleri, **sadece o aralıktaki** telemetriye göre hesaplanmış olmalı (en son anlık değer değil).

### 1.4 Konsol doğrulaması

1. Tarayıcı DevTools → Console aç.
2. Geçerli aralıkla rapor oluştur.
3. **Beklenen loglar:**
   - `[ReportPage] [FORM] Date range - start: <ms> end: <ms>`
   - `[ReportPage] [API] Date range: start: <ms> end: <ms>`
   - `[ReportPage] [API] Calling getAggregateHistory: LAST|MIN|MAX|AVG entity_id: ...`
4. `start` / `end` değerlerinin seçilen tarihlere karşılık gelen ms cinsinden olduğunu kontrol et.

---

## 2. API seviyesi testi (PowerShell)

### 2.1 Entity history aggregate 200

`test-report-api.ps1` çalıştırıldığında (cihaz/entity varsa):

- `POST /api/v1/entity/history/aggregate` çağrısı yapılır.
- Body: `entity_id`, `start_timestamp`, `end_timestamp` (ms), `aggregate_type: "LAST"`.
- **Beklenen:** HTTP 200; JSON içinde `value` veya `data` alanı.

### 2.2 Tarih aralığı ile aggregate

- `start_timestamp`: 2 gün önce 00:00 (ms).
- `end_timestamp`: 1 gün önce 23:59:59.999 (ms).
- **Beklenen:** 200; dönen `value` bu aralıktaki verilere göre olmalı (doğrulama için entity history search ile karşılaştırılabilir).

---

## 3. Yapılan kontroller (kod)

- **Form:** `dateRange` zorunlu; `start` / `end` yoksa rapor oluşturulmaz.
- **Validasyon:** `end > start`; aksi halde hata gösterilir.
- **End-of-day:** Bitiş tarihi saat 00:00:00.000 ise, aynı gün 23:59:59.999’a uzatılır (seçilen gün dahil).
- **API:** `getAggregateHistory` her zaman `start_timestamp` ve `end_timestamp` (ms) ile çağrılır; bu aralık loglanır.

---

## 4. Başarı kriterleri

- Tarih aralığı seçilmeden rapor oluşturulamaz.
- Bitiş ≤ başlangıç olduğunda hata verilir.
- Geçerli aralıkla PDF oluşur; PDF’te tarih aralığı metni doğrudur.
- Agregalar (LAST/MIN/MAX/AVG) yalnızca bu aralığa göre istenir ve raporda kullanılır (backend doğru implemente ettiği sürece).
