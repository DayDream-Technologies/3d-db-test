-- Menu items with aggregated allergen labels (string for display).

SELECT
  mi.id,
  mi.name,
  GROUP_CONCAT(a.name, ', ') AS allergens
FROM menu_items mi
LEFT JOIN menu_item_allergens mia ON mia.menu_item_id = mi.id
LEFT JOIN allergens a ON a.id = mia.allergen_id
GROUP BY mi.id, mi.name
ORDER BY mi.name;
