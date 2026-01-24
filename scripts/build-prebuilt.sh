#!/bin/sh
# Build web (same as local: beaver-iot-web-local.dockerfile + root context), push to GHCR,
# then api + monolith. Monolith uses BASE_WEB_IMAGE=ghcr.io/.../beaver-iot-web so buildx
# pulls OUR image (not upstream), fixing Alarm/Map missing in pushed monolith.
# Run from workspace root. Expects { beaver-iot-web/, beaver-iot-docker/ } (restructure-ci-workspace).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BD="$ROOT/beaver-iot-docker/build-docker"
WEB_GHCR="${WEB_GHCR_IMAGE:-ghcr.io/rifatsekerariot/beaver-iot-web:latest}"

cd "$ROOT"
# 1. Web – same as local: beaver-iot-web-local.dockerfile, context = workspace root
docker build --no-cache --network=host \
  -f beaver-iot-docker/build-docker/beaver-iot-web-local.dockerfile \
  -t milesight/beaver-iot-web:latest \
  -t "$WEB_GHCR" .

# 2. Push web to GHCR so compose/buildx uses OUR image (not Docker Hub upstream)
docker push "$WEB_GHCR"

# 3. Point monolith at our web image; then api + monolith
echo "BASE_WEB_IMAGE=$WEB_GHCR" >> "$BD/.env"
cd "$BD"
docker compose build --no-cache api monolith
