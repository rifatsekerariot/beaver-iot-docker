# Beaver IoT + PostgreSQL + Caddy (HTTPS, 443)

Tek `curl` komutu ile: **PostgreSQL** + **Caddy** (otomatik HTTPS, Let's Encrypt). Domain ile `https://domain` uzerinden erisim.

---

## Hizli baslangic

### Tek komut (domain ilk kurulumda sorulur)

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-caddy-postgres.sh | sudo sh -s --
```

Script **domain adresinizi ister**; girerken Enter’a basın. Domain `$WORKSPACE/.beaver-domain` dosyasina yazilir. Sonraki calistirmalarda bu dosyadan okunur.

### Domain’i komutla vermek

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-caddy-postgres.sh | sudo sh -s -- --domain beaver.sirket.com
```

### Diger secenekler

```bash
# Workspace (varsayilan: /opt/beaver-chirpstack)
curl -sSL .../deploy-caddy-postgres.sh | sudo sh -s -- --domain beaver.example.com --workspace /opt/beaver

# PostgreSQL sifresi
curl -sSL .../deploy-caddy-postgres.sh | sudo sh -s -- --domain beaver.example.com --postgres-password "gizli"

# ChirpStack tenant
curl -sSL .../deploy-caddy-postgres.sh | sudo sh -s -- --domain beaver.example.com --tenant-id "default"

# Docker kurma (zaten kuruluysa)
curl -sSL .../deploy-caddy-postgres.sh | sudo sh -s -- --domain beaver.example.com --skip-docker-install
```

---

## Gereksinimler

- **Linux** (Ubuntu, Debian, RHEL, vb.)
- **Domain:** A kaydi sunucunun dis IP’sine yonlendirilmis olmali.
- **Portlar:** 80 ve 443 dis dunyaya acik (Caddy, Let’s Encrypt ACME icin).
- **sudo** (Docker ve Git kurulumu icin; `--skip-docker-install` ile Docker’i atlayabilirsiniz).

---

## Ne calisir?

1. **Docker** (ve gerekirse **Git**) yoksa kurar.
2. **beaver-iot-docker** klonlar / gunceller.
3. **Domain** alir: `--domain`, `.beaver-domain` veya ilk kurulumda kullanicidan.
4. **Caddyfile** uretir: `domain { reverse_proxy monolith:80 }`.
5. **Compose** ile ayaga kaldirir:
   - **postgresql**
   - **monolith** (Beaver IoT; 9080, 1883, 8083)
   - **caddy** (80, 443; Let’s Encrypt ile otomatik HTTPS).

---

## Domain degistirmek

Domain’i degistirmek icin `.beaver-domain` dosyasini silin ve scripti tekrar calistirin:

```bash
sudo rm /opt/beaver-chirpstack/.beaver-domain
curl -sSL .../deploy-caddy-postgres.sh | sudo sh -s --
```

Yeni domain girilir; Caddyfile yeniden yazilir. Caddy’yi yeniden baslatmak icin:

```bash
cd /opt/beaver-chirpstack/beaver-iot-docker/examples
docker compose -f chirpstack-prebuilt-postgres-caddy.yaml up -d caddy
```

---

## Sertifika ve yenileme

- **Caddy**, Let’s Encrypt sertifikasini kendisi alir ve yeniler.
- Sertifikalar `caddy_data` volume’unda; konteyner silinmedikce korunur.
- Ilk acilista 1–2 dakika surer; domain 80/443’ten ulasilabilir olmali.

---

## Ozet

| Konu        | Deger                                              |
|------------|-----------------------------------------------------|
| HTTPS      | `https://&lt;domain&gt;`                            |
| Yedek HTTP | `http://localhost:9080`                             |
| Webhook    | `https://&lt;domain&gt;/public/integration/chirpstack/webhook` |
| Compose    | `chirpstack-prebuilt-postgres-caddy.yaml`           |
| Domain     | `$WORKSPACE/.beaver-domain`                         |
