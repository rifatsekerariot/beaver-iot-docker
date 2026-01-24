#!/bin/sh
# Clone beaver-iot-web for CI. Run from workspace root.
# DEST=beaver-iot-web (sibling of beaver-iot-docker) for local layout; else build-docker/beaver-iot-web.

set -e
WEB_REPO="${WEB_GIT_REPO_URL:-https://github.com/rifatsekerariot/beaver-iot-web.git}"
DEST="${CI_CLONE_WEB_DEST:-build-docker/beaver-iot-web}"

rm -rf "$DEST"
git clone --depth 1 -b main "$WEB_REPO" "$DEST"
echo "Cloned beaver-iot-web into $DEST (main)"
