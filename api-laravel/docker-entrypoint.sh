#!/bin/sh
set -e

PORT="${PORT:-8080}"

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

if [ -n "${DB_HOST:-}" ]; then
  DB_HOST="$(trim "$DB_HOST")"
  export DB_HOST

  case "$DB_HOST" in
    *[,:]*|Host*|host*)
      echo "ERROR: DB_HOST looks invalid. Paste hostname only, without 'Host:', comma, or port."
      echo "Current DB_HOST=${DB_HOST}"
      exit 1
      ;;
  esac
fi

if [ -n "${DB_PORT:-}" ]; then
  DB_PORT="$(trim "$DB_PORT")"
  export DB_PORT
fi

echo "Starting Lotaya API on port ${PORT}..."
echo "DB_HOST=${DB_HOST:-<not set>} DB_PORT=${DB_PORT:-3306} DB_DATABASE=${DB_DATABASE:-<not set>}"

if [ -z "${APP_KEY:-}" ]; then
  echo "ERROR: APP_KEY is not set. Generate one locally: php artisan key:generate --show"
  exit 1
fi

if [ -z "${DB_HOST:-}" ]; then
  echo "ERROR: DB_HOST is not set."
  exit 1
fi

# Start HTTP server first so Railway healthcheck can reach /health while migrations run.
php artisan serve --host=0.0.0.0 --port="${PORT}" &
SERVER_PID=$!

attempt=1
max_attempts=15
while [ "$attempt" -le "$max_attempts" ]; do
  if php artisan migrate --force --no-interaction; then
    echo "Migrations complete."
    break
  fi
  if [ "$attempt" -eq "$max_attempts" ]; then
    echo "ERROR: Database migration failed after ${max_attempts} attempts."
    kill "$SERVER_PID" 2>/dev/null || true
    exit 1
  fi
  echo "Database not ready, retry ${attempt}/${max_attempts}..."
  attempt=$((attempt + 1))
  sleep 4
done

wait "$SERVER_PID"
