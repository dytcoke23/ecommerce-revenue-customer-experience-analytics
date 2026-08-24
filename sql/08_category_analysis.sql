WITH category_orders AS (
 SELECT p.category_name, i.order_id, SUM(i.item_revenue) revenue, SUM(i.freight_cost) freight FROM fact_order_items i JOIN dim_product p USING(product_id) GROUP BY 1,2
)
SELECT category_name, COUNT(*) orders, ROUND(SUM(revenue),2) revenue, ROUND(AVG(revenue),2) aov,
       ROUND(100.0*SUM(revenue)/SUM(SUM(revenue)) OVER(),2) revenue_contribution_pct,
       ROUND(AVG(r.review_score),2) average_review_score, ROUND(100.0*AVG(CASE WHEN r.review_score=1 THEN 1.0 ELSE 0 END),2) one_star_rate,
       ROUND(100.0*AVG(o.is_late),2) late_delivery_rate, ROUND(100.0*SUM(freight)/NULLIF(SUM(revenue),0),2) freight_pct,
       RANK() OVER(ORDER BY SUM(revenue) DESC) revenue_rank
FROM category_orders c JOIN fact_orders o USING(order_id) LEFT JOIN fact_reviews r USING(order_id)
GROUP BY category_name ORDER BY revenue DESC;
