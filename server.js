const express = require("express");
const path = require("path");
const fs = require("fs");
const Database = require("better-sqlite3");
const { initDb } = require("./db/init");
const createApiRouter = require("./routes");

const PORT = process.env.PORT || 3000;
const DB_PATH = path.join(__dirname, "data", "restaurant.db");

fs.mkdirSync(path.dirname(DB_PATH), { recursive: true });
const db = new Database(DB_PATH);
db.pragma("foreign_keys = ON");
initDb(db);

const app = express();
app.use(express.json());
app.use("/api", createApiRouter(db));
app.use(express.static(path.join(__dirname, "public")));

app.listen(PORT, () => {
  console.log(`Restaurant demo: http://localhost:${PORT}`);
  console.log(`SQLite database: ${DB_PATH}`);
});
