# Lotaya Shwe Oh — Deploy

**Production: Z.com Private Hosting** → see [`deploy/zcom/README.md`](../deploy/zcom/README.md)

**Temporary test: Render** → see [`DEPLOY-RENDER.md`](DEPLOY-RENDER.md)

---

## One Laravel app = everything

| Path | Purpose |
|------|---------|
| `/health` | Health check |
| `/api/*` | Flutter mobile API |
| `/exchange` | Public point exchange form |
| `/exchange/status` | Withdraw status |
| `/admin` | Admin panel |

Flutter only needs `API_URL` + `EXCHANGE_URL` when switching hosts.

---

## Local development (Laragon)

```cmd
d:
cd \LOYAYA\api-laravel
php artisan serve
```

Flutter emulator:

```bash
flutter run \
  --dart-define=API_URL=http://10.0.2.2:8000 \
  --dart-define=EXCHANGE_URL=http://10.0.2.2:8000/exchange
```

---

## API endpoints

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/points/balance`
- `GET /api/points/history`
- `POST /api/points/earn`
- `POST /api/withdraw/request`
- `GET /api/withdraw/status?email=`
- `GET /api/admin/withdraws` (`X-Admin-Key`)
- `POST /api/admin/withdraws/{id}/approve`
- `POST /api/admin/withdraws/{id}/reject`
