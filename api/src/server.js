require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDb, query, getOne } = require('./db');
const { runMigrations } = require('./runMigrations');
const authService = require('./authService');
const {
  earnPoints,
  getBalance,
  getRateForTier,
  lockWithdrawPoints,
  refundWithdrawPoints,
  validateWithdrawAmount,
  syncUserTier,
} = require('./pointService');

const app = express();
app.use(cors());
app.use(express.json());

function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: 'UNAUTHORIZED' });
  }
  authService.findUserByToken(token).then((user) => {
    if (!user) {
      return res.status(401).json({ error: 'UNAUTHORIZED' });
    }
    req.user = user;
    req.token = token;
    next();
  });
}

function adminMiddleware(req, res, next) {
  const key = req.headers['x-admin-key'];
  if (!key || key !== process.env.ADMIN_API_KEY) {
    return res.status(403).json({ error: 'FORBIDDEN' });
  }
  next();
}

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'lotaya-shwe-oh-api' });
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'VALIDATION_ERROR' });
    }
    const user = await authService.register({ name, email, password, phone });
    const tokenRow = await getOne(`SELECT api_token FROM users WHERE id = ?`, [
      user.id,
    ]);
    res.status(201).json({ user, token: tokenRow.api_token });
  } catch (e) {
    if (e.message === 'EMAIL_EXISTS') {
      return res.status(409).json({ error: e.message });
    }
    res.status(500).json({ error: 'SERVER_ERROR' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'VALIDATION_ERROR' });
    }
    const user = await authService.login({ email, password });
    const tokenRow = await getOne(`SELECT api_token FROM users WHERE id = ?`, [
      user.id,
    ]);
    res.json({ user, token: tokenRow.api_token });
  } catch (e) {
    if (e.message === 'INVALID_CREDENTIALS') {
      return res.status(401).json({ error: e.message });
    }
    res.status(500).json({ error: 'SERVER_ERROR' });
  }
});

app.get('/api/auth/me', authMiddleware, async (req, res) => {
  res.json({ user: req.user, token: req.token });
});

app.get('/api/points/balance', authMiddleware, async (req, res) => {
  const balance = await getBalance(req.user.id);
  const tier = await syncUserTier(req.user.id);
  res.json({
    balance,
    tier,
    rate: getRateForTier(tier),
    public_id: req.user.public_id,
  });
});

app.get('/api/points/history', authMiddleware, async (req, res) => {
  const rows = await query(
    `SELECT id, amount, type, reference_id, balance_after, created_at
     FROM point_transactions
     WHERE user_id = ?
     ORDER BY id DESC
     LIMIT 50`,
    [req.user.id],
  );
  res.json({ history: rows });
});

app.post('/api/points/earn', authMiddleware, async (req, res) => {
  try {
    const { action, idempotent_key: idempotentKey } = req.body;
    const result = await earnPoints(req.user.id, action, idempotentKey);
    res.json({
      balance: result.balance,
      earned: result.duplicate ? 0 : undefined,
      duplicate: result.duplicate,
    });
  } catch (e) {
    const map = {
      INVALID_ACTION: 400,
      ALREADY_CLAIMED_TODAY: 409,
    };
    res.status(map[e.message] || 500).json({ error: e.message || 'SERVER_ERROR' });
  }
});

app.post('/api/withdraw/request', async (req, res) => {
  try {
    const {
      public_id: publicId,
      name,
      email,
      points,
      payment_method: paymentMethod,
      payment_phone: paymentPhone,
    } = req.body;

    if (!publicId || !email || !points || !paymentMethod || !paymentPhone) {
      return res.status(400).json({ error: 'VALIDATION_ERROR' });
    }

    validateWithdrawAmount(Number(points));

    const user = await authService.findUserByPublicId(publicId);
    if (!user) {
      return res.status(404).json({ error: 'USER_NOT_FOUND' });
    }

    const balance = await getBalance(user.id);
    if (balance < points) {
      return res.status(400).json({ error: 'INSUFFICIENT_POINTS' });
    }

    const tier = await syncUserTier(user.id);
    const rate = getRateForTier(tier);
    const mmkAmount = points * rate;

    const insert = await query(
      `INSERT INTO withdraw_requests
       (user_id, points, mmk_amount, rate, payment_method, payment_phone, email, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')`,
      [
        user.id,
        points,
        mmkAmount,
        rate,
        paymentMethod,
        paymentPhone,
        email.toLowerCase(),
      ],
    );

    await lockWithdrawPoints(user.id, Number(points), insert.insertId);

    res.status(201).json({
      request_id: insert.insertId,
      status: 'pending',
      points,
      mmk_amount: mmkAmount,
      rate,
      message: 'Withdraw request submitted. Points locked.',
    });
  } catch (e) {
    const map = {
      BELOW_MINIMUM: 400,
      INVALID_STEP: 400,
      INSUFFICIENT_POINTS: 400,
    };
    res.status(map[e.message] || 500).json({ error: e.message || 'SERVER_ERROR' });
  }
});

app.get('/api/withdraw/status', async (req, res) => {
  const email = (req.query.email || '').toLowerCase();
  if (!email) {
    return res.status(400).json({ error: 'VALIDATION_ERROR' });
  }
  const rows = await query(
    `SELECT id, points, mmk_amount, rate, payment_method, status, created_at, updated_at
     FROM withdraw_requests
     WHERE email = ?
     ORDER BY id DESC
     LIMIT 20`,
    [email],
  );
  res.json({ requests: rows });
});

app.get('/api/admin/withdraws', adminMiddleware, async (req, res) => {
  const status = req.query.status || 'pending';
  const rows = await query(
    `SELECT w.*, u.public_id, u.name AS user_name, u.tier
     FROM withdraw_requests w
     JOIN users u ON u.id = w.user_id
     WHERE w.status = ?
     ORDER BY w.id ASC
     LIMIT 100`,
    [status],
  );
  res.json({ requests: rows });
});

app.post('/api/admin/withdraws/:id/approve', adminMiddleware, async (req, res) => {
  const id = Number(req.params.id);
  const row = await getOne(`SELECT * FROM withdraw_requests WHERE id = ?`, [id]);
  if (!row) return res.status(404).json({ error: 'NOT_FOUND' });
  if (row.status !== 'pending') {
    return res.status(409).json({ error: 'ALREADY_PROCESSED' });
  }
  await query(`UPDATE withdraw_requests SET status = 'approved' WHERE id = ?`, [id]);
  res.json({ ok: true, status: 'approved' });
});

app.post('/api/admin/withdraws/:id/reject', adminMiddleware, async (req, res) => {
  const id = Number(req.params.id);
  const row = await getOne(`SELECT * FROM withdraw_requests WHERE id = ?`, [id]);
  if (!row) return res.status(404).json({ error: 'NOT_FOUND' });
  if (row.status !== 'pending') {
    return res.status(409).json({ error: 'ALREADY_PROCESSED' });
  }
  await refundWithdrawPoints(row.user_id, row.points, id);
  await query(`UPDATE withdraw_requests SET status = 'rejected' WHERE id = ?`, [id]);
  res.json({ ok: true, status: 'rejected' });
});

async function start() {
  await initDb();
  await runMigrations();
  const port = Number(process.env.PORT || 8000);
  app.listen(port, () => {
    console.log(`Lotaya Shwe Oh API running on port ${port}`);
  });
}

start().catch((err) => {
  console.error(err);
  process.exit(1);
});
