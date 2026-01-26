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
# 1. Web – use beaver-iot-web-local.dockerfile (workspace root context, beaver-iot-web/ sibling)
echo "Building web image with beaver-iot-web-local.dockerfile (context: workspace root)"
echo "Verifying beaver-iot-web source before build..."
if [ ! -d "beaver-iot-web" ]; then
  echo "ERROR: beaver-iot-web directory not found!"
  exit 1
fi
echo "beaver-iot-web directory exists, checking latest commit..."
cd beaver-iot-web
LATEST_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "not a git repo")
LATEST_COMMIT_MSG=$(git log -1 --pretty=format:"%h %s" 2>/dev/null || echo "no commit message")
echo "Latest commit in beaver-iot-web: $LATEST_COMMIT"
echo "Latest commit message: $LATEST_COMMIT_MSG"
cd "$ROOT"
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
