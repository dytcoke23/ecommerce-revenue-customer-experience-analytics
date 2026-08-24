-- Execute after load. These checks are also executed and rendered by src/validate_data.py.
SELECT 'duplicate_order_primary_keys' AS check_name, COUNT(*) AS exceptions FROM (SELECT order_id FROM raw_orders GROUP BY order_id HAVING COUNT(*) > 1)
UNION ALL SELECT 'null_customer_ids', COUNT(*) FROM raw_orders WHERE customer_id IS NULL OR TRIM(customer_id) = ''
UNION ALL SELECT 'null_purchase_timestamps', COUNT(*) FROM raw_orders WHERE order_purchase_timestamp IS NULL OR TRIM(order_purchase_timestamp) = ''
UNION ALL SELECT 'invalid_order_statuses', COUNT(*) FROM raw_orders WHERE order_status NOT IN ('created','approved','invoiced','processing','shipped','delivered','unavailable','canceled')
UNION ALL SELECT 'negative_prices', COUNT(*) FROM raw_order_items WHERE CAST(price AS REAL) < 0
UNION ALL SELECT 'zero_order_item_ids', COUNT(*) FROM raw_order_items WHERE CAST(order_item_id AS INTEGER) <= 0
UNION ALL SELECT 'missing_review_scores', COUNT(*) FROM raw_reviews WHERE review_score IS NULL OR TRIM(review_score) = '';
