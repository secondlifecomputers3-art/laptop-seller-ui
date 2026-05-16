#!/bin/bash
set -e  # exit on error

echo "Installing Flutter (if needed)..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$PWD/flutter/bin"

# Use the stable channel
flutter channel stable
flutter upgrade

echo "Building Flutter web app..."
flutter clean
flutter pub get
# Important: set base href to match your GitHub Pages subdirectory
flutter build web --release --base-href "/laptop-seller-ui/"

# Copy _headers if present (optional for GitHub Pages)
if [ -f "_headers" ]; then
  cp _headers build/web/
fi

echo "Adding version to service worker..."
TIMESTAMP=$(date +%s)
sed -i "s|flutter_service_worker\.js|flutter_service_worker.js?v=$TIMESTAMP|" build/web/index.html
sed -i "s|flutter_bootstrap\.js|flutter_bootstrap.js?v=$TIMESTAMP|" build/web/index.html

echo "Done."