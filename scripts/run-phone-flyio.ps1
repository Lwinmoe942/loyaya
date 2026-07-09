# Run Flutter on phone using Fly.io public API
# App URL: https://lotaya-shwe-oh.fly.dev

$apiUrl = "https://lotaya-shwe-oh.fly.dev"
$exchangeUrl = "$apiUrl/exchange"

Write-Host "Checking Fly.io API..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "$apiUrl/health" -UseBasicParsing -TimeoutSec 30 | Out-Null
    Write-Host "API is ready." -ForegroundColor Green
} catch {
    Write-Host "API not reachable yet — deploy first: see deploy/flyio/README.md" -ForegroundColor Yellow
}

flutter run `
  --dart-define=API_URL=$apiUrl `
  --dart-define=EXCHANGE_URL=$exchangeUrl
