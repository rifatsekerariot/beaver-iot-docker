#!/bin/sh
# Build api, web, monolith in order (CI).
# Run from repo root. Expects build-docker/.env.

set -e
cd "$(dirname "$0")/../build-docker"
docker compose build --no-cache api
docker compose build --no-cache web
docker compose build --no-cache monolith
