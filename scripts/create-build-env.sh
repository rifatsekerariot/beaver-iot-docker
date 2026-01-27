#!/bin/sh
# Create build-docker/.env for CI (Build and push prebuilt image).
# Run from repo root.
# API: rifatsekerariot/beaver-iot (Alarm backend, t_alarm, PostgreSQL changelog v1.4.0).
# Override: API_GIT_REPO_URL, API_GIT_BRANCH env.

set -e
cd "$(dirname "$0")/../build-docker"
API_GIT_REPO_URL="${API_GIT_REPO_URL:-https://github.com/rifatsekerariot/beaver-iot.git}"
API_GIT_BRANCH="${API_GIT_BRANCH:-origin/main}"
cat << ENVEOF > .env
API_GIT_REPO_URL=$API_GIT_REPO_URL
API_GIT_BRANCH=$API_GIT_BRANCH
WEB_GIT_REPO_URL=https://github.com/rifatsekerariot/beaver-iot-web.git
WEB_GIT_BRANCH=origin/main
DOCKER_REPO=milesight
PRODUCTION_TAG=latest
ENVEOF
echo "Created build-docker/.env (API=$API_GIT_REPO_URL $API_GIT_BRANCH)"
