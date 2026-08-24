-- Raw tables are created dynamically by src/load_data.py so headers remain faithful to source CSVs.
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_seller;
DROP TABLE IF EXISTS dim_geography;
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS fact_payments;
DROP TABLE IF EXISTS fact_reviews;

CREATE TABLE dim_date (
  date_key TEXT PRIMARY KEY, calendar_year INTEGER, calendar_quarter INTEGER,
  month_number INTEGER, month_name TEXT, year_month TEXT
);
CREATE TABLE dim_geography (
  geo_key TEXT PRIMARY KEY, geography_role TEXT, state TEXT, city TEXT
);
CREATE TABLE dim_customer (
  customer_id TEXT PRIMARY KEY, customer_unique_id TEXT, geo_key TEXT, customer_state TEXT, customer_city TEXT
);
CREATE TABLE dim_product (
  product_id TEXT PRIMARY KEY, category_portuguese TEXT, category_name TEXT,
  product_weight_g REAL, product_length_cm REAL, product_height_cm REAL, product_width_cm REAL
);
CREATE TABLE dim_seller (
  seller_id TEXT PRIMARY KEY, geo_key TEXT, seller_state TEXT, seller_city TEXT
);
CREATE TABLE fact_orders (
  order_id TEXT PRIMARY KEY, customer_id TEXT, purchase_date TEXT, approved_at TEXT,
  carrier_handoff_at TEXT, delivered_at TEXT, estimated_delivery_at TEXT, order_status TEXT,
  customer_geo_key TEXT, delivery_days REAL, delay_days REAL, is_delivered INTEGER, is_cancelled INTEGER, is_late INTEGER
);
CREATE TABLE fact_order_items (
  order_id TEXT, order_item_id INTEGER, product_id TEXT, seller_id TEXT, shipping_limit_at TEXT,
  item_revenue REAL, freight_cost REAL, PRIMARY KEY (order_id, order_item_id)
);
CREATE TABLE fact_payments (
  order_id TEXT, payment_sequential INTEGER, payment_type TEXT, payment_installments INTEGER,
  payment_value REAL, PRIMARY KEY (order_id, payment_sequential)
);
CREATE TABLE fact_reviews (
  order_id TEXT PRIMARY KEY, review_id TEXT, review_score INTEGER, review_creation_at TEXT, review_answer_at TEXT
);

CREATE INDEX idx_fact_orders_purchase_date ON fact_orders(purchase_date);
CREATE INDEX idx_fact_items_seller ON fact_order_items(seller_id);
CREATE INDEX idx_fact_items_product ON fact_order_items(product_id);
CREATE INDEX idx_fact_payments_order ON fact_payments(order_id);
