# Fly.io deploy helper (run from repo root after fly auth login)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\api-laravel"

Write-Host "Deploying to Fly.io (lotaya-shwe-oh)..." -ForegroundColor Cyan
fly deploy

Write-Host ""
Write-Host "App URL: https://lotaya-shwe-oh.fly.dev" -ForegroundColor Green
Write-Host "Health:  https://lotaya-shwe-oh.fly.dev/health" -ForegroundColor Green
Write-Host "Exchange: https://lotaya-shwe-oh.fly.dev/exchange" -ForegroundColor Green
