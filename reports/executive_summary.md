# Executive Summary

## Business Problem

Identify categories, sellers, and regions that generate marketplace value while harming customer experience through delivery failures, freight, cancellations, or poor reviews.

## Dataset and Method

Analysis uses the downloaded Brazilian E-Commerce Public Dataset by Olist. Raw CSVs were retained, loaded into SQLite, quality-profiled, and modeled as separate order, item, payment, and review facts to avoid duplicate revenue.

## Five Important Findings

1. Delivered orders generated **R$13,221,498.11** of item revenue across **96,478 orders**; average review score was **4.16** and the on-time rate was **91.89%**.
2. **health_beauty** was the largest category at **R$1,258,681.34** (9.26% of item revenue), with a **4.18** average review score and **8.77%** late-delivery rate.
3. Among categories below the portfolio-average review score, **watches_gifts** carried the most revenue (**R$1,205,005.68**) while scoring **4.02**; its late-delivery rate was **8.10%**.
4. **AL** had the highest late-delivery rate among states with at least 100 delivered orders: **23.93%** across **397 orders**, averaging **24.54 delivery days**.
5. The top material-volume seller by Operational Attention Score was **b1b3948701c5c72445495bd161b83a4c**: **18 orders**, **R$24,699.19 revenue**, **50.00%** late delivery, **77.78%** low-review rate, and a score of **43.09**.

## Management Recommendations

1. Put the top-ranked seller into a time-bound delivery and complaint root-cause review before expanding its order allocation.
2. Investigate the product, seller, and freight mix behind the highest-revenue below-average-review category.
3. Establish state-specific delivery monitoring for the worst-performing customer region before changing service promises.

## Assumptions and Limitations

Revenue is item-level GMV; payment value is a separate measure. Review analysis uses the latest review per order. The dataset is historical and anonymized, so causality and current operational performance cannot be inferred.

## Next Steps

Validate the Power BI report with current operational data, set seller service-level thresholds, and refresh the score monthly.
