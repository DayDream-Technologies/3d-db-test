-- Local restaurant test schema (SQLite)
-- INTEGER PKs, FKs enforced via PRAGMA foreign_keys = ON in application

CREATE TABLE roles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
);

CREATE TABLE order_statuses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
);

CREATE TABLE reservation_statuses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
);

CREATE TABLE waitlist_statuses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
);

CREATE TABLE allergens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE kitchen_stations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
);

CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT
);

CREATE TABLE dining_tables (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  location_id INTEGER NOT NULL REFERENCES locations (id),
  name TEXT NOT NULL,
  capacity INTEGER NOT NULL CHECK (capacity > 0),
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  UNIQUE (location_id, name)
);
CREATE INDEX idx_dining_tables_location ON dining_tables (location_id);

CREATE TABLE staff (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  role_id INTEGER NOT NULL REFERENCES roles (id),
  name TEXT NOT NULL,
  email TEXT,
  hired_at TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);
CREATE INDEX idx_staff_role ON staff (role_id);

CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_customers_phone ON customers (phone);
CREATE INDEX idx_customers_name ON customers (name);

CREATE TABLE menu_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL REFERENCES menu_categories (id),
  name TEXT NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
  kitchen_station_id INTEGER REFERENCES kitchen_stations (id),
  is_available INTEGER NOT NULL DEFAULT 1 CHECK (is_available IN (0, 1))
);
CREATE INDEX idx_menu_items_category ON menu_items (category_id);
CREATE INDEX idx_menu_items_available ON menu_items (is_available);

CREATE TABLE suppliers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  contact_phone TEXT
);

CREATE TABLE inventory_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  unit TEXT NOT NULL,
  quantity_on_hand REAL NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
  reorder_point REAL NOT NULL DEFAULT 0 CHECK (reorder_point >= 0)
);

CREATE TABLE promotions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  discount_pct INTEGER NOT NULL CHECK (discount_pct >= 0 AND discount_pct <= 100),
  valid_from TEXT NOT NULL,
  valid_to TEXT NOT NULL
);

CREATE TABLE menu_item_allergens (
  menu_item_id INTEGER NOT NULL REFERENCES menu_items (id) ON DELETE CASCADE,
  allergen_id INTEGER NOT NULL REFERENCES allergens (id),
  PRIMARY KEY (menu_item_id, allergen_id)
);

CREATE TABLE supplier_items (
  supplier_id INTEGER NOT NULL REFERENCES suppliers (id),
  inventory_item_id INTEGER NOT NULL REFERENCES inventory_items (id),
  unit_cost_cents INTEGER NOT NULL CHECK (unit_cost_cents >= 0),
  PRIMARY KEY (supplier_id, inventory_item_id)
);

CREATE TABLE menu_item_recipe (
  menu_item_id INTEGER NOT NULL REFERENCES menu_items (id) ON DELETE CASCADE,
  inventory_item_id INTEGER NOT NULL REFERENCES inventory_items (id),
  qty_per_portion REAL NOT NULL CHECK (qty_per_portion > 0),
  PRIMARY KEY (menu_item_id, inventory_item_id)
);

CREATE TABLE shifts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  staff_id INTEGER NOT NULL REFERENCES staff (id),
  starts_at TEXT NOT NULL,
  ends_at TEXT NOT NULL
);
CREATE INDEX idx_shifts_staff ON shifts (staff_id);
CREATE INDEX idx_shifts_starts ON shifts (starts_at);

CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL REFERENCES customers (id),
  dining_table_id INTEGER REFERENCES dining_tables (id),
  order_status_id INTEGER NOT NULL REFERENCES order_statuses (id),
  placed_at TEXT NOT NULL DEFAULT (datetime('now')),
  notes TEXT
);
CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_orders_table ON orders (dining_table_id);
CREATE INDEX idx_orders_status ON orders (order_status_id);
CREATE INDEX idx_orders_placed ON orders (placed_at);

CREATE TABLE order_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  menu_item_id INTEGER NOT NULL REFERENCES menu_items (id),
  qty INTEGER NOT NULL CHECK (qty > 0),
  unit_price_cents INTEGER NOT NULL CHECK (unit_price_cents >= 0)
);
CREATE INDEX idx_order_lines_order ON order_lines (order_id);
CREATE INDEX idx_order_lines_menu_item ON order_lines (menu_item_id);

CREATE TABLE order_promotions (
  order_id INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  promotion_id INTEGER NOT NULL REFERENCES promotions (id),
  discount_cents INTEGER NOT NULL DEFAULT 0 CHECK (discount_cents >= 0),
  PRIMARY KEY (order_id, promotion_id)
);

CREATE TABLE payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  method TEXT NOT NULL,
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  processed_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_payments_order ON payments (order_id);
CREATE INDEX idx_payments_processed ON payments (processed_at);

CREATE TABLE reservations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL REFERENCES customers (id),
  dining_table_id INTEGER NOT NULL REFERENCES dining_tables (id),
  party_size INTEGER NOT NULL CHECK (party_size > 0),
  start_at TEXT NOT NULL,
  end_at TEXT NOT NULL,
  reservation_status_id INTEGER NOT NULL REFERENCES reservation_statuses (id),
  notes TEXT,
  CHECK (end_at > start_at)
);
CREATE INDEX idx_reservations_table ON reservations (dining_table_id);
CREATE INDEX idx_reservations_start ON reservations (start_at);
CREATE INDEX idx_reservations_status ON reservations (reservation_status_id);

CREATE TABLE waitlist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL REFERENCES customers (id),
  party_size INTEGER NOT NULL CHECK (party_size > 0),
  requested_at TEXT NOT NULL DEFAULT (datetime('now')),
  waitlist_status_id INTEGER NOT NULL REFERENCES waitlist_statuses (id),
  notes TEXT
);
CREATE INDEX idx_waitlist_status ON waitlist (waitlist_status_id);
CREATE INDEX idx_waitlist_requested ON waitlist (requested_at);

CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL REFERENCES customers (id),
  order_id INTEGER NOT NULL REFERENCES orders (id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (customer_id, order_id)
);
CREATE INDEX idx_reviews_order ON reviews (order_id);
