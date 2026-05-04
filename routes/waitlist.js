const express = require("express");

module.exports = function waitlistRoutes(db) {
  const router = express.Router();

  router.get("/waitlist", (req, res) => {
    try {
      const rows = db
        .prepare(
          `SELECT w.id, w.party_size, w.requested_at, w.notes,
                  s.code AS status_code, c.name AS customer_name, c.phone
           FROM waitlist w
           JOIN waitlist_statuses s ON s.id = w.waitlist_status_id
           JOIN customers c ON c.id = w.customer_id
           ORDER BY w.requested_at ASC`
        )
        .all();
      res.json({
        entries: rows.map((r) => ({
          id: r.id,
          partySize: r.party_size,
          requestedAt: r.requested_at,
          notes: r.notes,
          statusCode: r.status_code,
          customerName: r.customer_name,
          phone: r.phone,
        })),
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to list waitlist" });
    }
  });

  router.post("/waitlist", (req, res) => {
    try {
      const body = req.body || {};
      const hasCustomerId =
        body.customerId !== undefined &&
        body.customerId !== null &&
        String(body.customerId).trim() !== "";
      let customerId = hasCustomerId ? Number(body.customerId) : null;
      if (hasCustomerId && !Number.isFinite(customerId)) {
        return res.status(400).json({ error: "Invalid customerId" });
      }
      if (customerId != null && Number.isFinite(customerId)) {
        const c = db.prepare(`SELECT id FROM customers WHERE id = ?`).get(customerId);
        if (!c) {
          return res.status(400).json({ error: "Invalid customerId" });
        }
      } else if (body.customer && (body.customer.name || body.customer.phone)) {
        const info = body.customer;
        const r = db
          .prepare(`INSERT INTO customers (name, email, phone) VALUES (?, ?, ?)`)
          .run(info.name || "Guest", info.email || null, info.phone || null);
        customerId = r.lastInsertRowid;
      } else {
        return res.status(400).json({ error: "customerId or customer { name, phone } required" });
      }

      const partySize = Number(body.partySize);
      if (!partySize || partySize < 1) {
        return res.status(400).json({ error: "partySize must be a positive integer" });
      }

      const waiting = db.prepare(`SELECT id FROM waitlist_statuses WHERE code = 'waiting'`).get();
      const ins = db
        .prepare(
          `INSERT INTO waitlist (customer_id, party_size, waitlist_status_id, notes)
           VALUES (?, ?, ?, ?)`
        )
        .run(customerId, partySize, waiting.id, body.notes || null);

      res.status(201).json({
        id: ins.lastInsertRowid,
        customerId,
        partySize,
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to add waitlist entry" });
    }
  });

  return router;
};
