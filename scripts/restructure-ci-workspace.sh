#!/bin/sh
# Restructure CI workspace to match local: workspace = { beaver-iot-web/, beaver-iot-docker/ }.
# Run from workspace root (beaver-iot-docker repo after checkout).
# Moves all repo content into beaver-iot-docker/ so we can clone beaver-iot-web as sibling.

set -e
if [ -d beaver-iot-docker ] && [ -f beaver-iot-docker/build-docker/docker-compose.yaml ]; then
  echo "Already restructured (beaver-iot-docker/ exists)"
  exit 0
fi
mkdir -p _b2d
for x in $(ls -A); do
  [ "$x" = _b2d ] && continue
  mv "$x" _b2d/
done
mv _b2d beaver-iot-docker
echo "Restructured: workspace = { beaver-iot-docker/ } (match local layout)"
