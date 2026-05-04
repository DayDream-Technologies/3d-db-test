const fs = require("fs");
const path = require("path");

function tableExists(db, name) {
  const row = db
    .prepare(
      "SELECT 1 AS ok FROM sqlite_master WHERE type = 'table' AND name = ?"
    )
    .get(name);
  return Boolean(row);
}

function runSqlFile(db, filename) {
  const full = path.join(__dirname, filename);
  const sql = fs.readFileSync(full, "utf8");
  db.exec(sql);
}

/**
 * First boot: apply schema + seed. To reset: delete data/restaurant.db and restart.
 */
function initDb(db) {
  if (tableExists(db, "locations")) {
    return;
  }
  runSqlFile(db, "schema.sql");
  runSqlFile(db, "seed.sql");
}

module.exports = { initDb };
