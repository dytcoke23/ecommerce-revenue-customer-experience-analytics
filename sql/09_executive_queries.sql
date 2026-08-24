-- Intervention shortlist: economically important categories with below-average satisfaction or delivery.
WITH category AS (
 SELECT p.category_name, SUM(i.item_revenue) revenue, AVG(r.review_score) review_score, AVG(o.is_late) late_rate
 FROM fact_order_items i JOIN dim_product p USING(product_id) JOIN fact_orders o USING(order_id) LEFT JOIN fact_reviews r USING(order_id) GROUP BY 1
), benchmark AS (SELECT AVG(review_score) review_avg, AVG(late_rate) late_avg FROM category)
SELECT c.*, ROUND(100.0*c.revenue/SUM(c.revenue) OVER(),2) revenue_contribution_pct,
       CASE WHEN c.review_score < b.review_avg AND c.late_rate > b.late_avg THEN 'Prioritize: experience and delivery'
            WHEN c.review_score < b.review_avg THEN 'Prioritize: satisfaction' WHEN c.late_rate > b.late_avg THEN 'Monitor delivery' ELSE 'Maintain' END action
FROM category c CROSS JOIN benchmark b ORDER BY revenue DESC;
