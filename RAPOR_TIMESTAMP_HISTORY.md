# Rapor: Timestamp’li Telemetri Listesi

## Yapılanlar

1. **getHistory kullanımı**  
   Her entity için `entityAPI.getHistory` (start/end ms, sayfalanmış) çağrılıyor. Tarih aralığındaki tüm kayıtlar alınıyor (sayfa başına 500, en fazla 20 sayfa).

2. **Özet + zaman listesi**  
   - **Özet tablo:** Entity | Unit | Last | Min | Max | Avg (Last/Min/Max/Avg, history’den hesaplanıyor).  
   - **Her entity için:** "Entity (unit) – N" başlığı altında **Timestamp | Value** tablosu. Böylece hangi anda hangi değerin olduğu görülebiliyor.

3. **Widget taraması**  
   `config` alanı da taranıyor; dashboard’da seçili entity’lerin tamamına yakınının raporda yer alması hedefleniyor.

4. **Locale**  
   `report.table.timestamp`, `report.table.value`, `report.table.records` eklendi.

## Sonuç

- Raporda her entity için hem özet (Last/Min/Max/Avg) hem de **tarih aralığındaki tüm telemetri noktaları** (timestamp + value) listeleniyor.  
- Kullanıcı hem “o cihazda başka veri var mı?” sorusunu hem de “hangi anın verisi?” sorusunu yanıtlayabiliyor.
