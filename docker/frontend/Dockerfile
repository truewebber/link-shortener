FROM ghcr.io/truewebber/flutter-docker-image:3.29.2 AS builder

WORKDIR /app

RUN flutter config --enable-web

COPY web/pubspec.yaml web/pubspec.lock ./
RUN flutter pub get

COPY web .

RUN flutter build web --release --base-href "/app/"

FROM nginx:alpine

ENV PORT=3000
ENV BACKEND_API_URL=/
ENV GOOGLE_CAPTCHA_SITE_KEY=''
ENV ENVIRONMENT=production

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY docker/frontend/server.conf /etc/nginx/conf.d/default.template
COPY docker/frontend/config.template.js /usr/share/nginx/html/config.template.js
COPY docker/frontend/docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache gettext && \
    chmod +x /docker-entrypoint.sh && \
    chmod g+rwx /var/cache/nginx /var/run /var/log/nginx

ENTRYPOINT ["/docker-entrypoint.sh"]
