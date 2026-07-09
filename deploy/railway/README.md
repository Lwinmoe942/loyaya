# Railway Deploy — Lotaya Shwe Oh (အဆင့်လိုက်)

**Production target:** Z.com (မမေ့ပါနဲ့)  
**Railway:** Test / staging — MySQL + Laravel တစ်နေရာတည်း

---

## လိုအပ်ချက်

- [GitHub](https://github.com) account + `loyaya` repo push လုပ်ထားပြီး
- [Railway](https://railway.com) account (trial: 30 days / $5)
- `APP_KEY` — local မှာ generate:
  ```powershell
  cd D:\LOYAYA\api-laravel
  php artisan key:generate --show
  ```
- `ADMIN_API_KEY` — random string (admin login အတွက်):
  ```powershell
  php -r "echo bin2hex(random_bytes(32));"
  ```

---

## အဆင့် ၁ — GitHub သို့ push

Local changes အားလုံး GitHub မှာ ရှိရပါမယ်။

```powershell
cd D:\LOYAYA
git add .
git commit -m "Prepare Railway deploy"
git push origin main
```

---

## အဆင့် ၂ — Railway Project ဖွင့်ပါ

1. https://railway.com → Login
2. **New Project** နှိပ်ပါ
3. **Deploy from GitHub repo** ရွေးပါ
4. `loyaya` (သို့မဟုတ် သင့် repo name) ရွေးပါ
5. Project ဖန်တီးပါ

---

## အဆင့် ၃ — MySQL Database ထည့်ပါ

1. Project dashboard → **+ New** နှိပ်ပါ
2. **Database** → **MySQL** (သို့မဟုတ် **Add MySQL**)
3. MySQL service **Running** ဖြစ်တဲ့အထိ စောင့်ပါ

MySQL service → **Variables** tab မှာ ဒီ values တွေ ရမယ်:
- `MYSQLHOST`
- `MYSQLPORT`
- `MYSQLUSER`
- `MYSQLPASSWORD`
- `MYSQLDATABASE`

---

## အဆင့် ၄ — Laravel API Service ထည့်ပါ

Repo ကနေ service တစ်ခု ထပ်ထည့်ပါ (MySQL မဟုတ်):

1. **+ New** → **GitHub Repo** → same `loyaya` repo
2. Service settings → **Source**:
   - **Root Directory:** `api-laravel`
   - **Builder:** Dockerfile (`api-laravel/Dockerfile` သုံးမယ်)
3. **Settings** → **Deploy** → Save

---

## အဆင့် ၅ — Environment Variables ထည့်ပါ

Laravel service → **Variables** tab:

### A) MySQL ချိတ်ဆက်မှု

Railway variable reference သုံးပါ (MySQL service name က `MySQL` ဆိုရင်):

| Key | Value |
|-----|-------|
| `DB_CONNECTION` | `mysql` |
| `DB_HOST` | `${{MySQL.MYSQLHOST}}` |
| `DB_PORT` | `${{MySQL.MYSQLPORT}}` |
| `DB_DATABASE` | `${{MySQL.MYSQLDATABASE}}` |
| `DB_USERNAME` | `${{MySQL.MYSQLUSER}}` |
| `DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |

> MySQL service name မတူရင်: MySQL service → Variables → **Reference** ကို Laravel service မှာ paste လုပ်ပါ။

`MYSQL_ATTR_SSL_CA` **မထည့်ပါနဲ့** — Railway internal MySQL မှာ မလို။

### B) Laravel app settings

| Key | Value |
|-----|-------|
| `APP_ENV` | `production` |
| `APP_DEBUG` | `false` |
| `APP_KEY` | `base64:...` (အဆင့် ၁ က generate) |
| `ADMIN_API_KEY` | your random admin key |
| `APP_URL` | `https://YOUR-RAILWAY-URL.up.railway.app` (အဆင့် ၆ မှာ domain ရပြီးမှ update) |
| `EXCHANGE_URL` | `https://YOUR-RAILWAY-URL.up.railway.app/exchange` |
| `SESSION_DRIVER` | `database` |
| `CACHE_STORE` | `database` |
| `LOG_CHANNEL` | `stderr` |

### C) Business rules (optional — defaults OK)

```
RATE_BRONZE=3
RATE_SILVER=3
RATE_GOLD=3
RATE_FIRE=4
RATE_DIAMOND=4
MIN_WITHDRAW_POINTS=500
WITHDRAW_STEP=500
```

---

## အဆင့် ၆ — Public Domain ရယူပါ

1. Laravel service → **Settings** → **Networking**
2. **Generate Domain** နှိပ်ပါ
3. URL ရမယ် — ဥပမာ:  
   `https://lotaya-shwe-oh-production.up.railway.app`
4. **Variables** ပြန် သွားပြီး update လုပ်ပါ:
   - `APP_URL` = ထို URL
   - `EXCHANGE_URL` = `{URL}/exchange`
5. Service **Redeploy** လုပ်ပါ (Variables save ပြီး auto redeploy ဖြစ်နိုင်တယ်)

---

## အဆင့် ၇ — Deploy စောင့်ပြီး Test လုပ်ပါ

**Deployments** tab → status **Success** ဖြစ်ရမယ်။

Browser မှာ စစ်ပါ:

| Test | URL |
|------|-----|
| Health | `https://YOUR-URL.up.railway.app/health` |
| Exchange | `https://YOUR-URL.up.railway.app/exchange` |
| Admin | `https://YOUR-URL.up.railway.app/admin` |

Health မှာ:`{"ok":true,"service":"lotaya-shwe-oh-api"}`

> Migration က container start မှာ `docker-entrypoint.sh` က auto run လုပ်ပါတယ်။

---

## အဆင့် ၈ — Flutter App (ဖုန်း public)

```powershell
cd D:\LOYAYA
flutter run `
  --dart-define=API_URL=https://YOUR-URL.up.railway.app `
  --dart-define=EXCHANGE_URL=https://YOUR-URL.up.railway.app/exchange
```

သို့မဟုတ် domain ထည့်ပြီး script သုံးပါ:

```powershell
.\scripts\run-phone-railway.ps1 -ApiUrl "https://YOUR-URL.up.railway.app"
```

APK build:

```powershell
.\scripts\build-apk-railway.ps1 -ApiUrl "https://YOUR-URL.up.railway.app"
```

---

## အဆင့် ၉ — End-to-end test

1. App → Register / Login
2. Daily check-in → points ရမလား
3. Math quiz → +2 points
4. Copy Public ID
5. Exchange website → withdraw request
6. Admin → approve / reject
7. Points lock / refund မှန်မမှန်

---

## Troubleshooting

| ပြဿနာ | ဖြေရှင်းနည်း |
|--------|-------------|
| Deploy failed | **Deployments** → View logs |
| 500 / DB error | `DB_*` variables မှန်မမှန်၊ MySQL reference စစ် |
| Health timeout | Deploy ပြီးမှ ၁–၂ မိနစ် စောင့်ပါ |
| APP_KEY error | `APP_KEY` ထည့်ပြီး redeploy |
| Migration error | Logs မှာ SQL error ကြည့်၊ MySQL Running ဖြစ်ရမယ် |

---

## ကုန်ကျစရိတ်

- Trial: **$5 / 30 days**
- Trial ကုန်ရင် usage ပေါ် မူတည် charge
- Production အတွက် **Z.com** သို့ migrate (`deploy/zcom/README.md`)

---

## Z.com သို့ ပြောင်းတဲ့အခါ

1. Z.com server deploy
2. Flutter `API_URL` + `EXCHANGE_URL` ပဲ ပြောင်း
3. Railway service ရပ်ပါ (optional)

**Code rewrite မလို။**
