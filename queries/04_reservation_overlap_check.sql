-- Find reservations on a table that overlap a candidate window.
-- Parameters (edit before running):
--   :table_id   — dining_tables.id
--   :start_at   — new reservation start (ISO-like text)
--   :end_at     — new reservation end (must be > start)

SELECT r.id, r.start_at, r.end_at, rs.code AS status_code
FROM reservations r
JOIN reservation_statuses rs ON rs.id = r.reservation_status_id
WHERE r.dining_table_id = 2
  AND rs.code NOT IN ('cancelled', 'no_show')
  AND r.start_at < '2026-05-05 20:00:00'
  AND r.end_at > '2026-05-05 18:30:00';
