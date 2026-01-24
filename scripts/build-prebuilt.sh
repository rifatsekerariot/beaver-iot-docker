#!/bin/sh
# Build web (same as local: beaver-iot-web-local.dockerfile + root context) then api, monolith.
# Run from workspace root. Expects { beaver-iot-web/, beaver-iot-docker/ } (restructure-ci-workspace).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# workspace root = parent of beaver-iot-docker (when restructured)
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BD="$ROOT/beaver-iot-docker/build-docker"

cd "$ROOT"
# 1. Web – exact same as local: beaver-iot-web-local.dockerfile, context = workspace root
docker build --network=host \
  -f beaver-iot-docker/build-docker/beaver-iot-web-local.dockerfile \
  -t milesight/beaver-iot-web:latest .

cd "$BD"
# 2. Api, monolith (compose); monolith uses BASE_WEB_IMAGE=milesight/beaver-iot-web:latest
docker compose build --no-cache api monolith
