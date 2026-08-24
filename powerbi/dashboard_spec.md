# Power BI Report Specification

## Shared design

Use off-white canvas, charcoal text, one deep-blue primary accent, muted teal for positive delivery, and restrained amber/red for risks. Add page navigation buttons, synchronized Date/State/Category/Seller slicers, a last-refresh label, and concise custom tooltips. Avoid rainbow palettes and implicit aggregations.

## 1. Executive Overview

Cards: GMV, Total Orders, AOV, On-Time Delivery Rate, Average Review Score, Repeat Customer Rate. Visuals: monthly GMV line, category revenue bar, customer-state revenue map/bar, delivery-status breakdown, review distribution. Include the shared slicers.

## 2. Customer Experience

Review score trend, category review ranking, late-versus-on-time review comparison, 1-star category contribution, delivery-days versus review-score scatter, and customer-region comparison. Tooltip: orders, review score, one-star rate, late rate, freight ratio.

## 3. Logistics & Delivery

Cards: on-time rate, average delay, delivery days, freight. Visuals: late-delivery trend, worst customer states, category delivery performance, and freight burden. Use a bookmark to toggle rate/count perspective.

## 4. Seller Performance

Seller table with revenue, order volume, late rate, review score, cancellation rate, attention score, and rank. Apply red conditional formatting to material high-risk sellers. Configure drillthrough on `seller_id` to a Seller Detail page with monthly trend, category mix, delivery/review breakdown, and a Back button.

## 5. Category Performance

Show revenue, orders, AOV, review score, delay, freight ratio, ranking, and category concentration. Highlight categories with above-median revenue and below-average review score or above-average late rate. Use a detail tooltip showing top sellers and customer states.

## Manual build checklist

1. Load processed CSVs with Power Query; assign data types and use `dim_date` as Date table.
2. Create relationships exactly as `data_model.md` specifies, with single-direction filtering.
3. Create DAX measures and hide numeric source columns where a measure should be used.
4. Create the five pages, drillthrough page, tooltips, bookmarks, and synced slicers.
5. Refresh from real Olist exports, validate KPI totals against `reports/data_quality_summary.md`, and export screenshots.
