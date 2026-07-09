# Build release APK for Play Store / sharing — uses PUBLIC Render API.
# Usage: .\scripts\build-apk-public.ps1

$apiUrl = "https://lotaya-shwe-oh.onrender.com"
$exchangeUrl = "$apiUrl/exchange"

flutter build apk `
  --dart-define=API_URL=$apiUrl `
  --dart-define=EXCHANGE_URL=$exchangeUrl

Write-Host ""
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
