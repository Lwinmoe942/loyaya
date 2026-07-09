# Render — Temporary Testing Only

> **Production is Z.com Private Hosting.** See [`deploy/zcom/README.md`](../deploy/zcom/README.md).

Render free tier limitations:
- Web service sleeps after 15 min inactivity
- No managed MySQL — must use external DB (Aiven)
- Aiven free MySQL **powers off** when idle

Use Render only to test Flutter ↔ API before Z.com server is ready.

---

## Setup

1. Push repo to GitHub (`render.yaml` at root, `api-laravel/` folder)
2. Render → **Blueprint** → connect repo
3. Aiven MySQL → **Power on** → copy connection info

### Environment variables

| Variable | Value |
|----------|-------|
| `APP_KEY` | `php artisan key:generate --show` |
| `APP_URL` | `https://YOUR-SERVICE.onrender.com` |
| `EXCHANGE_URL` | `https://YOUR-SERVICE.onrender.com/exchange` |
| `DB_HOST` | Aiven hostname only (no comma, no `Host:` prefix) |
| `DB_PORT` | Aiven port (e.g. `12046`, **not** 3306) |
| `DB_DATABASE` | `defaultdb` |
| `DB_USERNAME` | `avnadmin` |
| `DB_PASSWORD` | from Aiven |
| `MYSQL_ATTR_SSL_CA` | `/etc/ssl/certs/ca-certificates.crt` |
| `ADMIN_API_KEY` | save the generated value |

### Verify hostname before deploy

```cmd
nslookup mysql-XXXX.h.aivencloud.com
```

Must return an IP. `Non-existent domain` = Aiven powered off or wrong host.

### Flutter test build

```bash
flutter run \
  --dart-define=API_URL=https://YOUR-SERVICE.onrender.com \
  --dart-define=EXCHANGE_URL=https://YOUR-SERVICE.onrender.com/exchange
```

---

## When Z.com is ready

1. Deploy on Z.com per `deploy/zcom/README.md`
2. Update Flutter URLs
3. Stop Render + Aiven services

No code changes.
