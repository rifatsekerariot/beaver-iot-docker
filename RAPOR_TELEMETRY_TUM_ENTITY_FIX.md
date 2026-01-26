# Rapor: Tüm Telemetri Görünsün (entityIdSet Filtresi Kaldırıldı)

## Sorun

Raporda **"sadece 1 telemetry verisi görünüyor"** – dashboard’daki cihazların diğer entity’leri (örn. Humidity, Temperature) listelenmiyordu.

## Neden

- Entity’ler `entityAPI.advancedSearch` (DEVICE_ID EQ, PROPERTY) ile alınıyordu.
- `entityIdSet` canvas `entity_ids` + **widget taraması**ndan (gauge, vb.) oluşturuluyordu.
- **entityIdSet.size > 0** iken `allRaw` bu kümeye **filtreleniyordu**.
- Widget’lar genelde **tek** entity’ye bağlı (örn. bir gauge = sadece Temperature). Sonuç: rapor yalnızca widget’ta kullanılan entity’leri gösteriyor, cihazdaki diğer telemetriler (Humidity, vb.) **eleniyordu**.

## Çözüm

- **Database’den doğrudan okuma:** Frontend DB’ye erişmez; Entity API kullanılıyor. Veri kaynağı zaten entity tablolarına karşılık gelen API.
- **Yapılan değişiklik:** advancedSearch ile alınan entity’ler **artık entityIdSet ile filtrelenmiyor**. Rapor, **cihaz başına tüm PROPERTY entity’leri** kullanıyor (Entity Data sayfası gibi).
- **Mevcut kod korundu:** canvas.entities yolu, cihaz çözümlemesi, aggregate, PDF akışı aynı. Sadece “filter by entityIdSet” kaldırıldı; entity listesi **genişletildi**.

## Sonuç

- Dashboard’daki cihazların **tüm** telemetri entity’leri (Humidity, Temperature, vb.) rapora yansır.
- Widget’a bağlı olmayan entity’ler de rapor tablolarında yer alır.
