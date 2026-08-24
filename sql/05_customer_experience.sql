-- Delays associated with satisfaction; review records are one deterministic record per order.
SELECT CASE WHEN o.is_late=1 THEN 'Late' WHEN o.is_delivered=1 THEN 'On time' ELSE 'Not delivered' END delivery_group,
       COUNT(r.order_id) reviewed_orders, ROUND(AVG(r.review_score),2) average_review_score,
       ROUND(100.0*SUM(CASE WHEN r.review_score=1 THEN 1 ELSE 0 END)/NULLIF(COUNT(r.order_id),0),2) one_star_rate
FROM fact_orders o LEFT JOIN fact_reviews r USING(order_id) GROUP BY 1;

-- Freight-heavy orders versus reviews (freight percentage bands).
WITH order_value AS (SELECT order_id, SUM(item_revenue) item_value, SUM(freight_cost) freight FROM fact_order_items GROUP BY order_id)
SELECT CASE WHEN freight/NULLIF(item_value,0) >= .30 THEN '30%+' WHEN freight/NULLIF(item_value,0) >= .15 THEN '15-29%' ELSE 'Under 15%' END freight_band,
       COUNT(*) orders, ROUND(AVG(r.review_score),2) average_review_score
FROM order_value v JOIN fact_reviews r USING(order_id) GROUP BY 1 ORDER BY 1;

-- Repeat-customer AOV and review comparison.
WITH customer_orders AS (SELECT c.customer_unique_id, o.order_id FROM fact_orders o JOIN dim_customer c USING(customer_id)),
frequency AS (SELECT customer_unique_id, COUNT(*) orders FROM customer_orders GROUP BY 1), order_revenue AS (SELECT order_id,SUM(item_revenue) revenue FROM fact_order_items GROUP BY 1)
SELECT CASE WHEN f.orders > 1 THEN 'Repeat' ELSE 'One-time' END customer_type, COUNT(DISTINCT co.customer_unique_id) customers,
       ROUND(AVG(orv.revenue),2) aov, ROUND(AVG(r.review_score),2) average_review_score
FROM customer_orders co JOIN frequency f USING(customer_unique_id) LEFT JOIN order_revenue orv USING(order_id) LEFT JOIN fact_reviews r USING(order_id) GROUP BY 1;
