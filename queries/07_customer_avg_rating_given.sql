-- Customers and the average star rating they gave (from reviews).

SELECT
  c.id,
  c.name,
  COUNT(rv.id) AS review_count,
  ROUND(AVG(rv.rating), 2) AS avg_rating_given
FROM customers c
LEFT JOIN reviews rv ON rv.customer_id = c.id
GROUP BY c.id, c.name
HAVING review_count > 0
ORDER BY avg_rating_given DESC, review_count DESC;
