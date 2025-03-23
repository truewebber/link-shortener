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

API_URL=${1:-"https://short.twb.one"}
ENV=${2:-"development"}

echo "Запуск Flutter с параметрами:"
echo "  API_BASE_URL: $API_URL"
echo "  ENVIRONMENT: $ENV"

# Запуск Flutter с параметрами компиляции
flutter run -d chrome \
  --dart-define=API_BASE_URL=$API_URL \
  --dart-define=ENVIRONMENT=$ENV
