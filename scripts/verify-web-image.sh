#!/bin/sh
# Verify web image has /web/index.html and /web/assets (CI).

set -e
docker run --rm milesight/beaver-iot-web:latest sh -c "test -f /web/index.html && test -d /web/assets"
echo "OK: web image has index.html and assets"
