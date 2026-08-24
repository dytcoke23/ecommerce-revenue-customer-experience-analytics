# DAX Measures

Create measures in a dedicated `Measures` table. Format money as Brazilian Real or the report's selected currency, percentages as `0.0%`, and scores as `0.00`.

```DAX
Total Orders = DISTINCTCOUNT(fact_orders[order_id])
Delivered Orders = CALCULATE([Total Orders], fact_orders[is_delivered] = 1)
Cancelled Orders = CALCULATE([Total Orders], fact_orders[is_cancelled] = 1)
GMV = SUM(fact_order_items[item_revenue])
Payment Value = SUM(fact_payments[payment_value])
AOV = DIVIDE([GMV], [Total Orders])
Average Items per Order = DIVIDE(COUNTROWS(fact_order_items), [Total Orders])
Average Freight Cost = AVERAGE(fact_order_items[freight_cost])
Freight % of Item Value = DIVIDE(SUM(fact_order_items[freight_cost]), [GMV])
Average Review Score = AVERAGE(fact_reviews[review_score])
1-Star Review Rate = DIVIDE(CALCULATE(COUNTROWS(fact_reviews), fact_reviews[review_score] = 1), COUNTROWS(fact_reviews))
1-2 Star Review Rate = DIVIDE(CALCULATE(COUNTROWS(fact_reviews), fact_reviews[review_score] <= 2), COUNTROWS(fact_reviews))
4-5 Star Review Rate = DIVIDE(CALCULATE(COUNTROWS(fact_reviews), fact_reviews[review_score] >= 4), COUNTROWS(fact_reviews))
On-Time Delivery Rate = DIVIDE(CALCULATE([Total Orders], fact_orders[is_delivered] = 1, fact_orders[is_late] = 0), [Delivered Orders])
Late Delivery Rate = DIVIDE(CALCULATE([Total Orders], fact_orders[is_late] = 1), [Delivered Orders])
Average Delivery Days = AVERAGE(fact_orders[delivery_days])
Average Delay Days = AVERAGE(fact_orders[delay_days])
Cancellation Rate = DIVIDE([Cancelled Orders], [Total Orders])
Unique Customers = DISTINCTCOUNT(dim_customer[customer_unique_id])
Repeat Customer Rate =
VAR CustomersWithOrders = SUMMARIZE(fact_orders, dim_customer[customer_unique_id], "OrderCount", [Total Orders])
RETURN DIVIDE(COUNTROWS(FILTER(CustomersWithOrders, [OrderCount] > 1)), COUNTROWS(CustomersWithOrders))
Orders per Seller = DIVIDE(COUNTROWS(fact_order_items), DISTINCTCOUNT(dim_seller[seller_id]))
Revenue per Seller = DIVIDE([GMV], DISTINCTCOUNT(dim_seller[seller_id]))
Revenue by State = [GMV]
Monthly GMV Growth =
VAR PreviousGMV = CALCULATE([GMV], DATEADD(dim_date[date_key], -1, MONTH))
RETURN DIVIDE([GMV] - PreviousGMV, PreviousGMV)
GMV Prior Year = CALCULATE([GMV], SAMEPERIODLASTYEAR(dim_date[date_key]))
Rolling 3-Month GMV = CALCULATE([GMV], DATESINPERIOD(dim_date[date_key], MAX(dim_date[date_key]), -3, MONTH))
Seller Revenue Rank = RANKX(ALL(dim_seller[seller_id]), [GMV],, DESC, Dense)
Category Revenue Rank = RANKX(ALL(dim_product[category_name]), [GMV],, DESC, Dense)
Operational Attention Score =
VAR RevenueShare = DIVIDE([GMV], CALCULATE([GMV], ALL(dim_seller)))
VAR LowReviewRate = [1-2 Star Review Rate]
RETURN 100 * (0.35 * [Late Delivery Rate] + 0.30 * LowReviewRate + 0.20 * [Cancellation Rate] + 0.15 * RevenueShare)
```

Use the score only where seller order volume is at least 10; otherwise display `Insufficient volume`.
