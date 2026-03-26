@echo off
echo Building Flutter web app...
flutter clean
flutter build web --release

echo Adding version to service worker...
for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do set TIMESTAMP=%%a%%b%%c%%d%%e
powershell -Command "(Get-Content build\web\index.html) -replace 'flutter_service_worker\.js', 'flutter_service_worker.js?v=%TIMESTAMP%' | Set-Content build\web\index.html"
powershell -Command "(Get-Content build\web\index.html) -replace 'flutter_bootstrap\.js', 'flutter_bootstrap.js?v=%TIMESTAMP%' | Set-Content build\web\index.html"

echo Done.