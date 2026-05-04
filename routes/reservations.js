const express = require("express");

module.exports = function reservationsRoutes(db) {
  const router = express.Router();

  function findOverlapping(tableId, startAt, endAt, excludeId) {
    const sql = `
      SELECT r.id, r.start_at, r.end_at, rs.code AS status_code
      FROM reservations r
      JOIN reservation_statuses rs ON rs.id = r.reservation_status_id
      WHERE r.dining_table_id = ?
        AND rs.code NOT IN ('cancelled', 'no_show')
        AND r.start_at < ?
        AND r.end_at > ?
        ${excludeId ? "AND r.id <> ?" : ""}
    `;
    const params = [tableId, endAt, startAt];
    if (excludeId) params.push(excludeId);
    return db.prepare(sql).all(...params);
  }

  router.get("/reservations", (req, res) => {
    try {
      const from = req.query.from;
      const to = req.query.to;
      let sql = `
        SELECT r.id, r.party_size, r.start_at, r.end_at, r.notes,
               rs.code AS status_code, c.name AS customer_name,
               t.name AS table_name, l.name AS location_name
        FROM reservations r
        JOIN reservation_statuses rs ON rs.id = r.reservation_status_id
        JOIN customers c ON c.id = r.customer_id
        JOIN dining_tables t ON t.id = r.dining_table_id
        JOIN locations l ON l.id = t.location_id
        WHERE 1=1
      `;
      const params = [];
      if (from) {
        sql += ` AND r.end_at >= ?`;
        params.push(from);
      }
      if (to) {
        sql += ` AND r.start_at <= ?`;
        params.push(to);
      }
      sql += ` ORDER BY r.start_at`;
      const rows = db.prepare(sql).all(...params);
      res.json({
        reservations: rows.map((r) => ({
          id: r.id,
          partySize: r.party_size,
          startAt: r.start_at,
          endAt: r.end_at,
          notes: r.notes,
          statusCode: r.status_code,
          customerName: r.customer_name,
          tableName: r.table_name,
          locationName: r.location_name,
        })),
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to list reservations" });
    }
  });

  router.post("/reservations", (req, res) => {
    try {
      const body = req.body || {};
      const customerId = Number(body.customerId);
      const tableId = Number(body.tableId);
      const partySize = Number(body.partySize);
      const startAt = body.startAt;
      const endAt = body.endAt;
      if (!customerId || !tableId || !partySize || !startAt || !endAt) {
        return res
          .status(400)
          .json({ error: "customerId, tableId, partySize, startAt, endAt required" });
      }
      if (endAt <= startAt) {
        return res.status(400).json({ error: "endAt must be after startAt" });
      }

      const cust = db.prepare(`SELECT id FROM customers WHERE id = ?`).get(customerId);
      if (!cust) {
        return res.status(400).json({ error: "Invalid customerId" });
      }
      const table = db
        .prepare(`SELECT id, capacity FROM dining_tables WHERE id = ? AND is_active = 1`)
        .get(tableId);
      if (!table) {
        return res.status(400).json({ error: "Invalid or inactive table" });
      }
      if (partySize > table.capacity) {
        return res.status(400).json({
          error: `Party size ${partySize} exceeds table capacity ${table.capacity}`,
        });
      }

      const overlaps = findOverlapping(tableId, startAt, endAt, null);
      if (overlaps.length > 0) {
        return res.status(409).json({
          error: "Table is already reserved for overlapping time",
          conflicts: overlaps,
        });
      }

      const confirmed = db
        .prepare(`SELECT id FROM reservation_statuses WHERE code = 'confirmed'`)
        .get();
      const r = db
        .prepare(
          `INSERT INTO reservations (customer_id, dining_table_id, party_size, start_at, end_at, reservation_status_id, notes)
           VALUES (?, ?, ?, ?, ?, ?, ?)`
        )
        .run(
          customerId,
          tableId,
          partySize,
          startAt,
          endAt,
          confirmed.id,
          body.notes || null
        );

      res.status(201).json({
        id: r.lastInsertRowid,
        customerId,
        tableId,
        partySize,
        startAt,
        endAt,
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to create reservation" });
    }
  });

  return router;
};
