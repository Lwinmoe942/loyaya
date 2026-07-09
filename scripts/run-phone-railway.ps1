param(
    [Parameter(Mandatory = $true)]
    [string]$ApiUrl
)

$ApiUrl = $ApiUrl.TrimEnd('/')
$exchangeUrl = "$ApiUrl/exchange"

Write-Host "Railway API: $ApiUrl" -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri "$ApiUrl/health" -UseBasicParsing -TimeoutSec 30 | Out-Null
    Write-Host "API is ready." -ForegroundColor Green
} catch {
    Write-Host "API not ready yet — check Railway deploy logs." -ForegroundColor Yellow
}

flutter run `
  --dart-define=API_URL=$ApiUrl `
  --dart-define=EXCHANGE_URL=$exchangeUrl
