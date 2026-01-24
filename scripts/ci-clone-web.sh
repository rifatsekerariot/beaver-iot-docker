#!/bin/sh
# Clone beaver-iot-web into build-docker/beaver-iot-web (CI).
# Run from repo root. Branch main. Same source as local (COPY, not clone-in-Dockerfile).

set -e
WEB_REPO="${WEB_GIT_REPO_URL:-https://github.com/rifatsekerariot/beaver-iot-web.git}"
DEST="build-docker/beaver-iot-web"

rm -rf "$DEST"
git clone --depth 1 -b main "$WEB_REPO" "$DEST"
echo "Cloned beaver-iot-web into $DEST (main)"
