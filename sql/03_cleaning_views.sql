-- Source is preserved in raw_* tables. This script reloads only analytical tables.
DELETE FROM dim_date; DELETE FROM dim_geography; DELETE FROM dim_customer; DELETE FROM dim_product;
DELETE FROM dim_seller; DELETE FROM fact_orders; DELETE FROM fact_order_items; DELETE FROM fact_payments; DELETE FROM fact_reviews;

INSERT INTO dim_geography
SELECT DISTINCT 'customer:' || customer_state || ':' || lower(customer_city), 'customer', customer_state, customer_city FROM raw_customers
UNION ALL
SELECT DISTINCT 'seller:' || seller_state || ':' || lower(seller_city), 'seller', seller_state, seller_city FROM raw_sellers;

INSERT INTO dim_customer
SELECT customer_id, customer_unique_id, 'customer:' || customer_state || ':' || lower(customer_city), customer_state, customer_city FROM raw_customers;

INSERT INTO dim_product
SELECT p.product_id, p.product_category_name, COALESCE(t.product_category_name_english, 'Untranslated / missing'),
       CAST(p.product_weight_g AS REAL), CAST(p.product_length_cm AS REAL), CAST(p.product_height_cm AS REAL), CAST(p.product_width_cm AS REAL)
FROM raw_products p LEFT JOIN raw_category_translation t ON p.product_category_name = t.product_category_name;

INSERT INTO dim_seller
SELECT seller_id, 'seller:' || seller_state || ':' || lower(seller_city), seller_state, seller_city FROM raw_sellers;

WITH RECURSIVE dates(day) AS (
  SELECT date(MIN(order_purchase_timestamp)) FROM raw_orders WHERE order_purchase_timestamp IS NOT NULL
  UNION ALL SELECT date(day, '+1 day') FROM dates WHERE day < (SELECT date(MAX(order_purchase_timestamp)) FROM raw_orders)
)
INSERT INTO dim_date
SELECT day, CAST(strftime('%Y', day) AS INTEGER), CAST((CAST(strftime('%m', day) AS INTEGER)-1)/3 AS INTEGER)+1,
       CAST(strftime('%m', day) AS INTEGER), CASE strftime('%m', day)
       WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar' WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
       WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep' WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec' END,
       strftime('%Y-%m', day) FROM dates;

INSERT INTO fact_orders
SELECT o.order_id, o.customer_id, date(o.order_purchase_timestamp), o.order_approved_at, o.order_delivered_carrier_date,
       o.order_delivered_customer_date, o.order_estimated_delivery_date, o.order_status,
       c.geo_key,
       CASE WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
            THEN julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp) END,
       CASE WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
            THEN MAX(julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date), 0) END,
       CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END,
       CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END,
       CASE WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END
FROM raw_orders o LEFT JOIN dim_customer c ON o.customer_id = c.customer_id;

INSERT INTO fact_order_items
SELECT order_id, CAST(order_item_id AS INTEGER), product_id, seller_id, shipping_limit_date,
       CAST(price AS REAL), CAST(freight_value AS REAL) FROM raw_order_items;

INSERT INTO fact_payments
SELECT order_id, CAST(payment_sequential AS INTEGER), payment_type, CAST(payment_installments AS INTEGER), CAST(payment_value AS REAL) FROM raw_payments;

INSERT INTO fact_reviews
WITH ranked_reviews AS (
  SELECT order_id, review_id, CAST(review_score AS INTEGER) review_score, review_creation_date, review_answer_timestamp,
         ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC, review_id DESC) AS review_rank
  FROM raw_reviews
)
SELECT order_id, review_id, review_score, review_creation_date, review_answer_timestamp FROM ranked_reviews WHERE review_rank = 1;
