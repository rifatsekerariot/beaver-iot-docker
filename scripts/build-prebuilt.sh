#!/bin/sh
# Build web (COPY, like local) then api, monolith (CI).
# Run from repo root. Expects build-docker/.env, build-docker/beaver-iot-web/ (ci-clone-web).

set -e
BD="$(dirname "$0")/../build-docker"
cd "$BD"

# 1. Web from build-docker/beaver-iot-web (COPY, same as local) – not git-in-container
docker build --network=host -f beaver-iot-web-ci.dockerfile -t milesight/beaver-iot-web:latest .
# 2. Api, monolith (compose); monolith uses BASE_WEB_IMAGE=milesight/beaver-iot-web:latest
docker compose build --no-cache api monolith
