-- Executive KPI spine: aggregate each fact first to prevent payment/item fan-out.
WITH item_by_order AS (SELECT order_id, SUM(item_revenue) item_revenue, SUM(freight_cost) freight_cost, COUNT(*) item_count FROM fact_order_items GROUP BY order_id),
payment_by_order AS (SELECT order_id, SUM(payment_value) payment_value FROM fact_payments GROUP BY order_id)
SELECT COUNT(*) AS total_orders, SUM(is_delivered) AS delivered_orders, SUM(is_cancelled) AS cancelled_orders,
       ROUND(SUM(COALESCE(i.item_revenue,0)),2) AS gmv, ROUND(SUM(COALESCE(p.payment_value,0)),2) AS payment_value,
       ROUND(AVG(i.item_revenue),2) AS average_order_value, ROUND(AVG(i.item_count),2) AS average_items_per_order,
       ROUND(AVG(i.freight_cost),2) AS average_freight_cost, ROUND(100.0*SUM(i.freight_cost)/NULLIF(SUM(i.item_revenue),0),2) AS freight_pct_item_value
FROM fact_orders o LEFT JOIN item_by_order i USING(order_id) LEFT JOIN payment_by_order p USING(order_id);

-- Monthly revenue growth, running total, and three-month rolling average.
WITH monthly AS (SELECT substr(o.purchase_date,1,7) month, SUM(i.item_revenue) revenue FROM fact_orders o JOIN fact_order_items i USING(order_id) GROUP BY 1)
SELECT month, revenue, ROUND(100.0*(revenue-LAG(revenue) OVER(ORDER BY month))/NULLIF(LAG(revenue) OVER(ORDER BY month),0),2) monthly_revenue_growth_pct,
       SUM(revenue) OVER(ORDER BY month) running_revenue, ROUND(AVG(revenue) OVER(ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) rolling_3_month_revenue
FROM monthly ORDER BY month;
