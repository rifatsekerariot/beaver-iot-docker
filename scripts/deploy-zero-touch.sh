#!/bin/sh
# Zero-touch deploy: Beaver IoT + ChirpStack v4 on a Linux server.
# Linux only. Usage:
#   curl -sSL https://raw.githubusercontent.com/rifatsekerariot/beaver-iot-docker/main/scripts/deploy-zero-touch.sh | sudo sh -s -- [--tenant-id ID] [--workspace DIR] [--skip-docker-install]
#   ./deploy-zero-touch.sh [options]

set -e

REPO_INTEGRATIONS="${REPO_INTEGRATIONS:-https://github.com/rifatsekerariot/beaver-iot-integrations.git}"
REPO_DOCKER="${REPO_DOCKER:-https://github.com/rifatsekerariot/beaver-iot-docker.git}"
MAVEN_IMAGE="${MAVEN_IMAGE:-maven:3.8-eclipse-temurin-17-alpine}"
WORKSPACE="${WORKSPACE:-/opt/beaver-chirpstack}"
TENANT_ID=""
SKIP_DOCKER_INSTALL=""

# POSIX-friendly option parsing
while [ $# -gt 0 ]; do
  case "$1" in
    --tenant-id)
      if [ $# -lt 2 ]; then
        echo "[zero-touch] --tenant-id requires a value"
        exit 1
      fi
      TENANT_ID="$2"
      shift 2
      ;;
    --workspace)
      if [ $# -lt 2 ]; then
        echo "[zero-touch] --workspace requires a value"
        exit 1
      fi
      WORKSPACE="$2"
      shift 2
      ;;
    --skip-docker-install)
      SKIP_DOCKER_INSTALL=1
      shift
      ;;
    *)
      echo "[zero-touch] Unknown option: $1"
      exit 1
      ;;
  esac
done

export WORKSPACE
export CHIRPSTACK_DEFAULT_TENANT_ID="${TENANT_ID}"

echo "[zero-touch] Linux zero-touch deploy: Beaver IoT + ChirpStack v4"
echo "[zero-touch] Workspace: $WORKSPACE"
echo "[zero-touch] Tenant ID:  ${TENANT_ID:-<not set>}"

# --- Docker ---
install_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "[zero-touch] Docker already installed."
    return 0
  fi
  echo "[zero-touch] Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable docker 2>/dev/null || true
    systemctl start docker 2>/dev/null || true
    sleep 2
  fi
}

if [ -z "$SKIP_DOCKER_INSTALL" ]; then
  install_docker
else
  if ! command -v docker >/dev/null 2>&1; then
    echo "[zero-touch] Docker not found. Run without --skip-docker-install to install."
    exit 1
  fi
fi

# --- Git ---
if ! command -v git >/dev/null 2>&1; then
  echo "[zero-touch] Installing Git..."
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq && apt-get install -y -qq git
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y -q git
  elif command -v yum >/dev/null 2>&1; then
    yum install -y -q git
  else
    echo "[zero-touch] Could not install Git (apt-get/dnf/yum not found). Install Git and re-run."
    exit 1
  fi
fi

# --- Workspace ---
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# --- Clone ---
if [ ! -d beaver-iot-integrations ]; then
  echo "[zero-touch] Cloning beaver-iot-integrations..."
  git clone --depth 1 -b main "$REPO_INTEGRATIONS" beaver-iot-integrations
else
  echo "[zero-touch] Updating beaver-iot-integrations..."
  (cd beaver-iot-integrations && git fetch origin main 2>/dev/null; git checkout main 2>/dev/null; git pull --depth 1 2>/dev/null || true)
fi

if [ ! -d beaver-iot-docker ]; then
  echo "[zero-touch] Cloning beaver-iot-docker..."
  git clone --depth 1 -b main "$REPO_DOCKER" beaver-iot-docker
else
  echo "[zero-touch] Updating beaver-iot-docker..."
  (cd beaver-iot-docker && git fetch origin main 2>/dev/null; git checkout main 2>/dev/null; git pull --depth 1 2>/dev/null || true)
fi

# --- Build ChirpStack JAR ---
echo "[zero-touch] Building chirpstack-integration JAR (Docker Maven)..."
docker run --rm \
  -v "$WORKSPACE/beaver-iot-integrations:/workspace" \
  -w /workspace \
  "$MAVEN_IMAGE" \
  mvn clean package -DskipTests -pl integrations/chirpstack-integration -am -q

JAR_DIR="$WORKSPACE/beaver-iot-integrations/integrations/chirpstack-integration/target"
JAR=$(find "$JAR_DIR" -maxdepth 1 -name 'chirpstack-integration-*.jar' ! -name '*original*' 2>/dev/null | head -1)
if [ -z "$JAR" ] || [ ! -f "$JAR" ]; then
  echo "[zero-touch] ERROR: ChirpStack JAR not found in $JAR_DIR"
  exit 1
fi
echo "[zero-touch] Built: $JAR"

# --- Copy JAR ---
TARGET_DIR="$WORKSPACE/beaver-iot-docker/examples/target/chirpstack/integrations"
mkdir -p "$TARGET_DIR"
cp -f "$JAR" "$TARGET_DIR/"
echo "[zero-touch] Copied JAR to $TARGET_DIR"

# --- Compose up ---
COMPOSE_CMD=""
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "[zero-touch] ERROR: docker compose or docker-compose not found. Install Docker Compose and re-run."
  exit 1
fi

echo "[zero-touch] Starting Beaver IoT + ChirpStack stack..."
cd "$WORKSPACE/beaver-iot-docker/examples"
$COMPOSE_CMD -f chirpstack.yaml up -d

# --- Summary ---
SERVER_IP=""
if command -v hostname >/dev/null 2>&1; then
  if hostname -I 2>/dev/null | grep -q .; then
    SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
  fi
fi
if [ -z "$SERVER_IP" ]; then
  SERVER_IP="<sunucu-ip>"
fi

echo ""
echo "[zero-touch] Done."
echo "  UI:       http://${SERVER_IP}:9080"
echo "  Webhook:  http://${SERVER_IP}:9080/public/integration/chirpstack/webhook"
echo "  Logs:     docker logs -f beaver-iot"
