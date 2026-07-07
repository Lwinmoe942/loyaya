# Lotaya Shwe Oh — Deploy Guide

One Laravel app = **API + Exchange website + Admin panel**.

Flutter app only needs `API_URL` to switch hosts. No app rewrite when moving Render → Z.com.

---

## What runs where

| URL path | Purpose |
|----------|---------|
| `/health` | Render health check |
| `/api/*` | Flutter app API (same as Node API) |
| `/exchange` | Public point withdraw form |
| `/exchange/status` | Withdraw status check |
| `/admin` | Admin login + approve/reject |

---

## Phase A — Render (start here)

### 1. MySQL database

Render has no free MySQL. Use one of:

- [Aiven](https://aiven.io) free MySQL
- PlanetScale (if available)
- Any external MySQL 8+

Create database `lotaya`.

### 2. Push to GitHub

Repo root must include `render.yaml` and `api-laravel/`.

### 3. Render deploy

1. [render.com](https://render.com) → **New** → **Blueprint**
2. Connect GitHub repo
3. Set env vars in dashboard:

| Variable | Example |
|----------|---------|
| `APP_URL` | `https://lotaya-shwe-oh.onrender.com` |
| `EXCHANGE_URL` | `https://lotaya-shwe-oh.onrender.com/exchange` |
| `DB_HOST` | Aiven host |
| `DB_DATABASE` | `lotaya` |
| `DB_USERNAME` | ... |
| `DB_PASSWORD` | ... |
| `ADMIN_API_KEY` | auto-generated (save it!) |

4. Deploy. Migrations run automatically on container start.

### 4. Flutter app (production test)

```bash
flutter run --dart-define=API_URL=https://lotaya-shwe-oh.onrender.com
```

Release build:

```bash
flutter build apk --dart-define=API_URL=https://lotaya-shwe-oh.onrender.com
```

### 5. Share exchange link externally

`https://lotaya-shwe-oh.onrender.com/exchange`

Admin: `https://lotaya-shwe-oh.onrender.com/admin`

---

## Phase B — Z.com migration (later)

**Same code. Only hosting + URLs change.**

### Checklist

1. Buy Z.com Private Hosting (Ubuntu + aaPanel)
2. Install: PHP 8.2+, Composer, MariaDB/MySQL, Nginx
3. Upload `api-laravel/` (or git clone)
4. Copy `.env` from Render, update:

```env
APP_URL=https://api.yourdomain.com
EXCHANGE_URL=https://exchange.yourdomain.com
DB_HOST=127.0.0.1
DB_DATABASE=lotaya
DB_USERNAME=...
DB_PASSWORD=...
ADMIN_API_KEY=<same key as before>
```

5. Run on server:

```bash
composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
```

6. Nginx point to `public/` (standard Laravel)
7. SSL via Let's Encrypt (aaPanel)
8. Update Flutter:

```bash
flutter build apk --dart-define=API_URL=https://api.yourdomain.com
```

9. Stop Render service (optional)

### Optional: split domains on Z.com

| Domain | Points to |
|--------|-----------|
| `api.yourdomain.com` | Laravel `public/` |
| `exchange.yourdomain.com` | same app (or redirect to `/exchange`) |
| `admin.yourdomain.com` | same app `/admin` |

Same codebase — Nginx server blocks can all use one Laravel `public/` folder.

---

## Local development (Laragon)

```cmd
d:
cd \LOYAYA\api-laravel
php artisan serve
```

- API: `http://127.0.0.1:8000/api/...`
- Exchange: `http://127.0.0.1:8000/exchange`
- Admin: `http://127.0.0.1:8000/admin`

Flutter emulator:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000
```

---

## API compatibility (Flutter + Node parity)

All endpoints match the Node API in `api/`:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/points/balance`
- `GET /api/points/history`
- `POST /api/points/earn`
- `POST /api/withdraw/request`
- `GET /api/withdraw/status?email=`
- `GET /api/admin/withdraws` (header `X-Admin-Key`)
- `POST /api/admin/withdraws/{id}/approve`
- `POST /api/admin/withdraws/{id}/reject`

---

## What you change when switching hosts

| Item | Change? |
|------|---------|
| Flutter `API_URL` | Yes (one line) |
| `.env` on server | Yes |
| Laravel code | No |
| Database dump/import | Yes (migrate data once) |
| Play Store app logic | No |
