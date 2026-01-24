# Beaver IoT + ChirpStack – Zero Touch Dağıtım (Linux)

Bu dokümanda, **Beaver IoT + ChirpStack v4 HTTP entegrasyonunu** bir **Linux sunucusunda** **tek script ile (zero touch)** nasıl ayağa kaldıracağınız anlatılır. **Sadece Linux** desteklenir; Windows kullanılmaz.

---

## Script çalıştırınca sistem otomatik ayağa kalkar mı?

**Evet.** Linux sunucuda script’i `sudo` ile çalıştırırsanız, **hiçbir şeyi elle kurmanıza gerek kalmadan**:

1. Docker yoksa kurulur  
2. Git yoksa kurulur  
3. Repolar klonlanır  
4. ChirpStack JAR build edilir (Docker Maven)  
5. JAR kopyalanır, `docker compose` ile Beaver + ChirpStack ayağa kalkar  

**Şartlar:** Linux, `sudo`, internet, **9080 / 1883 / 8083** portları boş olmalı.  
Windows’ta çalışmaz; WSL veya uzak Linux sunucu kullanın.

---

## Zero touch ne demek?

- Sunucuda **tek `deploy-zero-touch.sh`** çalıştırıyorsunuz.
- Script: Docker kurulumu (yoksa), Git (yoksa), repo klonlama, ChirpStack JAR build, compose ile **Beaver’ı ayağa kaldırır**.
- Elle Maven/Java kurmanız gerekmez; build Docker ile yapılır.

---

## Gereksinimler

- **Linux**: Ubuntu 20.04/22.04, Debian 11+, RHEL/CentOS 8+, Amazon Linux 2.
- **root** veya **sudo** (Docker kurulumu için).
- **İnternet** erişimi (Docker, Maven, Docker Hub, GitHub).
- **Git**: Script yoksa kurar (apt/dnf/yum).

---

## Hızlı başlangıç

### Tek komut (curl ile)

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s --
```

**Tenant ID ile:**

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default"
```

**Özel workspace (varsayılan `/opt/beaver-chirpstack`):**

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default" --workspace /opt/beaver-chirpstack
```

### Script’i indirip çalıştır

```bash
sudo wget -qO /tmp/deploy-zero-touch.sh https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh
sudo sh /tmp/deploy-zero-touch.sh --tenant-id "default"
```

**Workspace env ile:**

```bash
sudo WORKSPACE=/opt/beaver-chirpstack sh /tmp/deploy-zero-touch.sh --tenant-id "default"
```

**Canlı sunucuda kendi fork'larınızla test (Alarm/Map/DeviceList widget'ları dahil):**

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default" --build-images
```

Bu komut api/web/monolith'ı build eder (WEB = rifatsekerariot/beaver-iot-web). **15–25 dakika** sürebilir. Tek komut, zero touch; kurulum sonrası UI `http://<sunucu>:9080` üzerinden erişilir.

---

## Script ne yapar?

1. **Docker** yoksa kurar (`get.docker.com`).
2. **Git** yoksa kurar (apt-get / dnf / yum).
3. **Workspace** oluşturur: varsayılan **`/opt/beaver-chirpstack`**.
4. **Klonlar:**  
   - `beaver-iot-integrations` (rifatsekerariot)  
   - `beaver-iot-docker` (rifatsekerariot)
5. **ChirpStack JAR** build: `docker run` ile Maven.
6. JAR’ı `examples/target/chirpstack/integrations/` altına kopyalar.
7. **İsteğe bağlı:** `--build-images` ile api/web/monolith build (WEB = rifatsekerariot/beaver-iot-web; Alarm/Map/DeviceList dahil). Varsayılan kapalı; `milesight/beaver-iot:latest` pull.
8. **`chirpstack.yaml`** ile `docker compose up -d` çalıştırır.
9. **`CHIRPSTACK_DEFAULT_TENANT_ID`**: `--tenant-id` ile verdiğiniz değer ortam değişkeni olarak compose’a geçer.

---

## Parametreler

