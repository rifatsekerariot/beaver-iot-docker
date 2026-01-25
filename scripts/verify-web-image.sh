#!/bin/sh
# Verify web image has /web, index.html, assets, and widget-related chunks.
# Our build emits useAlarmEmphasis-*, DrawingBoard-* (not Alarm-/Map-); check those.

set -e
IMAGE="${VERIFY_WEB_IMAGE:-milesight/beaver-iot-web:latest}"

docker run --rm --entrypoint sh "$IMAGE" -c '
  test -f /web/index.html || { echo "missing /web/index.html"; exit 1; }
  test -d /web/assets || { echo "missing /web/assets"; exit 1; }
  test -d /web/assets/js || { echo "missing /web/assets/js"; exit 1; }
  ls /web/assets/js | grep -qE "^useAlarmEmphasis-" || { echo "missing useAlarmEmphasis-*.js (widget hook)"; exit 1; }
  ls /web/assets/js | grep -qE "^DrawingBoard-"     || { echo "missing DrawingBoard-*.js"; exit 1; }
'
echo "OK: web image has index.html, assets, useAlarmEmphasis and DrawingBoard chunks ($IMAGE)"
