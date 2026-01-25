#!/bin/sh
# Verify web image has /web, index.html, assets, and Alarm/Map widget chunks (match local).
# Run after building milesight/beaver-iot-web:latest. Fail if widget chunks missing.

set -e
IMAGE="${VERIFY_WEB_IMAGE:-milesight/beaver-iot-web:latest}"

docker run --rm --entrypoint sh "$IMAGE" -c '
  test -f /web/index.html || { echo "missing /web/index.html"; exit 1; }
  test -d /web/assets || { echo "missing /web/assets"; exit 1; }
  test -d /web/assets/js || { echo "missing /web/assets/js"; exit 1; }
  ls /web/assets/js | grep -qE "^Alarm-" || { echo "missing Alarm-*.js widget chunk"; exit 1; }
  ls /web/assets/js | grep -qE "^Map-"   || { echo "missing Map-*.js widget chunk"; exit 1; }
'
echo "OK: web image has index.html, assets, Alarm and Map widget chunks ($IMAGE)"
