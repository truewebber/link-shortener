#!/bin/bash

# Add Flutter to PATH
export PATH=$PATH:~/.flutter/bin

# Print Flutter version
echo "Flutter version:"
flutter --version

# Clean the project
flutter clean

# Get dependencies
flutter pub get

source .env

echo "Запуск Flutter с параметрами:"
echo "  API_BASE_URL: $API_BASE_URL"
echo "  GOOGLE_CAPTCHA_SITE_KEY: $GOOGLE_CAPTCHA_SITE_KEY"
echo "  ENVIRONMENT: $ENVIRONMENT"

# Запуск Flutter с параметрами компиляции
flutter run -d chrome \
  --web-browser-flag "--disable-web-security" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=GOOGLE_CAPTCHA_SITE_KEY="$GOOGLE_CAPTCHA_SITE_KEY" \
  --dart-define=ENVIRONMENT="$ENVIRONMENT"
