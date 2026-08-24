"""Export the star-schema tables to CSV for Power BI Desktop."""
from __future__ import annotations

import argparse
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TABLES = ["dim_date", "dim_customer", "dim_product", "dim_seller", "dim_geography", "fact_orders", "fact_order_items", "fact_payments", "fact_reviews"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--database", type=Path, default=ROOT / "data" / "olist_analytics.sqlite")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "data" / "processed")
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(args.database) as connection:
        for table in TABLES:
            cursor = connection.execute(f"SELECT * FROM {table}")
            path = args.output_dir / f"{table}.csv"
            with path.open("w", encoding="utf-8", newline="") as handle:
                writer = csv.writer(handle)
                writer.writerow([item[0] for item in cursor.description])
                writer.writerows(cursor)
    print(f"Exported {len(TABLES)} Power BI tables to {args.output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
