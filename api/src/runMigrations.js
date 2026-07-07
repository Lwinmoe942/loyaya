const { migrate } = require('./migrate');
const { useMysql } = require('./db');

async function migrateMysql() {
  const { query } = require('./db');

  await query(`
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      public_id VARCHAR(20) NOT NULL UNIQUE,
      name VARCHAR(120) NOT NULL,
      email VARCHAR(190) NOT NULL UNIQUE,
      password_hash VARCHAR(255) NOT NULL,
      phone VARCHAR(30) NULL,
      tier VARCHAR(20) NOT NULL DEFAULT 'bronze',
      api_token VARCHAR(80) NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS point_transactions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      amount INT NOT NULL,
      type VARCHAR(50) NOT NULL,
      reference_id VARCHAR(80) NULL,
      balance_after INT NOT NULL,
      idempotent_key VARCHAR(120) NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uq_idempotent (idempotent_key),
      INDEX idx_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS withdraw_requests (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      points INT NOT NULL,
      mmk_amount INT NOT NULL,
      rate INT NOT NULL,
      payment_method VARCHAR(30) NOT NULL,
      payment_phone VARCHAR(30) NOT NULL,
      email VARCHAR(190) NOT NULL,
      status VARCHAR(20) NOT NULL DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_status (status),
      INDEX idx_email (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}

async function runMigrations() {
  if (useMysql()) {
    await migrateMysql();
  } else {
    await migrate();
  }
}

module.exports = { runMigrations };
