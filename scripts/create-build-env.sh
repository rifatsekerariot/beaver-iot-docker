#!/bin/sh
# Create build-docker/.env for CI (Build and push prebuilt image).
# Run from repo root.

set -e
cd "$(dirname "$0")/../build-docker"
cat << 'ENVEOF' > .env
API_GIT_REPO_URL=https://github.com/Milesight-IoT/beaver-iot.git
API_GIT_BRANCH=origin/release
WEB_GIT_REPO_URL=https://github.com/rifatsekerariot/beaver-iot-web.git
WEB_GIT_BRANCH=origin/main
DOCKER_REPO=milesight
PRODUCTION_TAG=latest
ENVEOF
echo "Created build-docker/.env"
