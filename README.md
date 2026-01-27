# Beaver IoT Docker

[![Build Docker Image](https://github.com/rifatsekerariot/beaver-iot-docker/actions/workflows/build-push-prebuilt.yaml/badge.svg)](https://github.com/rifatsekerariot/beaver-iot-docker/actions/workflows/build-push-prebuilt.yaml)

Beaver IoT platform with **ChirpStack v4 HTTP Integration** support, custom widgets, and zero-touch deployment.

## Features

- ✅ **ChirpStack v4 HTTP Integration** - Seamless integration with ChirpStack LoRaWAN Network Server
- ✅ **Custom Widgets** - Alarm, Map, DeviceList, and 12+ custom widgets (Alert Indicator, Air Quality Card, Status Badge, etc.)
- ✅ **Backend Ready Check** - Automatic loading screen while backend API initializes
- ✅ **Zero-Touch Deployment** - Single script deployment on Linux servers
- ✅ **Prebuilt Docker Images** - Ready-to-use images pushed to GitHub Container Registry (GHCR)
- ✅ **CI/CD Pipeline** - Automated builds with GitHub Actions

## Requirements

- **Docker**: Version 20.10 or higher
- **Linux** (for zero-touch deployment): Ubuntu 20.04/22.04, Debian 11+, RHEL/CentOS 8+, Amazon Linux 2
- **Git** (optional, for building from source)

## Quick Start

### Zero-Touch Deployment (Linux)

Deploy Beaver IoT + ChirpStack on a Linux server with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s --
```

**With custom tenant ID:**

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --tenant-id=my-tenant
```

**Build from source (instead of using prebuilt image):**

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- --build-images
```

The script will:
1. Install Docker (if not present)
2. Install Git (if not present)
3. Clone `beaver-iot-docker` repository
4. Pull prebuilt image from GHCR (or build from source with `--build-images`)
5. Start Beaver IoT + ChirpStack stack

**Access:**
- Web UI: `http://your-server:9080`
- ChirpStack Webhook: `http://your-server:9080/public/integration/chirpstack/webhook?event=uplink`

For detailed deployment instructions, see [ZERO_TOUCH_DEPLOY.md](./ZERO_TOUCH_DEPLOY.md).

### Caddy + PostgreSQL (HTTPS, 443)

PostgreSQL + Caddy ile domain uzerinden otomatik HTTPS:

```bash
curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-caddy-postgres.sh | sudo sh -s --
```

Ilk kurulumda domain sorulur; `--domain beaver.example.com` ile de verilebilir. Bkz. [CADDY_POSTGRES_DEPLOY.md](./CADDY_POSTGRES_DEPLOY.md).

## Build from Source

### Preparations

Navigate to the `build-docker` directory and create a `.env` configuration file:

```shell
cd build-docker
touch .env
```

Edit the `.env` configuration file with the following content:

```dotenv
# Load the build result to `docker images`
DOCKER_BUILD_OPTION_LOAD=true
# Docker registry and repository
DOCKER_REGISTRY=milesight
# Image tag
PRODUCTION_TAG=latest
# Git repository URLs and branches
WEB_GIT_REPO_URL=https://github.com/rifatsekerariot/beaver-iot-web.git
WEB_GIT_BRANCH=origin/main
API_GIT_REPO_URL=https://github.com/Milesight-IoT/beaver-iot.git
API_GIT_BRANCH=origin/release
```

> **Note:** This project uses custom repositories:
> - `beaver-iot-web`: `rifatsekerariot/beaver-iot-web` (main branch) - includes custom widgets and BackendReadyCheck
> - `beaver-iot-integrations`: `rifatsekerariot/beaver-iot-integrations` (main branch) - includes ChirpStack v4 HTTP integration

### Building via Bash Script

Execute the build script to commence the build process:

```shell
./build-docker/build.sh
```

If you need to build only specific images, you can specify them using the `--build-target` parameter:

```shell
./build-docker/build.sh --build-target=beaver-iot,beaver-iot-web
```

For additional configuration options, use the --help option:

```shell
./build-docker/build.sh --help
```

### Building via Docker Compose

If you don't have a Bash environment, you can build the images directly using Docker Compose:

```shell
cd build-docker && docker compose build --no-cache
```

### Building with Local Web Source (Development)

For local development with `beaver-iot-web` in a sibling directory:

**PowerShell (Windows):**

```powershell
.\scripts\run-with-local-web.ps1
```

This script will:
1. Prepare ChirpStack integration JAR
2. Build `beaver-iot-web` image from local source
3. Build API and Monolith images
4. Start Docker Compose stack

## ChirpStack Integration

### Configuration

The ChirpStack HTTP integration requires a **tenant ID** to be configured. You can set it via:

1. **Environment variable** (recommended):
   ```bash
   export CHIRPSTACK_DEFAULT_TENANT_ID=your-tenant-id
   ```

2. **HTTP header** (per request):
   ```http
   X-Tenant-Id: your-tenant-id
   ```

3. **Docker Compose** (in `examples/chirpstack-prebuilt.yaml`):
   ```yaml
   environment:
     CHIRPSTACK_DEFAULT_TENANT_ID: ${CHIRPSTACK_DEFAULT_TENANT_ID:-default}
   ```

### Webhook Endpoint

Configure ChirpStack to send webhooks to:

```
http://your-server:9080/public/integration/chirpstack/webhook?event=uplink
```

**Supported events:**
- `uplink` - Device uplink data
- `join` - Device join event
- `status` - Device status update

### Adding Devices

1. Send webhook from ChirpStack (device will be auto-created)
2. Or manually add device via Beaver IoT web UI:
   - Go to **Devices** → **Add Device**
   - Select **ChirpStack** integration
   - Enter **DevEUI** (device EUI from ChirpStack)

For detailed ChirpStack setup, see [CHIRPSTACK_QUICKSTART.md](./CHIRPSTACK_QUICKSTART.md).

## Custom Widgets

This project includes custom widgets beyond the standard Beaver IoT widgets:

- **Alarm Widget** - Visual alarm indicators
- **Map Widget** - Device location mapping
- **Device List Widget** - Device listing and management
- **Alert Indicator** - Single entity alert display
- **Air Quality Card** - Multi-entity air quality metrics (CO2, TVOC, PM2.5, PM10)
- **Status Badge** - Entity status badge
- **Counter Card** - Numeric counter display
- **Security Icon** - Security status indicator
- **Thermostat Dial** - Temperature control display
- **Rainfall Histogram** - Rainfall data visualization
- **Signal Quality Dial** - RSSI/SNR/SF signal metrics
- **HVAC Schematic** - Fan and valve status
- **Wind Rose** - Wind direction and speed
- **Industrial Gauges** - ADC/ADV/Modbus metrics
- **Network Table** - Network data table

All widgets support:
- Real-time data updates
- Alarm emphasis (visual highlighting for alarm conditions)
- Responsive layout
- Multi-entity selection (where applicable)

## Docker Compose Examples

### Prebuilt Image (Recommended)

Uses prebuilt image from GHCR (ChirpStack JAR baked in, no build required):

```bash
cd examples
docker compose -f chirpstack-prebuilt.yaml up -d
```

### Build from Source

Builds images from source (includes ChirpStack JAR build):

```bash
cd examples
docker compose -f chirpstack.yaml up -d
```

### Monolith Only

Run only the monolith service:

```bash
cd examples
docker compose -f monolith.yaml up -d
```

## CI/CD

### GitHub Actions Workflow

The project includes a CI/CD pipeline that:

1. Builds ChirpStack integration JAR
2. Clones `beaver-iot-web` repository
3. Builds Docker images (web, api, monolith)
4. Pushes images to GitHub Container Registry (GHCR)

**Workflow:** `.github/workflows/build-push-prebuilt.yaml`

**Prebuilt Image:** `ghcr.io/rifatsekerariot/beaver-iot:latest`

**Manual Trigger:**
- Go to **Actions** → **Build and push prebuilt image** → **Run workflow**

**Automatic Trigger:**
- Push to `main` branch (when `build-docker/**`, `scripts/**`, `examples/**`, or `.github/workflows/build-push-prebuilt.yaml` changes)

## Project Structure

```
beaver-iot-docker/
├── build-docker/          # Docker build configuration
│   ├── beaver-iot.dockerfile
│   ├── beaver-iot-web-local.dockerfile
│   ├── docker-compose.yaml
│   └── .env.example
├── examples/              # Docker Compose examples
│   ├── chirpstack-prebuilt.yaml
│   ├── chirpstack.yaml
│   └── monolith.yaml
├── scripts/              # Deployment and build scripts
│   ├── deploy-zero-touch.sh
│   ├── build-prebuilt.sh
│   └── ci-*.sh
└── .github/workflows/    # CI/CD workflows
    └── build-push-prebuilt.yaml
```

## Related Repositories

- **beaver-iot-web**: [rifatsekerariot/beaver-iot-web](https://github.com/rifatsekerariot/beaver-iot-web) - Frontend with custom widgets
- **beaver-iot-integrations**: [rifatsekerariot/beaver-iot-integrations](https://github.com/rifatsekerariot/beaver-iot-integrations) - ChirpStack v4 HTTP integration

## Documentation

- [Zero-Touch Deployment Guide](./ZERO_TOUCH_DEPLOY.md)
- [ChirpStack Quick Start](./CHIRPSTACK_QUICKSTART.md)
- [ChirpStack Data Not Coming Fix](./CHIRPSTACK_VERILER_GELMIYOR_FIX.md)

## Troubleshooting

### Backend Not Ready (502 Error)

If you see a 502 error on `/api/v1/user/status`:
- The **BackendReadyCheck** component will show a loading screen until the backend is ready
- Wait for the Java API to fully start (usually 30-60 seconds)
- Check Docker logs: `docker compose logs monolith`

### ChirpStack Data Not Coming

If ChirpStack webhooks are not being processed:
1. Check `CHIRPSTACK_DEFAULT_TENANT_ID` is set (defaults to "default" if not provided)
2. Verify webhook URL in ChirpStack: `http://your-server:9080/public/integration/chirpstack/webhook?event=uplink`
3. Check Docker logs: `docker compose logs monolith | grep -i chirpstack`
4. See [CHIRPSTACK_VERILER_GELMIYOR_FIX.md](./CHIRPSTACK_VERILER_GELMIYOR_FIX.md)

### Widgets Not Visible

If custom widgets are not visible in the "Add widget" UI:
1. Ensure you're using the prebuilt image from GHCR: `ghcr.io/rifatsekerariot/beaver-iot:latest`
2. Check CI/CD build completed successfully
3. Verify web image contains widget chunks: `docker run --rm --entrypoint sh ghcr.io/rifatsekerariot/beaver-iot:latest -c "ls /web/assets/js | grep -E 'useAlarmEmphasis-|DrawingBoard-'"`

## License

See [LICENSE](./LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For security issues, see [SECURITY.md](./SECURITY.md).
