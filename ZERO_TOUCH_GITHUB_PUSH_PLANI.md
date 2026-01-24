# Zero-Touch Canlı Test – GitHub Güncelleme Planı

**Amaç:** Canlı sunucuda tek komutla (`--build-images`) test edilebilmesi için GitHub’daki kodları güncellemek. **Temkinli:** Var olan davranışı bozmadan, yalnızca gerekli değişiklikler push edilecek.

---

## 1. Güncellenecek repolar

| Repo | Hedef branch | Yapılacak iş |
|------|--------------|--------------|
| **beaver-iot-integrations** (beaver) | main | ENTEGRASYON_WIDGET_DOCKER, CHIRPSTACK_BAGLANTI linki |
| **beaver-iot-web** | main | `useFilterPlugins` (Alarm/Map/DeviceList widget) |
| **beaver-iot-docker** | main | deploy-zero-touch `--build-images`, ZERO_TOUCH_DEPLOY, build-docker düzeltmeleri |

---

## 2. beaver-iot-docker (önce)

- **Commit edilecek:**  
  `scripts/deploy-zero-touch.sh`, `ZERO_TOUCH_DEPLOY.md`,  
  `build-docker/beaver-iot.dockerfile`, `build-docker/docker-entrypoint.sh`,  
  `build-docker/nginx/*` (LF),  
  `build-docker/beaver-iot-web-local.dockerfile`, `dockerignore-for-local-web`,  
  `scripts/build-web-local.ps1`, `scripts/run-with-local-web.ps1`
- **Commit edilmeyecek:** `api-build.log`, `DURUM_VE_SONRAKI_ADIMLAR.md` (opsiyonel; istenirse ayrı commit).
- **.gitignore:** `api-build.log` eklenmeli.

---

## 3. beaver-iot-integrations (beaver)

- **Commit edilecek:**  
  `ENTEGRASYON_WIDGET_DOCKER.md`,  
  `CHIRPSTACK_BAGLANTI_VE_CALISTIRMA.md` (widget + run-with-local-web kısmı).
- **Commit edilmeyecek:**  
  PDF’ler, `build-integrations.log`, diğer rapor MD’leri (ALARM_WIDGET_DURUM, BEAVER_IOT_DOCS_ANALIZ, vb.).

---

## 4. beaver-iot-web

- **Commit edilecek:**  
  Yalnızca `apps/web/src/components/drawing-board/hooks/useFilterPlugins.tsx` (Alarm/Map/DeviceList filtreden çıkarıldı).
- **Diğer değişiklikler:** Bu push’ta dahil edilmeyecek (temkinli).

---

## 5. Zero-touch canlı test komutu (güncelleme sonrası)

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default" --build-images
```

- **Build-images kapalı** (varsayılan): Mevcut davranış aynen kalır (JAR + compose up, image pull).
- **Build-images açık:** api/web/monolith build, WEB = rifatsekerariot/beaver-iot-web; widget’lı UI ile canlı test.

---

*Bu plan, temkinli ve minimal güncelleme ile zero-touch canlı testi mümkün kılmak için hazırlanmıştır.*
