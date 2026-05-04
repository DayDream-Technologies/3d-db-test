-- Per-order subtotal, promotion discount, and net (for reconciliation).

SELECT
  o.id AS order_id,
  o.placed_at,
  os.code AS status_code,
  SUM(ol.qty * ol.unit_price_cents) AS subtotal_cents,
  IFNULL((
    SELECT SUM(op.discount_cents)
    FROM order_promotions op
    WHERE op.order_id = o.id
  ), 0) AS discount_cents,
  SUM(ol.qty * ol.unit_price_cents) - IFNULL((
    SELECT SUM(op.discount_cents)
    FROM order_promotions op
    WHERE op.order_id = o.id
  ), 0) AS net_cents
FROM orders o
JOIN order_statuses os ON os.id = o.order_status_id
JOIN order_lines ol ON ol.order_id = o.id
GROUP BY o.id, o.placed_at, os.code
ORDER BY o.placed_at DESC;
