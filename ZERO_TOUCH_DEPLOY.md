# Beaver IoT + ChirpStack – Zero Touch Dağıtım (Linux)

Bu dokümanda, **Beaver IoT + ChirpStack v4 HTTP entegrasyonunu** bir **Linux sunucusunda** **tek script ile (zero touch)** nasıl ayağa kaldıracağınız anlatılır. **Sadece Linux** desteklenir; Windows kullanılmaz.

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
7. **`chirpstack.yaml`** ile `docker compose up -d` çalıştırır.
8. **`CHIRPSTACK_DEFAULT_TENANT_ID`**: `--tenant-id` ile verdiğiniz değer ortam değişkeni olarak compose’a geçer.

---

## Parametreler

| Parametre | Açıklama |
|-----------|----------|
| `--tenant-id "default"` | Beaver tenant ID (ChirpStack webhook için). |
| `--workspace /opt/beaver` | Klonlama ve compose’un çalışacağı dizin. |
| `--skip-docker-install` | Docker kurma; zaten kuruluysa kullan. |

**Ortam değişkenleri:**

| Değişken | Açıklama |
|----------|----------|
| `WORKSPACE` | Workspace dizini (`--workspace` öncelikli). |
| `REPO_INTEGRATIONS` | integrations repo URL (opsiyonel). |
| `REPO_DOCKER` | docker repo URL (opsiyonel). |

---

## Dağıtım sonrası

- **Beaver UI:** `http://<SUNUCU_IP>:9080`
- **Webhook (ChirpStack):** `http://<SUNUCU_IP>:9080/public/integration/chirpstack/webhook`
- **Log:** `docker logs -f beaver-iot`
- **Test:** `curl` ile webhook’a POST veya `scripts/test-webhook.ps1` başka bir makineden (Windows) çalıştırılabilir; sunucu tarafı sadece Linux.

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

- **Linux sunucuda** tek komut:  
  `curl -sSL .../deploy-zero-touch.sh | sudo sh -s -- --tenant-id "default"`
- Docker ve gerekirse Git script ile kurulur, repolar klonlanır, JAR build edilir, compose ayağa kalkar.
- **Sadece Linux** kullanılır; Windows için bu zero-touch dağıtım **yoktur**.
