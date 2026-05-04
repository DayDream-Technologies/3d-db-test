-- Deterministic seed data (explicit IDs for stable references)

INSERT INTO roles (id, code, name) VALUES
  (1, 'server', 'Server'),
  (2, 'host', 'Host'),
  (3, 'cook', 'Cook'),
  (4, 'manager', 'Manager');

INSERT INTO order_statuses (id, code, name) VALUES
  (1, 'placed', 'Placed'),
  (2, 'preparing', 'Preparing'),
  (3, 'ready', 'Ready'),
  (4, 'served', 'Served'),
  (5, 'closed', 'Closed');

INSERT INTO reservation_statuses (id, code, name) VALUES
  (1, 'requested', 'Requested'),
  (2, 'confirmed', 'Confirmed'),
  (3, 'seated', 'Seated'),
  (4, 'cancelled', 'Cancelled'),
  (5, 'no_show', 'No show');

INSERT INTO waitlist_statuses (id, code, name) VALUES
  (1, 'waiting', 'Waiting'),
  (2, 'seated', 'Seated'),
  (3, 'cancelled', 'Cancelled');

INSERT INTO allergens (id, name) VALUES
  (1, 'Dairy'),
  (2, 'Gluten'),
  (3, 'Tree nuts'),
  (4, 'Shellfish');

INSERT INTO kitchen_stations (id, code, name) VALUES
  (1, 'prep', 'Prep'),
  (2, 'grill', 'Grill'),
  (3, 'pantry', 'Pantry'),
  (4, 'cold', 'Cold station');

INSERT INTO locations (id, name, address, phone) VALUES
  (1, 'Main dining', '100 Maple Ave, Demo City', '555-0100'),
  (2, 'Patio annex', '100 Maple Ave Rear', '555-0101');

INSERT INTO dining_tables (id, location_id, name, capacity, is_active) VALUES
  (1, 1, 'T1', 2, 1),
  (2, 1, 'T2', 4, 1),
  (3, 1, 'T3', 4, 1),
  (4, 1, 'T4', 6, 1),
  (5, 1, 'Bar-1', 2, 1),
  (6, 2, 'P-A', 4, 1),
  (7, 2, 'P-B', 8, 1);

INSERT INTO staff (id, role_id, name, email, hired_at, is_active) VALUES
  (1, 4, 'Alex Morgan', 'alex@example.test', '2024-01-15', 1),
  (2, 3, 'Jordan Lee', 'jordan@example.test', '2024-03-01', 1),
  (3, 3, 'Sam Rivera', 'sam@example.test', '2024-06-10', 1),
  (4, 1, 'Casey Kim', 'casey@example.test', '2025-02-20', 1),
  (5, 2, 'Riley Chen', 'riley@example.test', '2025-04-01', 1),
  (6, 1, 'Taylor Brooks', NULL, '2025-08-01', 1);

INSERT INTO customers (id, name, email, phone, created_at) VALUES
  (1, 'Jamie Doe', 'jamie@example.test', '555-1001', '2026-01-10 12:00:00'),
  (2, 'Morgan Smith', NULL, '555-1002', '2026-02-02 09:30:00'),
  (3, 'Avery Johnson', 'avery@example.test', '555-1003', '2026-02-14 18:00:00'),
  (4, 'Quinn Patel', 'quinn@example.test', '555-1004', '2026-03-01 11:00:00'),
  (5, 'Blake Wilson', NULL, '555-1005', '2026-03-20 19:45:00'),
  (6, 'Cameron Lee', 'cam@example.test', '555-1006', '2026-04-01 08:00:00');

INSERT INTO menu_categories (id, name, sort_order) VALUES
  (1, 'Starters', 10),
  (2, 'Mains', 20),
  (3, 'Sides', 30),
  (4, 'Desserts', 40),
  (5, 'Beverages', 50);

INSERT INTO menu_items (id, category_id, name, description, price_cents, kitchen_station_id, is_available) VALUES
  (1, 1, 'House salad', 'Greens, vinaigrette', 850, 1, 1),
  (2, 1, 'Soup of the day', 'Chef choice', 950, 1, 1),
  (3, 1, 'Bruschetta', 'Tomato, basil', 1100, 4, 1),
  (4, 2, 'Grilled salmon', 'Lemon butter', 2400, 2, 1),
  (5, 2, 'Burger', 'Cheddar, pickles', 1650, 2, 1),
  (6, 2, 'Pasta primavera', 'Seasonal vegetables', 1550, 1, 1),
  (7, 2, 'Steak frites', '8oz strip', 2900, 2, 1),
  (8, 3, 'Fries', 'Sea salt', 600, 2, 1),
  (9, 3, 'Roasted vegetables', 'Herbs', 700, 1, 1),
  (10, 4, 'Chocolate cake', 'Ganache', 900, 3, 1),
  (11, 4, 'Ice cream', 'Vanilla bean', 700, 4, 1),
  (12, 5, 'Iced tea', 'Unsweet or sweet', 350, 4, 1),
  (13, 5, 'Soda', 'Assorted', 350, 4, 1),
  (14, 5, 'Coffee', 'Regular or decaf', 400, 3, 1),
  (15, 5, 'House wine', 'Glass', 900, 4, 1);

INSERT INTO suppliers (id, name, contact_phone) VALUES
  (1, 'Fresh Valley Produce', '555-2001'),
  (2, 'Coastal Seafood Co.', '555-2002'),
  (3, 'Metro Dry Goods', '555-2003');

