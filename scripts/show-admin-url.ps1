# Show your private admin URL (set env vars on Railway first).
param(
    [string]$BaseUrl = "https://lotaya-shwe-oh-production-d73b.up.railway.app",
    [string]$AdminPath = "lso-private-change-me"
)

$path = $AdminPath.Trim().Trim('/')
$url = "$BaseUrl/$path"

Write-Host ""
Write-Host "Private Admin URL (bookmark this, not linked in the app):" -ForegroundColor Cyan
Write-Host $url -ForegroundColor Green
Write-Host ""
Write-Host "Railway Variables to set:" -ForegroundColor Yellow
Write-Host "  ADMIN_PANEL_PATH = $path"
Write-Host "  ADMIN_PASSWORD   = your-strong-personal-password"
Write-Host "  ADMIN_API_KEY    = separate-random-key-for-api"
Write-Host "  ADMIN_ALLOWED_IPS = optional, your-public-ip"
Write-Host ""
