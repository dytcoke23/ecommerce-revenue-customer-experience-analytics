# E-commerce Revenue & Customer Experience Analytics

**Which high-revenue marketplace categories, sellers, and customer regions need intervention because delivery, freight, cancellations, or reviews are eroding customer experience?**

> Dashboard preview: add [`screenshots/01_executive_overview.png`](screenshots/README.md) after building the documented Power BI report from the real dataset.

## Executive summary

This project turns Olist's relational marketplace data into a decision-ready model: revenue is analyzed alongside delivery reliability, freight burden, cancellations, and customer reviews. It is designed to identify operational priorities—not merely describe sales.

## Business questions

- What categories and states generate the most revenue?
- Where do strong revenue, late delivery, freight burden, cancellations, and poor reviews overlap?
- Which sellers warrant corrective action, and why?
- How do repeat customers differ in AOV and review patterns?

## Dataset and model

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Real source data is downloaded locally and excluded from Git; see [`data/README.md`](data/README.md).

```text
dim_date ───────< fact_orders >────── dim_customer
                    │      │
                    │      └──────< fact_reviews
                    ├──────< fact_payments
                    └──────< fact_order_items >──── dim_product
                                             └────── dim_seller
```

`fact_orders` is one row per order, `fact_order_items` one row per order item, and `fact_payments` one row per payment sequence. Facts are never joined at incompatible grain for additive metrics.

## Tools used

SQLite · SQL · Python · Power BI · Power Query · DAX · Git/GitHub

## What this repository demonstrates

- Raw-data preservation, quality profiling, and reconciliation checks
- A star-style analytical model with explicit fact grain
- Business SQL using CTEs, windows, rankings, growth, rolling averages, and conditional logic
- KPI design and a transparent seller Operational Attention Score
- A five-page Power BI design with drillthrough and usable executive storytelling

## Reproduce

```powershell
python src/download_data.py
python src/load_data.py
python src/validate_data.py
python src/export_powerbi_tables.py
python src/generate_reports.py
python -m pytest
```

Then follow [`powerbi/dashboard_spec.md`](powerbi/dashboard_spec.md) in Power BI Desktop. Use `data/processed/` as the import location.

## Repository structure

```text
data/       source-data instructions and generated local outputs
sql/        schema, quality checks, KPI and decision queries
src/        download, load, validate, export, and report scripts
powerbi/    semantic model, DAX, and report specifications
reports/    data dictionary, quality results, findings, executive summary
tests/      synthetic-fixture regression tests
```

## Limitations

The historical, anonymized Olist data supports prioritization, not causal proof or live operating decisions. A `.pbix` is deliberately not claimed or included; desktop report assembly is manual and fully specified.
