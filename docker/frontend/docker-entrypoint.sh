#!/bin/sh
set -e

echo "starting server on port: $PORT";
envsubst '$PORT' < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
