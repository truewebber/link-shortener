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

# Run the web app
flutter run --debug -d chrome --web-browser-flag "--disable-web-security"
