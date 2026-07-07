# Lotaya Shwe Oh API

Points ledger + withdraw API for the Flutter app and exchange website.

## Quick start (local)

```bash
cd api
copy .env.example .env
npm install
npm start
```

API: `http://localhost:8000`  
Health: `GET /health`

## Endpoints

| Method | Path | Auth |
|--------|------|------|
| POST | `/api/auth/register` | — |
| POST | `/api/auth/login` | — |
| GET | `/api/auth/me` | Bearer |
| GET | `/api/points/balance` | Bearer |
| GET | `/api/points/history` | Bearer |
| POST | `/api/points/earn` | Bearer |
| POST | `/api/withdraw/request` | — (public_id) |
| GET | `/api/withdraw/status?email=` | — |
| GET | `/api/admin/withdraws?status=pending` | X-Admin-Key |
| POST | `/api/admin/withdraws/:id/approve` | X-Admin-Key |
| POST | `/api/admin/withdraws/:id/reject` | X-Admin-Key |

## Render deploy

1. Push `api/` to GitHub
2. [render.com](https://render.com) → New → Blueprint → connect repo
3. Add Aiven MySQL env vars: `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
4. Set `ADMIN_API_KEY` in Render dashboard

## Flutter

Set API URL in `lib/config/api_config.dart`.

## Z.com migration later

Same REST endpoints — copy logic to Laravel; only hosting changes.
