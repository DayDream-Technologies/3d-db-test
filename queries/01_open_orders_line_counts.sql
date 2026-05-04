-- Open orders with table name and number of line items.
-- Replace status filter as needed.

SELECT
  o.id AS order_id,
  o.placed_at,
  os.code AS status_code,
  c.name AS customer_name,
  t.name AS table_name,
  COUNT(ol.id) AS line_count
FROM orders o
JOIN order_statuses os ON os.id = o.order_status_id
JOIN customers c ON c.id = o.customer_id
LEFT JOIN dining_tables t ON t.id = o.dining_table_id
LEFT JOIN order_lines ol ON ol.order_id = o.id
WHERE os.code IN ('placed', 'preparing', 'ready', 'served')
GROUP BY o.id
ORDER BY o.placed_at DESC;
