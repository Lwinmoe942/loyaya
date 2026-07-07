const crypto = require('crypto');
const { query, getOne } = require('./db');

const TIER_THRESHOLDS = [
  { tier: 'diamond', min: 10000, rateKey: 'RATE_DIAMOND' },
  { tier: 'fire', min: 6000, rateKey: 'RATE_FIRE' },
  { tier: 'gold', min: 3000, rateKey: 'RATE_GOLD' },
  { tier: 'silver', min: 1000, rateKey: 'RATE_SILVER' },
  { tier: 'bronze', min: 0, rateKey: 'RATE_BRONZE' },
];

function generatePublicId() {
  const part = () => crypto.randomBytes(2).toString('hex').toUpperCase();
  return `LSO-${part()}-${part()}`;
}

function generateToken() {
  return crypto.randomBytes(32).toString('hex');
}

function getRateForTier(tier) {
  const key = `RATE_${tier.toUpperCase()}`;
  return Number(process.env[key] || process.env.RATE_BRONZE || 3);
}

async function getBalance(userId) {
  const row = await getOne(
    `SELECT COALESCE(SUM(amount), 0) AS balance
     FROM point_transactions WHERE user_id = ?`,
    [userId],
  );
  return Number(row?.balance || 0);
}

async function getLifetimePoints(userId) {
  const row = await getOne(
    `SELECT COALESCE(SUM(amount), 0) AS total
     FROM point_transactions
     WHERE user_id = ? AND amount > 0`,
    [userId],
  );
  return Number(row?.total || 0);
}

function resolveTier(lifetimePoints) {
  for (const item of TIER_THRESHOLDS) {
    if (lifetimePoints >= item.min) {
      return item.tier;
    }
  }
  return 'bronze';
}

async function syncUserTier(userId) {
  const lifetime = await getLifetimePoints(userId);
  const tier = resolveTier(lifetime);
  await query(`UPDATE users SET tier = ? WHERE id = ?`, [tier, userId]);
  return tier;
}

async function addTransaction(userId, amount, type, referenceId, idempotentKey) {
  if (idempotentKey) {
    const existing = await getOne(
      `SELECT id FROM point_transactions WHERE idempotent_key = ?`,
      [idempotentKey],
    );
    if (existing) {
      return { duplicate: true, balance: await getBalance(userId) };
    }
  }

  const balance = await getBalance(userId);
  const newBalance = balance + amount;
  if (newBalance < 0) {
    throw new Error('INSUFFICIENT_POINTS');
  }

  await query(
    `INSERT INTO point_transactions
     (user_id, amount, type, reference_id, balance_after, idempotent_key)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [userId, amount, type, referenceId || null, newBalance, idempotentKey || null],
  );

  await syncUserTier(userId);
  return { duplicate: false, balance: newBalance };
}

const EARN_RULES = {
  daily_checkin: { points: 10, daily: true },
  math_quiz: { points: 2, daily: false },
};

async function earnPoints(userId, action, idempotentKey) {
  const rule = EARN_RULES[action];
  if (!rule) {
    throw new Error('INVALID_ACTION');
  }

  let key = idempotentKey;
  if (rule.daily) {
    const today = new Date().toISOString().slice(0, 10);
    key = `earn_${action}_${userId}_${today}`;
  } else if (!key) {
    key = `earn_${action}_${userId}_${Date.now()}`;
  }

  const result = await addTransaction(userId, rule.points, `earn_${action}`, action, key);
  if (result.duplicate && rule.daily) {
    throw new Error('ALREADY_CLAIMED_TODAY');
  }
  return result;
}

async function lockWithdrawPoints(userId, points, withdrawId) {
  return addTransaction(
    userId,
    -points,
    'withdraw_lock',
    String(withdrawId),
    `withdraw_lock_${withdrawId}`,
  );
}

async function refundWithdrawPoints(userId, points, withdrawId) {
  return addTransaction(
    userId,
    points,
    'withdraw_refund',
    String(withdrawId),
    `withdraw_refund_${withdrawId}`,
  );
}

function validateWithdrawAmount(points) {
  const min = Number(process.env.MIN_WITHDRAW_POINTS || 500);
  const step = Number(process.env.WITHDRAW_STEP || 500);
  if (points < min) {
    throw new Error('BELOW_MINIMUM');
  }
  if (points % step !== 0) {
    throw new Error('INVALID_STEP');
  }
}

module.exports = {
  generatePublicId,
  generateToken,
  getBalance,
  getLifetimePoints,
  getRateForTier,
  syncUserTier,
  earnPoints,
  lockWithdrawPoints,
  refundWithdrawPoints,
  validateWithdrawAmount,
};
