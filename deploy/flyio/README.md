# Fly.io Deploy — Lotaya Shwe Oh

**App URL (after deploy):** https://lotaya-shwe-oh.fly.dev

Singapore region (`sin`) — good latency for Myanmar users.  
**Always-on** — no Render-style cold start sleep.

Database: use **external MySQL** (Aiven) — same as Render. Fly has no managed MySQL.

---

## 1. Install Fly CLI (Windows)

PowerShell (admin):

```powershell
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

Close and reopen terminal, then:

```powershell
fly version
fly auth login
```

---

## 2. Deploy Laravel API

```powershell
cd D:\LOYAYA\api-laravel
fly launch --no-deploy --copy-config --name lotaya-shwe-oh --region sin
```

If app name `lotaya-shwe-oh` is taken, pick another name and update `fly.toml` + Flutter URL.

### Set secrets (Aiven MySQL — copy from Aiven dashboard)

```powershell
fly secrets set APP_KEY="base64:YOUR_KEY_FROM_php_artisan_key_generate_show"
fly secrets set APP_URL="https://lotaya-shwe-oh.fly.dev"
fly secrets set EXCHANGE_URL="https://lotaya-shwe-oh.fly.dev/exchange"
fly secrets set ADMIN_API_KEY="your-long-random-admin-key"
fly secrets set DB_CONNECTION="mysql"
fly secrets set DB_HOST="mysql-xxxx.h.aivencloud.com"
fly secrets set DB_PORT="12046"
fly secrets set DB_DATABASE="defaultdb"
fly secrets set DB_USERNAME="avnadmin"
fly secrets set DB_PASSWORD="your-aiven-password"
fly secrets set MYSQL_ATTR_SSL_CA="/etc/ssl/certs/ca-certificates.crt"
```

**Important:** Aiven must be **Running** (not Powered off). Hostname copy exactly from Aiven.

### Deploy

```powershell
fly deploy
```

### Check

```powershell
fly open /health
fly logs
```

Expected: `{"ok":true,"service":"lotaya-shwe-oh-api"}`

---

## 3. Flutter app (physical phone, public)

```powershell
cd D:\LOYAYA
.\scripts\run-phone-flyio.ps1
```

Or manually:

```powershell
flutter run `
  --dart-define=API_URL=https://lotaya-shwe-oh.fly.dev `
  --dart-define=EXCHANGE_URL=https://lotaya-shwe-oh.fly.dev/exchange
```

---

## URLs after deploy

| Service | URL |
|---------|-----|
| API health | https://lotaya-shwe-oh.fly.dev/health |
| Exchange | https://lotaya-shwe-oh.fly.dev/exchange |
| Admin | https://lotaya-shwe-oh.fly.dev/admin |
| API base | https://lotaya-shwe-oh.fly.dev/api |

---

## Fly.io dashboard

https://fly.io/apps/lotaya-shwe-oh

(Credit card required for Fly.io account — small free allowance may apply.)

---

## Production reminder

**Z.com Private Hosting** remains the production target.  
Fly.io is for testing only. When Z.com is ready, switch Flutter `API_URL` to your domain.

See `deploy/zcom/README.md`.