INSERT INTO inventory_items (id, sku, name, unit, quantity_on_hand, reorder_point) VALUES
  (1, 'INV-LETTUCE', 'Romaine lettuce', 'head', 24, 8),
  (2, 'INV-TOMATO', 'Tomatoes', 'lb', 40, 15),
  (3, 'INV-SALMON', 'Salmon fillet', 'lb', 18, 6),
  (4, 'INV-BEEF', 'Strip steak', 'lb', 22, 10),
  (5, 'INV-PASTA', 'Dry pasta', 'lb', 30, 12),
  (6, 'INV-FRIES', 'Frozen fries', 'case', 5, 2),
  (7, 'INV-CHOC', 'Chocolate cake mix', 'box', 12, 4),
  (8, 'INV-CREAM', 'Heavy cream', 'qt', 10, 4);

INSERT INTO promotions (id, code, discount_pct, valid_from, valid_to) VALUES
  (1, 'HAPPY10', 10, '2026-01-01', '2026-12-31'),
  (2, 'WELCOME15', 15, '2026-01-01', '2026-06-30');

INSERT INTO menu_item_allergens (menu_item_id, allergen_id) VALUES
  (3, 2),
  (4, 4),
  (5, 1),
  (5, 2),
  (10, 1),
  (11, 1);

INSERT INTO supplier_items (supplier_id, inventory_item_id, unit_cost_cents) VALUES
  (1, 1, 120),
  (1, 2, 180),
  (2, 3, 1200),
  (3, 4, 1400),
  (3, 5, 90),
  (3, 6, 800),
  (3, 7, 350),
  (3, 8, 280);

INSERT INTO menu_item_recipe (menu_item_id, inventory_item_id, qty_per_portion) VALUES
  (1, 1, 0.25),
  (1, 2, 0.1),
  (4, 3, 0.35),
  (5, 4, 0.4),
  (6, 5, 0.2),
  (8, 6, 0.05),
  (10, 7, 0.15),
  (11, 8, 0.08);

INSERT INTO shifts (id, staff_id, starts_at, ends_at) VALUES
  (1, 2, '2026-05-01 09:00:00', '2026-05-01 17:00:00'),
  (2, 3, '2026-05-01 09:00:00', '2026-05-01 17:00:00'),
  (3, 4, '2026-05-01 11:00:00', '2026-05-01 19:00:00'),
  (4, 5, '2026-05-01 16:00:00', '2026-05-01 23:00:00'),
  (5, 1, '2026-05-02 08:00:00', '2026-05-02 16:00:00');

INSERT INTO orders (id, customer_id, dining_table_id, order_status_id, placed_at, notes) VALUES
  (1, 1, 2, 5, '2026-04-10 18:30:00', NULL),
  (2, 2, NULL, 5, '2026-04-12 12:05:00', 'Takeout'),
  (3, 3, 4, 5, '2026-04-18 19:00:00', 'Birthday'),
  (4, 1, 3, 2, '2026-05-04 17:10:00', 'Extra napkins'),
  (5, 4, 5, 1, '2026-05-04 17:45:00', NULL),
  (6, 5, 1, 1, '2026-05-04 18:00:00', NULL);

INSERT INTO order_lines (id, order_id, menu_item_id, qty, unit_price_cents) VALUES
  (1, 1, 2, 1, 950),
  (2, 1, 5, 2, 1650),
  (3, 1, 8, 1, 600),
  (4, 2, 6, 1, 1550),
  (5, 2, 12, 2, 350),
  (6, 3, 7, 2, 2900),
  (7, 3, 9, 1, 700),
  (8, 3, 14, 2, 400),
  (9, 4, 4, 1, 2400),
  (10, 4, 8, 1, 600),
  (11, 5, 5, 1, 1650),
  (12, 5, 13, 1, 350),
  (13, 6, 1, 1, 850),
  (14, 6, 12, 1, 350);

INSERT INTO order_promotions (order_id, promotion_id, discount_cents) VALUES
  (1, 1, 320),
  (3, 2, 1295);

INSERT INTO payments (id, order_id, method, amount_cents, processed_at) VALUES
  (1, 1, 'card', 4580, '2026-04-10 18:55:00'),
  (2, 2, 'cash', 2250, '2026-04-12 12:20:00'),
  (3, 3, 'card', 8705, '2026-04-18 20:05:00'),
  (4, 4, 'pending', 0, '2026-05-04 17:10:00'),
  (5, 5, 'pending', 0, '2026-05-04 17:45:00'),
  (6, 6, 'pending', 0, '2026-05-04 18:00:00');

INSERT INTO reservations (id, customer_id, dining_table_id, party_size, start_at, end_at, reservation_status_id, notes) VALUES
  (1, 3, 4, 4, '2026-05-04 19:00:00', '2026-05-04 21:00:00', 2, 'Window if possible'),
  (2, 4, 2, 2, '2026-05-05 18:30:00', '2026-05-05 20:00:00', 2, NULL),
  (3, 6, 7, 6, '2026-05-06 12:00:00', '2026-05-06 14:00:00', 1, 'Business lunch'),
  (4, 1, 3, 3, '2026-04-20 17:00:00', '2026-04-20 19:00:00', 3, NULL);

INSERT INTO waitlist (id, customer_id, party_size, requested_at, waitlist_status_id, notes) VALUES
  (1, 2, 3, '2026-05-04 17:00:00', 1, NULL),
  (2, 5, 2, '2026-05-04 17:30:00', 1, 'Outdoor preferred');

INSERT INTO reviews (id, customer_id, order_id, rating, comment, created_at) VALUES
  (1, 1, 1, 5, 'Great burger.', '2026-04-11 10:00:00'),
  (2, 3, 3, 4, 'Steak was good; loud room.', '2026-04-19 09:00:00');
