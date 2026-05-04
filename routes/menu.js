const express = require("express");

module.exports = function menuRoutes(db) {
  const router = express.Router();

  router.get("/menu", (req, res) => {
    try {
      const onlyAvail = req.query.available === "1" || req.query.available === "true";
      const sql = `
        SELECT
          c.id AS category_id,
          c.name AS category_name,
          c.sort_order,
          mi.id AS item_id,
          mi.name AS item_name,
          mi.description,
          mi.price_cents,
          mi.is_available,
          ks.code AS kitchen_station_code
        FROM menu_categories c
        JOIN menu_items mi ON mi.category_id = c.id
        LEFT JOIN kitchen_stations ks ON ks.id = mi.kitchen_station_id
        WHERE 1 = 1
        ${onlyAvail ? "AND mi.is_available = 1" : ""}
        ORDER BY c.sort_order, mi.name
      `;
      const rows = db.prepare(sql).all();
      const byCat = new Map();
      for (const row of rows) {
        if (!byCat.has(row.category_id)) {
          byCat.set(row.category_id, {
            id: row.category_id,
            name: row.category_name,
            sortOrder: row.sort_order,
            items: [],
          });
        }
        byCat.get(row.category_id).items.push({
          id: row.item_id,
          name: row.item_name,
          description: row.description,
          priceCents: row.price_cents,
          isAvailable: Boolean(row.is_available),
          kitchenStationCode: row.kitchen_station_code,
        });
      }
      res.json({ categories: [...byCat.values()] });
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: "Failed to load menu" });
    }
  });

  return router;
};
