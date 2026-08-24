-- Operational Attention Score: revenue contribution, late delivery, 1-2 star reviews, cancellation rate.
WITH seller_orders AS (
 SELECT i.seller_id, i.order_id, SUM(i.item_revenue) revenue FROM fact_order_items i GROUP BY 1,2
), seller_metrics AS (
 SELECT s.seller_id, s.seller_state, COUNT(*) orders, SUM(so.revenue) revenue, AVG(o.is_late) late_rate, AVG(o.is_cancelled) cancellation_rate,
        AVG(CASE WHEN r.review_score <=2 THEN 1.0 ELSE 0.0 END) low_review_rate
 FROM seller_orders so JOIN fact_orders o USING(order_id) JOIN dim_seller s USING(seller_id) LEFT JOIN fact_reviews r USING(order_id)
 GROUP BY 1,2
), scored AS (
 SELECT *, 100.0*revenue/SUM(revenue) OVER() revenue_contribution_pct,
        100.0*(.35*COALESCE(late_rate,0)+.30*COALESCE(low_review_rate,0)+.20*COALESCE(cancellation_rate,0)+.15*(revenue/SUM(revenue) OVER())) attention_score
 FROM seller_metrics WHERE orders >= 10
)
SELECT *, DENSE_RANK() OVER(ORDER BY attention_score DESC) risk_rank FROM scored ORDER BY risk_rank, seller_id;
