-- Top 10 menu items by total quantity sold (all time).

SELECT
  mi.id,
  mi.name,
  SUM(ol.qty) AS total_qty,
  SUM(ol.qty * ol.unit_price_cents) AS gross_line_cents
FROM order_lines ol
JOIN menu_items mi ON mi.id = ol.menu_item_id
GROUP BY mi.id, mi.name
ORDER BY total_qty DESC
LIMIT 10;
