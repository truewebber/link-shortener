#!/bin/sh
set -e

echo "starting server on port: $PORT";

# Process nginx config
envsubst '$PORT' < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf

# Process frontend config
envsubst '$BACKEND_API_URL,$ENVIRONMENT' < /usr/share/nginx/html/config.template.js > /usr/share/nginx/html/config.js

exec nginx -g "daemon off;"
