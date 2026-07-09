# Lotaya Shwe Oh (LOYAYA)

Flutter rewards app + Laravel backend for point earning, external exchange, and admin payout.

**Production hosting: Z.com Private Hosting** — see [`deploy/zcom/README.md`](deploy/zcom/README.md)

Render is temporary testing only — see [`api-laravel/DEPLOY-RENDER.md`](api-laravel/DEPLOY-RENDER.md)

---

## Project structure

```
LOYAYA/
├── lib/                 # Flutter app (Play Store)
├── api-laravel/         # Production backend (API + exchange + admin)
├── deploy/zcom/         # Z.com production deploy
├── deploy/flyio/        # Fly.io test deploy
├── archive/             # Project snapshots / backups
├── scripts/             # Flutter run/build helpers
├── api/                 # Legacy Node API (reference only)
└── render.yaml          # Optional Render test deploy
```

---

## Business workflow

```
┌─────────────┐     earn points      ┌──────────────────┐
│ Flutter App │ ──────────────────►  │ Laravel API      │
│ (Play Store)│ ◄──────────────────  │ (Z.com server)   │
└─────────────┘     balance/history  └────────┬─────────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
            /exchange (web)           /admin (web)              MySQL local
            user withdraw form        approve/reject            always on
            public_id + payment         manual KBZ/Wave
```

1. User earns points in app (check-in, quiz, games later)
2. User copies **Public ID** from app
3. User opens **exchange website** (external) → submits withdraw
4. Server **locks points** automatically
5. Admin approves → manual MMK transfer via KBZ/Wave
6. Admin rejects → points **refunded** automatically

**Play Store policy:** No in-app cash/withdraw UI. Exchange marketed externally only.

---

## Local development

### Backend (Laragon)

```cmd
d:
cd \LOYAYA\api-laravel
php artisan serve
```

- API: `http://127.0.0.1:8000/api/...`
- Exchange: `http://127.0.0.1:8000/exchange`
- Admin: `http://127.0.0.1:8000/admin`

### Flutter

```bash
flutter pub get
flutter run \
  --dart-define=API_URL=http://10.0.2.2:8000 \
  --dart-define=EXCHANGE_URL=http://10.0.2.2:8000/exchange
```

---

## Production build (Z.com)

After Z.com deploy:

```bash
flutter build apk \
  --dart-define=API_URL=https://api.yourdomain.com \
  --dart-define=EXCHANGE_URL=https://api.yourdomain.com/exchange
```

**Only these two URLs change when switching hosts.**

---

## What to deploy on Z.com

One server runs everything:

| Component | Path |
|-----------|------|
| Laravel API | `api-laravel/public/` via Nginx |
| Exchange site | `/exchange` |
| Admin panel | `/admin` |
| MySQL | `127.0.0.1:3306` database `lotaya` |

Full guide: [`deploy/zcom/README.md`](deploy/zcom/README.md)

---

## Environment variables (server)

Copy [`deploy/zcom/env.production.example`](deploy/zcom/env.production.example) → `api-laravel/.env`

Key values:
- `APP_URL` — your API domain
- `EXCHANGE_URL` — exchange page URL
- `ADMIN_API_KEY` — admin login key
- `DB_*` — local MySQL on Z.com

---

## API endpoints

| Method | Path | Auth |
|--------|------|------|
| POST | `/api/auth/register` | — |
| POST | `/api/auth/login` | — |
| GET | `/api/auth/me` | Bearer |
| GET | `/api/points/balance` | Bearer |
| GET | `/api/points/history` | Bearer |
| POST | `/api/points/earn` | Bearer |
| POST | `/api/withdraw/request` | — |
| GET | `/api/withdraw/status` | — |
| GET | `/api/admin/withdraws` | X-Admin-Key |

---

## Tier rates (MMK per point)

| Tier | Min lifetime pts | Rate |
|------|------------------|------|
| Bronze | 0 | 3 |
| Silver | 1,000 | 3 |
| Gold | 3,000 | 3 |
| Fire | 6,000 | 4 |
| Diamond | 10,000 | 4 |

Min withdraw: 500 points, step 500.
