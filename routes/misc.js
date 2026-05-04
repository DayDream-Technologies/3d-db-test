const express = require("express");

module.exports = function miscRoutes(db) {
  const router = express.Router();

  router.get("/summary", (req, res) => {
    try {
      const today = new Date().toISOString().slice(0, 10);
      const openStatuses = db
        .prepare(
          `SELECT id FROM order_statuses WHERE code IN ('placed','preparing','ready','served')`
        )
        .all()
        .map((r) => r.id);
      const openOrders = db
        .prepare(
          `SELECT COUNT(*) AS n FROM orders WHERE order_status_id IN (${openStatuses
            .map(() => "?")
            .join(",")})`
        )
        .get(...openStatuses);

      const reservationsToday = db
        .prepare(
          `SELECT COUNT(*) AS n FROM reservations
           WHERE date(start_at) = date(?)
           AND reservation_status_id IN (
             SELECT id FROM reservation_statuses WHERE code IN ('requested','confirmed')
           )`
        )
        .get(today);

      const waitlistWaiting = db
        .prepare(
          `SELECT COUNT(*) AS n FROM waitlist w
           JOIN waitlist_statuses s ON s.id = w.waitlist_status_id
           WHERE s.code = 'waiting'`
        )
        .get();

      res.json({
        openOrders: openOrders.n,
        reservationsToday: reservationsToday.n,
        waitlistWaiting: waitlistWaiting.n,
        todayDate: today,
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to load summary" });
    }
  });

  router.get("/tables", (req, res) => {
    try {
      const rows = db
        .prepare(
          `SELECT t.id, t.name, t.capacity, t.is_active, l.name AS location_name
           FROM dining_tables t
           JOIN locations l ON l.id = t.location_id
           WHERE t.is_active = 1
           ORDER BY l.name, t.name`
        )
        .all();
      res.json({
        tables: rows.map((r) => ({
          id: r.id,
          name: r.name,
          capacity: r.capacity,
          locationName: r.location_name,
          isActive: Boolean(r.is_active),
        })),
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to load tables" });
    }
  });

  router.post("/customers", (req, res) => {
    try {
      const body = req.body || {};
      if (!body.name && !body.phone) {
        return res.status(400).json({ error: "name or phone is required" });
      }
      const r = db
        .prepare(`INSERT INTO customers (name, email, phone) VALUES (?, ?, ?)`)
        .run(body.name || "Guest", body.email || null, body.phone || null);
      res.status(201).json({
        id: r.lastInsertRowid,
        name: body.name || "Guest",
        email: body.email || null,
        phone: body.phone || null,
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to create customer" });
    }
  });

  router.get("/customers", (req, res) => {
    try {
      const q = (req.query.q || "").trim();
      if (q.length < 1) {
        return res.json({ customers: [] });
      }
      const like = `%${q.replace(/%/g, "")}%`;
      const rows = db
        .prepare(
          `SELECT id, name, email, phone
           FROM customers
           WHERE name LIKE ? OR IFNULL(phone,'') LIKE ? OR IFNULL(email,'') LIKE ?
           ORDER BY name
           LIMIT 20`
        )
        .all(like, like, like);
      res.json({ customers: rows });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to search customers" });
    }
  });

  return router;
};
