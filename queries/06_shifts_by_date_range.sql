-- Staff shifts in a date range (inclusive bounds on starts_at).

SELECT
  s.id AS shift_id,
  st.name AS staff_name,
  r.code AS role_code,
  s.starts_at,
  s.ends_at
FROM shifts s
JOIN staff st ON st.id = s.staff_id
JOIN roles r ON r.id = st.role_id
WHERE s.starts_at >= '2026-05-01 00:00:00'
  AND s.starts_at < '2026-05-08 00:00:00'
ORDER BY s.starts_at, st.name;
