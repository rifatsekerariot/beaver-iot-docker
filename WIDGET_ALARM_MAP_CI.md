# Alarm / Map widget’lar – yerel imaj vs GitHub imaj

## Yerel imajda nasıl çalışıyor?

**Monolith** (`milesight/beaver-iot:latest`) içinde `/web` frontend build’inden geliyor:

- `/web/index.html` → ana sayfa; `/web/assets/js/index-*.js` entry.
- `/web/assets/js/` içinde **widget chunk’ları**:
  - **Alarm-yP28KY9z.js** – Alarm widget (lazy-loaded)
  - **Map-tdPfu7n2.js** – Map widget (lazy-loaded)
  - **Table-CiutCydg.js** – Device List widget (lazy-loaded)

Bu chunk’lar **beaver-iot-web** build’inden (Vite) geliyor. Plugin klasörleri (`alarm/`, `map/`, `device-list/` vb.) `control-panel/index.ts` ile **components.ts** glob’unda (`./*/control-panel/index.ts`) toplanıyor; **useFilterPlugins** hepsini gösteriyor (filtre yok). Vite her plugin için ayrı chunk üretiyor → `Alarm-*.js`, `Map-*.js`, `Table-*.js`.

## GitHub imajına uygulama

1. **Kaynak:** `rifatsekerariot/beaver-iot-web` **main** – **components.ts** (glob + regex) ve **useFilterPlugins** (filtre yok) bu repoda.
2. **Build:** CI **beaver-iot-web-local.dockerfile** kullanıyor; context = workspace root, `COPY beaver-iot-web/`, `pnpm build` – yerelle aynı.
3. **Layout:** Restructure + `beaver-iot-web` root’ta clone – yerel `c:\Projeler` yapısıyla aynı.
4. **Doğrulama:** `verify-web-image.sh` web imajında **Alarm-*.js** ve **Map-*.js** chunk’larının varlığını kontrol ediyor. Eksikse CI fail ediyor.

## Verify komutu (CI’da kullanılan)

```sh
docker run --rm --entrypoint sh milesight/beaver-iot-web:latest -c '
  test -f /web/index.html && test -d /web/assets && test -d /web/assets/js && \
  ls /web/assets/js | grep -qE "^Alarm-" && \
  ls /web/assets/js | grep -qE "^Map-"
'
```

Yerel **milesight/beaver-iot-web:latest** ile çalıştırıldığında OK dönüyorsa, GitHub’da da aynı build’den üretilen imaj bu kontrolleri geçer.
