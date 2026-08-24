"""Generate concise, evidence-backed portfolio findings from the loaded real dataset."""
from __future__ import annotations
import argparse
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def rows(connection, query):
    return connection.execute(query).fetchall()

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--database", type=Path, default=ROOT / "data" / "olist_analytics.sqlite")
    args = parser.parse_args()
    with sqlite3.connect(args.database) as con:
        orders, gmv, avg_review, on_time = con.execute("""
          SELECT COUNT(*), ROUND(SUM(item_revenue),2), ROUND(AVG(review_score),2), ROUND(100.0*(1-AVG(is_late)),2)
          FROM fact_orders o LEFT JOIN (SELECT order_id,SUM(item_revenue) item_revenue FROM fact_order_items GROUP BY 1) i USING(order_id)
          LEFT JOIN fact_reviews r USING(order_id) WHERE o.is_delivered=1
        """).fetchone()
        top_categories = rows(con, (ROOT / "sql" / "08_category_analysis.sql").read_text().rstrip().rstrip(";") + " LIMIT 3")
        sellers = rows(con, (ROOT / "sql" / "07_seller_analysis.sql").read_text().rstrip().rstrip(";") + " LIMIT 3")
        category_issue = con.execute("""
          WITH x AS (SELECT p.category_name category, SUM(i.item_revenue) revenue, AVG(r.review_score) score, AVG(o.is_late) late
                     FROM fact_order_items i JOIN dim_product p USING(product_id) JOIN fact_orders o USING(order_id) LEFT JOIN fact_reviews r USING(order_id) GROUP BY 1),
          b AS (SELECT AVG(score) score_avg FROM x)
          SELECT category,revenue,score,late FROM x,b WHERE score < score_avg ORDER BY revenue DESC LIMIT 1
        """).fetchone()
        worst_state = con.execute("""
          SELECT c.customer_state, COUNT(*) orders, AVG(o.is_late) late_rate, AVG(o.delivery_days) days
          FROM fact_orders o JOIN dim_customer c USING(customer_id) WHERE o.is_delivered=1 GROUP BY 1 HAVING COUNT(*) >= 100 ORDER BY late_rate DESC LIMIT 1
        """).fetchone()
        repeat = con.execute("""
          WITH co AS (SELECT c.customer_unique_id,o.order_id FROM fact_orders o JOIN dim_customer c USING(customer_id)),
          f AS (SELECT customer_unique_id,COUNT(*) n FROM co GROUP BY 1), v AS (SELECT order_id,SUM(item_revenue) revenue FROM fact_order_items GROUP BY 1)
          SELECT CASE WHEN f.n>1 THEN 'repeat' ELSE 'one-time' END, AVG(v.revenue), AVG(r.review_score)
          FROM co JOIN f USING(customer_unique_id) LEFT JOIN v USING(order_id) LEFT JOIN fact_reviews r USING(order_id) GROUP BY 1
        """).fetchall()
    top = top_categories[0]
    repeat_map = {kind: (aov, score) for kind, aov, score in repeat}
    top_seller = sellers[0] if sellers else None
    summary = f"""# Executive Summary

## Business Problem

Identify categories, sellers, and regions that generate marketplace value while harming customer experience through delivery failures, freight, cancellations, or poor reviews.

## Dataset and Method

Analysis uses the downloaded Brazilian E-Commerce Public Dataset by Olist. Raw CSVs were retained, loaded into SQLite, quality-profiled, and modeled as separate order, item, payment, and review facts to avoid duplicate revenue.

## Five Important Findings

1. Delivered orders generated **R${gmv:,.2f}** of item revenue across **{orders:,} orders**; average review score was **{avg_review:.2f}** and the on-time rate was **{on_time:.2f}%**.
2. **{top[0]}** was the largest category at **R${top[2]:,.2f}** ({top[4]}% of item revenue), with a **{top[5]:.2f}** average review score and **{top[7]:.2f}%** late-delivery rate.
3. Among categories below the portfolio-average review score, **{category_issue[0]}** carried the most revenue (**R${category_issue[1]:,.2f}**) while scoring **{category_issue[2]:.2f}**; its late-delivery rate was **{category_issue[3]*100:.2f}%**.
4. **{worst_state[0]}** had the highest late-delivery rate among states with at least 100 delivered orders: **{worst_state[2]*100:.2f}%** across **{worst_state[1]:,} orders**, averaging **{worst_state[3]:.2f} delivery days**.
5. The top material-volume seller by Operational Attention Score was **{top_seller[0]}**: **{top_seller[2]:,} orders**, **R${top_seller[3]:,.2f} revenue**, **{top_seller[4]*100:.2f}%** late delivery, **{top_seller[6]*100:.2f}%** low-review rate, and a score of **{top_seller[8]:.2f}**.

## Management Recommendations

1. Put the top-ranked seller into a time-bound delivery and complaint root-cause review before expanding its order allocation.
2. Investigate the product, seller, and freight mix behind the highest-revenue below-average-review category.
3. Establish state-specific delivery monitoring for the worst-performing customer region before changing service promises.

## Assumptions and Limitations

Revenue is item-level GMV; payment value is a separate measure. Review analysis uses the latest review per order. The dataset is historical and anonymized, so causality and current operational performance cannot be inferred.

## Next Steps

Validate the Power BI report with current operational data, set seller service-level thresholds, and refresh the score monthly.
"""
    insights = "# Insights\n\n## Top categories\n\n| Category | Orders | Revenue | AOV | Revenue share | Avg review | 1-star rate | Late rate | Freight % | Revenue rank |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
    for r in top_categories:
        insights += "| " + " | ".join(str(x) for x in r) + " |\n"
    insights += "\n## Sellers needing operational attention\n\n| Seller | State | Orders | Revenue | Late rate | Cancellation rate | Low-review rate | Revenue contribution | Score | Rank |\n|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n"
    for r in sellers:
        insights += "| " + " | ".join(str(x) for x in r) + " |\n"
    (ROOT / "reports" / "executive_summary.md").write_text(summary, encoding="utf-8")
    (ROOT / "reports" / "insights.md").write_text(insights, encoding="utf-8")
    print("Generated executive_summary.md and insights.md")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
