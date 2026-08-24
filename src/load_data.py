"""Load raw Olist CSVs into SQLite and materialize the analytical star model."""
from __future__ import annotations

import argparse
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_RAW = ROOT / "data" / "raw"
DEFAULT_DB = ROOT / "data" / "olist_analytics.sqlite"
TABLES = {
    "olist_orders_dataset.csv": "raw_orders",
    "olist_order_items_dataset.csv": "raw_order_items",
    "olist_order_payments_dataset.csv": "raw_payments",
    "olist_order_reviews_dataset.csv": "raw_reviews",
    "olist_customers_dataset.csv": "raw_customers",
    "olist_products_dataset.csv": "raw_products",
    "olist_sellers_dataset.csv": "raw_sellers",
    "olist_geolocation_dataset.csv": "raw_geolocation",
    "product_category_name_translation.csv": "raw_category_translation",
}


def quote(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def load_csv(connection: sqlite3.Connection, path: Path, table: str) -> None:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames:
            raise ValueError(f"No header found in {path.name}")
        columns = reader.fieldnames
        connection.execute(f"DROP TABLE IF EXISTS {quote(table)}")
        connection.execute(f"CREATE TABLE {quote(table)} ({', '.join(quote(c) + ' TEXT' for c in columns)})")
        statement = f"INSERT INTO {quote(table)} ({', '.join(map(quote, columns))}) VALUES ({', '.join('?' for _ in columns)})"
        rows = ([record.get(column, "") or None for column in columns] for record in reader)
        connection.executemany(statement, rows)


def run_sql(connection: sqlite3.Connection, filename: str) -> None:
    connection.executescript((ROOT / "sql" / filename).read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-dir", type=Path, default=DEFAULT_RAW)
    parser.add_argument("--database", type=Path, default=DEFAULT_DB)
    args = parser.parse_args()
    missing = [name for name in TABLES if not (args.raw_dir / name).is_file()]
    if missing:
        raise SystemExit("Missing Olist CSVs: " + ", ".join(missing) + ". Run src/download_data.py first.")
    args.database.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(args.database) as connection:
        connection.execute("PRAGMA foreign_keys = ON")
        for filename, table in TABLES.items():
            load_csv(connection, args.raw_dir / filename, table)
        run_sql(connection, "01_create_schema.sql")
        run_sql(connection, "03_cleaning_views.sql")
        connection.execute("ANALYZE")
    print(f"Loaded raw data and analytical model into {args.database}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
