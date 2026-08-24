-- Customer states with delivery issues.
SELECT c.customer_state, COUNT(*) delivered_orders, ROUND(100.0*AVG(o.is_late),2) late_delivery_rate,
       ROUND(AVG(o.delivery_days),2) average_delivery_days, ROUND(AVG(o.delay_days),2) average_delay_days
FROM fact_orders o JOIN dim_customer c USING(customer_id) WHERE o.is_delivered=1 GROUP BY 1 ORDER BY late_delivery_rate DESC;

-- Category delivery performance.
SELECT p.category_name, COUNT(DISTINCT o.order_id) orders, ROUND(100.0*AVG(o.is_late),2) late_delivery_rate, ROUND(AVG(o.delivery_days),2) average_delivery_days
FROM fact_orders o JOIN fact_order_items i USING(order_id) JOIN dim_product p USING(product_id) WHERE o.is_delivered=1 GROUP BY 1 ORDER BY late_delivery_rate DESC;
