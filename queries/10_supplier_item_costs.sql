-- Supplier catalog with inventory item and unit cost.

SELECT
  sup.name AS supplier,
  inv.sku,
  inv.name AS item_name,
  si.unit_cost_cents
FROM supplier_items si
JOIN suppliers sup ON sup.id = si.supplier_id
JOIN inventory_items inv ON inv.id = si.inventory_item_id
ORDER BY sup.name, inv.name;
