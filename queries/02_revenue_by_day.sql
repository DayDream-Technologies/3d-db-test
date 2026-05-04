-- Revenue by calendar day from settled payments (non-pending).

SELECT
  date(p.processed_at) AS day,
  SUM(p.amount_cents) AS revenue_cents,
  COUNT(*) AS payment_count
FROM payments p
WHERE p.method <> 'pending'
GROUP BY date(p.processed_at)
ORDER BY day DESC;
