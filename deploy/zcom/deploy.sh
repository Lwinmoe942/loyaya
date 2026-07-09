#!/bin/bash
# Lotaya Shwe Oh — Z.com production deploy script
# Run on server as the site user after git pull.

set -euo pipefail

APP_DIR="${APP_DIR:-/www/wwwroot/lotaya/api-laravel}"
PHP_BIN="${PHP_BIN:-php}"

cd "$APP_DIR"

echo "==> Composer install"
composer install --no-dev --optimize-autoloader --no-interaction

if [ ! -f .env ]; then
  echo "ERROR: .env missing. Copy deploy/zcom/env.production.example to .env and configure."
  exit 1
fi

echo "==> Migrate"
$PHP_BIN artisan migrate --force --no-interaction

echo "==> Cache config & routes"
$PHP_BIN artisan config:cache
$PHP_BIN artisan route:cache
$PHP_BIN artisan view:cache

echo "==> Permissions"
chmod -R ug+rwx storage bootstrap/cache

echo "==> Done. Test: curl -s https://api.yourdomain.com/health"
