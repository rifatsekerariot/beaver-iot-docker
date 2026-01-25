# Build Beaver IoT Web from *local* beaver-iot-web (no git clone).
# Build context MUST be workspace root (parent of beaver-iot-web and beaver-iot-docker).
# Example: docker build -f beaver-iot-docker/build-docker/beaver-iot-web-local.dockerfile -t milesight/beaver-iot-web:latest .

FROM node:20.18.0-alpine3.20 AS web-builder

WORKDIR /beaver-iot-web
COPY beaver-iot-web/ .

ENV CI=true
RUN npm install -g pnpm && \
    pnpm install && \
    echo "=== Running build ===" && \
    pnpm build || { \
        echo "ERROR: Build failed"; \
        exit 1; \
    } && \
    echo "=== Build completed successfully ==="

# Debug: Verify build output exists and has correct structure
RUN echo "=== Checking build output ===" && \
    test -d /beaver-iot-web/apps/web/dist || { echo "ERROR: dist directory not found"; exit 1; } && \
    echo "✓ dist directory exists" && \
    ls -la /beaver-iot-web/apps/web/dist && \
    test -f /beaver-iot-web/apps/web/dist/index.html || { echo "ERROR: index.html not found in dist"; exit 1; } && \
    echo "✓ index.html exists" && \
    test -d /beaver-iot-web/apps/web/dist/assets || { echo "ERROR: assets directory not found in dist"; ls -la /beaver-iot-web/apps/web/dist; exit 1; } && \
    echo "✓ assets directory exists" && \
    test -d /beaver-iot-web/apps/web/dist/assets/js || { echo "ERROR: assets/js directory not found"; ls -la /beaver-iot-web/apps/web/dist/assets; exit 1; } && \
    echo "✓ assets/js directory exists" && \
    echo "=== Listing dist contents ===" && \
    find /beaver-iot-web/apps/web/dist -maxdepth 2 -type d && \
    echo "=== Listing assets/js (first 10) ===" && \
    ls /beaver-iot-web/apps/web/dist/assets/js | head -10

FROM alpine:3.20 AS web
COPY --from=web-builder /beaver-iot-web/apps/web/dist /web

# Debug: Verify copied structure
RUN echo "=== Verifying copied /web structure ===" && \
    test -d /web || { echo "ERROR: /web directory not found after copy"; exit 1; } && \
    test -f /web/index.html || { echo "ERROR: /web/index.html not found after copy"; exit 1; } && \
    echo "✓ /web directory and index.html exist" && \
    (test -d /web/assets && echo "✓ /web/assets exists" || echo "WARNING: /web/assets not found") && \
    (test -d /web/assets/js && echo "✓ /web/assets/js exists" || echo "WARNING: /web/assets/js not found") && \
    echo "=== /web directory structure ===" && \
    ls -la /web && \
    find /web -maxdepth 2 -type d | head -20
RUN apk add --no-cache envsubst nginx nginx-mod-http-headers-more
COPY beaver-iot-docker/build-docker/nginx/envsubst-on-templates.sh /envsubst-on-templates.sh
COPY beaver-iot-docker/build-docker/nginx/main.conf /etc/nginx/nginx.conf
COPY beaver-iot-docker/build-docker/nginx/templates /etc/nginx/templates

ENV BEAVER_IOT_API_HOST=172.17.0.1
ENV BEAVER_IOT_API_PORT=9200
ENV MQTT_BROKER_WS_PATH=/mqtt
ENV MQTT_BROKER_WS_PORT=""
ENV MQTT_BROKER_MOQUETTE_WEBSOCKET_PORT=8083

EXPOSE 80

RUN mkdir -p /run/nginx

COPY beaver-iot-docker/build-docker/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "/envsubst-on-templates.sh && nginx -g 'daemon off;'"]