| Parametre | Açıklama |
|-----------|----------|
| `--tenant-id "default"` | Beaver tenant ID (ChirpStack webhook için). |
| `--workspace /opt/beaver` | Klonlama ve compose’un çalışacağı dizin. |
| `--skip-docker-install` | Docker kurma; zaten kuruluysa kullan. |
| `--build-images` | api/web/monolith'ı kaynaktan build et (WEB = fork). **Canlı sunucu test** için kullanın; 15–25 dk sürebilir. Varsayılan: kapalı. |
| `--web-repo URL` | Web repo URL (`--build-images` ile). Varsayılan: rifatsekerariot/beaver-iot-web. |
| `--web-branch BRANCH` | Web branch (`--build-images` ile). Varsayılan: `origin/main`. |

**Ortam değişkenleri:**

| Değişken | Açıklama |
|----------|----------|
| `WORKSPACE` | Workspace dizini (`--workspace` öncelikli). |
| `REPO_INTEGRATIONS` | integrations repo URL (opsiyonel). |
| `REPO_DOCKER` | docker repo URL (opsiyonel). |
| `REPO_WEB` | Web repo URL (`--build-images` ile; varsayılan: rifatsekerariot/beaver-iot-web). |
| `REPO_WEB_BRANCH` | Web branch (`--build-images` ile; varsayılan: `origin/main`). |
| `REPO_API` | API (beaver-iot) repo URL (`--build-images` ile; varsayılan: Milesight-IoT/beaver-iot). |
| `REPO_API_BRANCH` | API branch (`--build-images` ile; varsayılan: `origin/release`). |

---

## Dağıtım sonrası

- **Beaver UI:** `http://<SUNUCU_IP>:9080`
- **Webhook (ChirpStack):** `http://<SUNUCU_IP>:9080/public/integration/chirpstack/webhook`
- **Log:** `docker logs -f beaver-iot`
- **Test:** `curl` ile webhook’a POST veya `scripts/test-webhook.ps1` başka bir makineden (Windows) çalıştırılabilir; sunucu tarafı sadece Linux.
- **Cihaz ekleme:** Webhook’tan gelen cihazlar için önce Beaver’da kayıt gerekir: **Device → Add → ChirpStack HTTP** → Device Name + **External Device ID (DevEUI)** (ChirpStack’teki DevEUI ile aynı) → Confirm. Ayrıntı: `CHIRPSTACK_BAGLANTI_VE_CALISTIRMA.md` (integrations repo).

---

## Cloud / VM ile zero touch

### AWS EC2 user-data

Örnek (Amazon Linux 2 / Ubuntu):

```bash
#!/bin/bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default"
```

### Azure VM (Linux)

Custom script extension ile `deploy-zero-touch.sh` indirilip `sudo sh` ile çalıştırılabilir.

### Genel

İlk açılışta (cloud-init, user-data, custom script) yalnızca bu script’i çalıştıracak şekilde ayarlarsanız **zero touch** dağıtım elde edersiniz.

---

## Sorun giderme

| Sorun | Olası neden | Çözüm |
|-------|-------------|--------|
| `docker: command not found` | Docker yok | `--skip-docker-install` kullanmayın; script kurar. |
| `Permission denied` | Yetki yetersiz | `sudo` ile çalıştırın. |
| `git clone` failed | Ağ / firewall | GitHub (443) erişimini kontrol edin. |
| `Cannot connect to Docker daemon` | Docker kapalı | `sudo systemctl start docker` |
| Port 9080 kullanımda | Çakışma | `chirpstack.yaml`’da portu değiştirin (örn. 9081:80). |

---

## Özet

- **Canlı sunucu test (widget'lı):** `curl -sSL .../deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default" --build-images`
- **Linux sunucuda** tek komut (varsayılan, pull):  
  `curl -sSL .../deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default"`
- Docker ve gerekirse Git script ile kurulur, repolar klonlanır, JAR build edilir, compose ayağa kalkar.
- **Sadece Linux** kullanılır; Windows için bu zero-touch dağıtım **yoktur**.
