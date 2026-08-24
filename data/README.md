# Data acquisition

This project analyzes the **Brazilian E-Commerce Public Dataset by Olist**. The real source files are intentionally not committed to this repository.

## Get the data

From the repository root, run:

```powershell
python src/download_data.py
```

The script first downloads the official Kaggle release, `olistbr/brazilian-ecommerce`. If Kaggle access is unavailable, it accepts a user-supplied, documented mirror archive through `--url` and rejects a download that does not match the expected schemas and row counts. The local `data/raw/download_manifest.json` records the URL and retrieval time; it is Git-ignored.

You may instead download the archive manually from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and extract these files into `data/raw/`:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `product_category_name_translation.csv`

## Data handling

Raw data stays unchanged. Local CSVs, archives, the SQLite database, and generated Power BI exports are excluded from Git. `tests/fixtures/synthetic_olist/` is a tiny **synthetic** fixture used only for automated tests; it is not Olist data and must never be used for portfolio findings.
