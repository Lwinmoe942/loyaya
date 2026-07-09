# Run Flutter app on a PHYSICAL PHONE using the PUBLIC Render API.
# Works on mobile data or any Wi-Fi — no same-network setup needed.
#
# Usage (PowerShell):
#   cd D:\LOYAYA
#   .\scripts\run-phone-public.ps1

$apiUrl = "https://lotaya-shwe-oh.onrender.com"
$exchangeUrl = "$apiUrl/exchange"

Write-Host "Waking up Render server (first request may take ~60s)..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "$apiUrl/health" -UseBasicParsing -TimeoutSec 120 | Out-Null
    Write-Host "Server is ready." -ForegroundColor Green
} catch {
    Write-Host "Server slow or waking up — app will retry automatically." -ForegroundColor Yellow
}

Write-Host "Starting Flutter on connected phone..." -ForegroundColor Cyan
flutter run `
  --dart-define=API_URL=$apiUrl `
  --dart-define=EXCHANGE_URL=$exchangeUrl
