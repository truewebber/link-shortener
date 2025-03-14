#!/bin/sh
set -e

envsubst < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
