# Build Beaver IoT Web from *local* beaver-iot-web (no git clone).
# Build context MUST be workspace root (parent of beaver-iot-web and beaver-iot-docker).
# Example: docker build -f beaver-iot-docker/build-docker/beaver-iot-web-local.dockerfile -t milesight/beaver-iot-web:latest .

FROM node:20.18.0-alpine3.20 AS web-builder

WORKDIR /beaver-iot-web
COPY beaver-iot-web/ .

ENV CI=true
RUN npm install -g pnpm && \
    pnpm install && \
    echo "=== Starting build ===" && \
    pnpm build 2>&1 && \
    echo "=== Build finished, checking dist ===" && \
    ls -la /beaver-iot-web/apps/web/dist/ && \
    echo "=== Checking for assets ===" && \
    ls -la /beaver-iot-web/apps/web/dist/assets/ 2>&1 || echo "WARNING: assets directory not found"

FROM alpine:3.20 AS web
COPY --from=web-builder /beaver-iot-web/apps/web/dist /web

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
