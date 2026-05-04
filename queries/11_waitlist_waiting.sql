-- Parties currently waiting, oldest first.

SELECT
  w.id,
  w.requested_at,
  w.party_size,
  c.name AS customer_name,
  c.phone
FROM waitlist w
JOIN waitlist_statuses ws ON ws.id = w.waitlist_status_id
JOIN customers c ON c.id = w.customer_id
WHERE ws.code = 'waiting'
ORDER BY w.requested_at ASC;
