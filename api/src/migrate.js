const { query } = require('./db');

async function migrate() {
  await query(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      public_id TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      phone TEXT,
      tier TEXT NOT NULL DEFAULT 'bronze',
      api_token TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS point_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      amount INTEGER NOT NULL,
      type TEXT NOT NULL,
      reference_id TEXT,
      balance_after INTEGER NOT NULL,
      idempotent_key TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(idempotent_key)
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS withdraw_requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      points INTEGER NOT NULL,
      mmk_amount INTEGER NOT NULL,
      rate INTEGER NOT NULL,
      payment_method TEXT NOT NULL,
      payment_phone TEXT NOT NULL,
      email TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `);

  console.log('Migrations complete.');
}

module.exports = { migrate };
