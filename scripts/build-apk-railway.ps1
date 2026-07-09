param(
    [Parameter(Mandatory = $true)]
    [string]$ApiUrl
)

$ApiUrl = $ApiUrl.TrimEnd('/')
$exchangeUrl = "$ApiUrl/exchange"

flutter build apk `
  --dart-define=API_URL=$ApiUrl `
  --dart-define=EXCHANGE_URL=$exchangeUrl

Write-Host ""
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
Write-Host "API_URL: $ApiUrl" -ForegroundColor Green
