-- Inventory items at or below reorder point.

SELECT
  i.id,
  i.sku,
  i.name,
  i.unit,
  i.quantity_on_hand,
  i.reorder_point,
  (i.reorder_point - i.quantity_on_hand) AS deficit
FROM inventory_items i
WHERE i.quantity_on_hand <= i.reorder_point
ORDER BY deficit DESC;
