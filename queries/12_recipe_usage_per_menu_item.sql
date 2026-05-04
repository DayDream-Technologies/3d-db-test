-- Bill of materials: quantity of each inventory component per menu portion.

SELECT
  mi.name AS menu_item,
  inv.sku,
  inv.name AS ingredient,
  mir.qty_per_portion,
  inv.unit
FROM menu_item_recipe mir
JOIN menu_items mi ON mi.id = mir.menu_item_id
JOIN inventory_items inv ON inv.id = mir.inventory_item_id
ORDER BY mi.name, inv.name;
