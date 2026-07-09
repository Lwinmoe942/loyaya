# Z.com Private Hosting — Production Deploy (Lotaya Shwe Oh)

**This is the canonical production guide.** Render is optional for temporary testing only.

One Laravel app (`api-laravel/`) serves everything:

| URL | Purpose |
|-----|---------|
| `https://api.yourdomain.com/health` | Health check |
| `https://api.yourdomain.com/api/*` | Flutter mobile API |
| `https://api.yourdomain.com/exchange` | Public point exchange (withdraw form) |
| `https://api.yourdomain.com/exchange/status` | Withdraw status check |
| `https://api.yourdomain.com/admin` | Admin approve/reject panel |

---

## 1. Buy Z.com Private Hosting

Recommended: **Ubuntu 22.04** + **aaPanel** (or plain LEMP).

Install via aaPanel:
- **Nginx**
- **PHP 8.2+** (extensions: `pdo_mysql`, `mbstring`, `openssl`, `tokenizer`, `xml`, `ctype`, `json`, `bcmath`, `fileinfo`)
- **MySQL 8** or **MariaDB**
- **Composer**

---

## 2. Create MySQL database

```sql
CREATE DATABASE lotaya CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'lotaya_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD';
GRANT ALL PRIVILEGES ON lotaya.* TO 'lotaya_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## 3. Upload code

```bash
cd /www/wwwroot
git clone https://github.com/YOUR_USER/loyaya.git lotaya
cd lotaya/api-laravel
cp ../../deploy/zcom/env.production.example .env
nano .env   # fill APP_KEY, DB_*, ADMIN_API_KEY, APP_URL, EXCHANGE_URL
php artisan key:generate
```

Generate `ADMIN_API_KEY` (save it — needed for admin login):

```bash
php -r "echo bin2hex(random_bytes(32));"
```

---

## 4. First deploy

```bash
chmod +x ../../deploy/zcom/deploy.sh
APP_DIR=/www/wwwroot/lotaya/api-laravel ../../deploy/zcom/deploy.sh
```

---

## 5. Nginx

Copy `deploy/zcom/nginx.conf` to your aaPanel site config. Update:
- `server_name`
- `root` path
- `fastcgi_pass` (PHP version socket — check aaPanel PHP settings)
- SSL certificate paths (use aaPanel Let's Encrypt)

Reload Nginx after save.

---

## 6. Flutter app (production build)

```bash
flutter build apk \
  --dart-define=API_URL=https://api.yourdomain.com \
  --dart-define=EXCHANGE_URL=https://api.yourdomain.com/exchange
```

Upload APK to Play Store. **Only change these two URLs when switching hosts.**

---

## 7. Daily operations

### Admin workflow
1. Open `https://api.yourdomain.com/admin`
2. Login with `ADMIN_API_KEY`
3. Approve pending withdraws → send MMK via KBZ/Wave manually
4. Reject → points auto-refund to user

### Exchange link (share externally, not in Play Store listing as cash)
`https://api.yourdomain.com/exchange`

---

## 8. Updates (git pull)

```bash
cd /www/wwwroot/lotaya
git pull
APP_DIR=/www/wwwroot/lotaya/api-laravel ./deploy/zcom/deploy.sh
```

---

## 9. Optional: cron (Laravel scheduler)

```cron
* * * * * cd /www/wwwroot/lotaya/api-laravel && php artisan schedule:run >> /dev/null 2>&1
```

---

## Migration from Render (testing → production)

1. Deploy on Z.com (steps above)
2. Export data from test DB if needed (`mysqldump`)
3. Import into Z.com MySQL
4. Update Flutter `API_URL` + `EXCHANGE_URL`
5. Stop Render service

**No code changes required.**

---

## Appendix: Render (temporary test only)

See `api-laravel/DEPLOY-RENDER.md` — requires external MySQL (Aiven). Not for production.
