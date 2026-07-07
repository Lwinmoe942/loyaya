const bcrypt = require('bcryptjs');
const { query, getOne } = require('./db');
const {
  generatePublicId,
  generateToken,
  getBalance,
  getRateForTier,
  syncUserTier,
} = require('./pointService');

async function register({ name, email, password, phone }) {
  const existing = await getOne(`SELECT id FROM users WHERE email = ?`, [
    email.toLowerCase(),
  ]);
  if (existing) {
    throw new Error('EMAIL_EXISTS');
  }

  const publicId = generatePublicId();
  const passwordHash = await bcrypt.hash(password, 10);
  const token = generateToken();

  const result = await query(
    `INSERT INTO users (public_id, name, email, password_hash, phone, api_token)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [publicId, name, email.toLowerCase(), passwordHash, phone || null, token],
  );

  const userId = result.insertId;
  return findUserById(userId);
}

async function login({ email, password }) {
  const user = await getOne(`SELECT * FROM users WHERE email = ?`, [
    email.toLowerCase(),
  ]);
  if (!user) {
    throw new Error('INVALID_CREDENTIALS');
  }

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) {
    throw new Error('INVALID_CREDENTIALS');
  }

  const token = generateToken();
  await query(`UPDATE users SET api_token = ? WHERE id = ?`, [token, user.id]);
  return findUserById(user.id);
}

async function findUserByToken(token) {
  if (!token) return null;
  const user = await getOne(`SELECT * FROM users WHERE api_token = ?`, [token]);
  if (!user) return null;
  return formatUser(user);
}

async function findUserById(id) {
  const user = await getOne(`SELECT * FROM users WHERE id = ?`, [id]);
  if (!user) return null;
  return formatUser(user);
}

async function findUserByPublicId(publicId) {
  const user = await getOne(`SELECT * FROM users WHERE public_id = ?`, [
    publicId,
  ]);
  if (!user) return null;
  return formatUser(user);
}

async function formatUser(user) {
  const balance = await getBalance(user.id);
  const tier = await syncUserTier(user.id);
  const rate = getRateForTier(tier);
  return {
    id: user.id,
    public_id: user.public_id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    tier,
    rate,
    balance,
    created_at: user.created_at,
  };
}

module.exports = {
  register,
  login,
  findUserByToken,
  findUserById,
  findUserByPublicId,
};
