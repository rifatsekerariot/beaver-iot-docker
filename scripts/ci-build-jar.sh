#!/bin/sh
# Clone beaver-iot-integrations, build ChirpStack JAR, copy to build-docker/integrations.
# Run from repo root (CI).

set -e
git clone --depth 1 -b main https://github.com/rifatsekerariot/beaver-iot-integrations.git /tmp/beaver-iot-integrations
docker run --rm \
  -v /tmp/beaver-iot-integrations:/workspace \
  -w /workspace \
  maven:3.8-eclipse-temurin-17-alpine \
  mvn clean package -DskipTests -pl integrations/chirpstack-integration -am -q
JAR=$(find /tmp/beaver-iot-integrations/integrations/chirpstack-integration/target -maxdepth 1 -name 'chirpstack-integration-*.jar' ! -name '*original*' 2>/dev/null | head -1)
if [ -z "$JAR" ] || [ ! -f "$JAR" ]; then
  echo "ERROR: ChirpStack JAR not found"
  exit 1
fi
mkdir -p build-docker/integrations
cp -f "$JAR" build-docker/integrations/
echo "JAR copied to build-docker/integrations"
