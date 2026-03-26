#!/bin/bash
echo "Building Flutter web app..."
flutter clean
flutter build web --release

echo "Adding version to service worker..."
TIMESTAMP=$(date +%s)
sed -i "s|flutter_service_worker\.js|flutter_service_worker.js?v=$TIMESTAMP|" build/web/index.html
sed -i "s|flutter_bootstrap\.js|flutter_bootstrap.js?v=$TIMESTAMP|" build/web/index.html

echo "Done."