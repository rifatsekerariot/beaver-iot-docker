# Rapor: Sadece Dashboard’da Seçili Telemetri (Aşı Dolabı Isı Takibi)

## Amaç

Rapor, **dashboard’da seçili** cihazların **sadece seçili** telemetri verilerini (örn. aşı dolabı ısı takibi) içermeli. Tüm entity’ler listelenmemeli; seçilen tarih aralığında, dashboard’da hangi telemetriler kullanılıyorsa yalnızca onlar raporlanmalı.

## Yapılanlar

- **entityIdSet filtresi geri getirildi:** advancedSearch ile alınan entity’ler, **entityIdSet.size > 0** iken **filtreleniyor**. entityIdSet = canvas `entity_ids` + widget taraması (gauge, industrial-gauges, air-quality, vb.).
- **Widget taraması güçlendirildi:** `entity`, `adc`, `adv`, `modbus`, `co2`, `tvoc`, `pm25`, `pm10` gibi alanlar ve `entity.value` / `entities[].value` formatları taranıyor.
- **entityIdSet boşsa:** Cihazlara ait tüm PROPERTY entity’leri kullanılıyor (önceki davranış).

## Sonuç

- Raporda **yalnızca** dashboard’da kullanılan (widget’larda seçilen) telemetriler görünür.
- Tüm entity’lerin listelenmesi ve çoğunda "—" olması engellendi.
