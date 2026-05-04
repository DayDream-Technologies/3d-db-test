const express = require("express");

function lineSubtotalCents(rows) {
  return rows.reduce((sum, r) => sum + r.qty * r.unit_price_cents, 0);
}

module.exports = function ordersRoutes(db) {
  const router = express.Router();

  router.get("/orders", (req, res) => {
    try {
      const openOnly = req.query.status === "open";
      let sql = `
        SELECT o.id, o.placed_at, o.notes, os.code AS status_code, os.name AS status_name,
               c.name AS customer_name, t.name AS table_name,
               (SELECT COUNT(*) FROM order_lines ol WHERE ol.order_id = o.id) AS line_count
        FROM orders o
        JOIN order_statuses os ON os.id = o.order_status_id
        JOIN customers c ON c.id = o.customer_id
        LEFT JOIN dining_tables t ON t.id = o.dining_table_id
      `;
      if (openOnly) {
        sql += ` WHERE os.code IN ('placed','preparing','ready','served')`;
      }
      sql += ` ORDER BY o.placed_at DESC`;
      const rows = db.prepare(sql).all();
      res.json({
        orders: rows.map((r) => ({
          id: r.id,
          placedAt: r.placed_at,
          notes: r.notes,
          statusCode: r.status_code,
          statusName: r.status_name,
          customerName: r.customer_name,
          tableName: r.table_name,
          lineCount: r.line_count,
        })),
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to list orders" });
    }
  });

  router.get("/orders/:id", (req, res) => {
    try {
      const id = Number(req.params.id);
      const order = db
        .prepare(
          `SELECT o.*, os.code AS status_code, c.name AS customer_name, t.name AS table_name
           FROM orders o
           JOIN order_statuses os ON os.id = o.order_status_id
           JOIN customers c ON c.id = o.customer_id
           LEFT JOIN dining_tables t ON t.id = o.dining_table_id
           WHERE o.id = ?`
        )
        .get(id);
      if (!order) {
        return res.status(404).json({ error: "Order not found" });
      }
      const lines = db
        .prepare(
          `SELECT ol.id, ol.qty, ol.unit_price_cents, mi.name AS item_name
           FROM order_lines ol
           JOIN menu_items mi ON mi.id = ol.menu_item_id
           WHERE ol.order_id = ?`
        )
        .all(id);
      const promos = db
        .prepare(
          `SELECT p.code, op.discount_cents
           FROM order_promotions op
           JOIN promotions p ON p.id = op.promotion_id
           WHERE op.order_id = ?`
        )
        .all(id);
      const payments = db
        .prepare(
          `SELECT id, method, amount_cents, processed_at FROM payments WHERE order_id = ?`
        )
        .all(id);
      const subtotal = lines.reduce((s, l) => s + l.qty * l.unit_price_cents, 0);
      const discount = promos.reduce((s, p) => s + p.discount_cents, 0);
      res.json({
        order: {
          id: order.id,
          placedAt: order.placed_at,
          notes: order.notes,
          statusCode: order.status_code,
          customerName: order.customer_name,
          tableName: order.table_name,
        },
        lines: lines.map((l) => ({
          id: l.id,
          itemName: l.item_name,
          qty: l.qty,
          unitPriceCents: l.unit_price_cents,
        })),
        promotions: promos,
        payments,
        subtotalCents: subtotal,
        discountCents: discount,
        totalCents: Math.max(0, subtotal - discount),
      });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to load order" });
    }
  });

  router.post("/orders", (req, res) => {
    const body = req.body || {};
    const linesIn = Array.isArray(body.lines) ? body.lines : [];
    if (linesIn.length === 0) {
      return res.status(400).json({ error: "At least one line item is required" });
    }

    const tx = db.transaction(() => {
      const hasCustomerId =
        body.customerId !== undefined &&
        body.customerId !== null &&
        String(body.customerId).trim() !== "";
      let customerId = hasCustomerId ? Number(body.customerId) : null;
      if (hasCustomerId && !Number.isFinite(customerId)) {
        throw Object.assign(new Error("Invalid customerId"), { status: 400 });
      }
      if (customerId != null && Number.isFinite(customerId)) {
        const c = db.prepare(`SELECT id FROM customers WHERE id = ?`).get(customerId);
        if (!c) {
          throw Object.assign(new Error("Invalid customerId"), { status: 400 });
        }
      } else if (body.customer && (body.customer.name || body.customer.phone)) {
        const info = body.customer;
        const r = db
          .prepare(
            `INSERT INTO customers (name, email, phone) VALUES (?, ?, ?)`
          )
          .run(
            info.name || "Guest",
            info.email || null,
            info.phone || null
          );
        customerId = r.lastInsertRowid;
      } else {
        throw Object.assign(new Error("customerId or customer { name, phone } required"), {
          status: 400,
        });
      }

      const tableId =
        body.tableId != null && body.tableId !== ""
          ? Number(body.tableId)
          : null;
      if (tableId) {
        const t = db.prepare(`SELECT id FROM dining_tables WHERE id = ? AND is_active = 1`).get(tableId);
        if (!t) {
          throw Object.assign(new Error("Invalid or inactive tableId"), { status: 400 });
        }
      }

      const placedStatus = db
        .prepare(`SELECT id FROM order_statuses WHERE code = 'placed'`)
        .get();
      const orderResult = db
        .prepare(
          `INSERT INTO orders (customer_id, dining_table_id, order_status_id, notes)
           VALUES (?, ?, ?, ?)`
        )
        .run(
          customerId,
          tableId,
          placedStatus.id,
          body.notes || null
        );
      const orderId = orderResult.lastInsertRowid;

      const getItem = db.prepare(
        `SELECT id, price_cents, is_available FROM menu_items WHERE id = ?`
      );
      for (const line of linesIn) {
        const mid = Number(line.menuItemId);
        const qty = Number(line.qty);
        if (!mid || !Number.isInteger(qty) || qty < 1) {
          throw Object.assign(new Error("Each line needs menuItemId and positive integer qty"), {
            status: 400,
          });
        }
        const item = getItem.get(mid);
        if (!item || !item.is_available) {
          throw Object.assign(new Error(`Menu item unavailable or missing: ${mid}`), {
            status: 400,
          });
        }
        db.prepare(
          `INSERT INTO order_lines (order_id, menu_item_id, qty, unit_price_cents)
           VALUES (?, ?, ?, ?)`
        ).run(orderId, mid, qty, item.price_cents);
      }

      const lineRows = db
        .prepare(
          `SELECT qty, unit_price_cents FROM order_lines WHERE order_id = ?`
        )
        .all(orderId);
      let subtotal = lineSubtotalCents(lineRows);
      let discountCents = 0;

      if (body.promotionCode) {
        const code = String(body.promotionCode).trim().toUpperCase();
        const today = new Date().toISOString().slice(0, 10);
        const promo = db
          .prepare(
            `SELECT id, discount_pct FROM promotions
             WHERE UPPER(code) = ? AND date(?) BETWEEN date(valid_from) AND date(valid_to)`
          )
          .get(code, today);
        if (promo) {
          discountCents = Math.floor((subtotal * promo.discount_pct) / 100);
          db.prepare(
            `INSERT INTO order_promotions (order_id, promotion_id, discount_cents)
             VALUES (?, ?, ?)`
          ).run(orderId, promo.id, discountCents);
        }
      }

      db.prepare(
        `INSERT INTO payments (order_id, method, amount_cents) VALUES (?, 'pending', 0)`
      ).run(orderId);

      const total = Math.max(0, subtotal - discountCents);
      return { orderId, subtotalCents: subtotal, discountCents, totalCents: total };
    });

    try {
      const out = tx();
      res.status(201).json(out);
    } catch (e) {
      if (e.status) {
        return res.status(e.status).json({ error: e.message });
      }
      console.error(e);
      res.status(500).json({ error: "Failed to create order" });
    }
  });

  router.patch("/orders/:id/status", (req, res) => {
    try {
      const id = Number(req.params.id);
      const code = (req.body && req.body.statusCode) || req.body?.code;
      if (!code || typeof code !== "string") {
        return res.status(400).json({ error: "Body must include statusCode (order status code)" });
      }
      const status = db
        .prepare(`SELECT id FROM order_statuses WHERE code = ?`)
        .get(code.trim().toLowerCase());
      if (!status) {
        return res.status(400).json({ error: "Unknown status code" });
      }
      const r = db.prepare(`UPDATE orders SET order_status_id = ? WHERE id = ?`).run(status.id, id);
      if (r.changes === 0) {
        return res.status(404).json({ error: "Order not found" });
      }
      if (code.trim().toLowerCase() === "closed") {
        const sub = db
          .prepare(
            `SELECT SUM(ol.qty * ol.unit_price_cents) AS s
             FROM order_lines ol WHERE ol.order_id = ?`
          )
          .get(id);
        const discRow = db
          .prepare(
            `SELECT IFNULL(SUM(discount_cents),0) AS d FROM order_promotions WHERE order_id = ?`
          )
          .get(id);
        const subtotal = sub.s || 0;
        const discount = discRow.d || 0;
        const total = Math.max(0, subtotal - discount);
        const pending = db
          .prepare(
            `SELECT id FROM payments WHERE order_id = ? AND method = 'pending' LIMIT 1`
          )
          .get(id);
        if (pending) {
          db.prepare(
            `UPDATE payments SET method = 'card', amount_cents = ?, processed_at = datetime('now') WHERE id = ?`
          ).run(total, pending.id);
        } else {
          db.prepare(
            `INSERT INTO payments (order_id, method, amount_cents) VALUES (?, 'card', ?)`
          ).run(id, total);
        }
      }
      res.json({ ok: true, orderId: id, statusCode: code.trim().toLowerCase() });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to update status" });
    }
  });

  return router;
};
