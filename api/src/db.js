const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { DatabaseSync } = require('node:sqlite');

let mode = 'sqlite';
let sqlite = null;
let pool = null;

function useMysql() {
  return Boolean(process.env.DB_HOST);
}

async function initDb() {
  if (useMysql()) {
    mode = 'mysql';
    pool = mysql.createPool({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT || 3306),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
    });
    return;
  }

  mode = 'sqlite';
  const dataDir = path.join(__dirname, '..', 'data');
  fs.mkdirSync(dataDir, { recursive: true });
  const dbPath =
    process.env.SQLITE_PATH || path.join(dataDir, 'lotaya.sqlite');
  sqlite = new DatabaseSync(dbPath);
}

async function query(sql, params = []) {
  if (mode === 'mysql') {
    const [rows] = await pool.query(sql, params);
    return rows;
  }

  const stmt = sqlite.prepare(sql);
  const isSelect = sql.trim().toUpperCase().startsWith('SELECT');
  if (isSelect) {
    return stmt.all(...params);
  }
  const result = stmt.run(...params);
  return { insertId: Number(result.lastInsertRowid), changes: result.changes };
}

async function getOne(sql, params = []) {
  const rows = await query(sql, params);
  return Array.isArray(rows) ? rows[0] : null;
}

module.exports = { initDb, query, getOne, useMysql };
