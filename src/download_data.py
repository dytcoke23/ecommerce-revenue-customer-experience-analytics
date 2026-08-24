"""Download and verify the public Olist CSV release without committing it to Git."""
from __future__ import annotations

import argparse
import csv
import json
import shutil
import sys
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
OFFICIAL_URL = "https://www.kaggle.com/api/v1/datasets/download/olistbr/brazilian-ecommerce"
REQUIRED = {
    "olist_orders_dataset.csv": 99441,
    "olist_order_items_dataset.csv": 112650,
    "olist_order_payments_dataset.csv": 103886,
    "olist_order_reviews_dataset.csv": 99224,
    "olist_customers_dataset.csv": 99441,
    "olist_products_dataset.csv": 32951,
    "olist_sellers_dataset.csv": 3095,
    "olist_geolocation_dataset.csv": 1000163,
    "product_category_name_translation.csv": 71,
}


def row_count(path: Path) -> int:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle)
        next(reader, None)
        return sum(1 for _ in reader)


def validate(directory: Path) -> None:
    missing = [name for name in REQUIRED if not (directory / name).is_file()]
    if missing:
        raise ValueError(f"Missing required files: {', '.join(missing)}")
    unexpected = []
    for name, expected in REQUIRED.items():
        actual = row_count(directory / name)
        if actual != expected:
            unexpected.append(f"{name}: expected {expected:,}, found {actual:,}")
    if unexpected:
        raise ValueError("Source row-count validation failed: " + "; ".join(unexpected))


def download(url: str, destination: Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(request, timeout=120) as response, destination.open("wb") as out:
        shutil.copyfileobj(response, out)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default=OFFICIAL_URL, help="Override the source archive URL.")
    parser.add_argument("--verify-only", action="store_true")
    args = parser.parse_args()
    RAW.mkdir(parents=True, exist_ok=True)
    if args.verify_only:
        validate(RAW)
        print("Olist source files validated.")
        return 0

    archive = RAW / "olist_source.zip"
    try:
        print(f"Downloading Olist dataset from {args.url}")
        download(args.url, archive)
        with zipfile.ZipFile(archive) as bundle:
            members = {Path(member).name: member for member in bundle.namelist()}
            missing = set(REQUIRED) - set(members)
            if missing:
                raise ValueError("Archive does not contain required Olist files: " + ", ".join(sorted(missing)))
            for name in REQUIRED:
                with bundle.open(members[name]) as source, (RAW / name).open("wb") as target:
                    shutil.copyfileobj(source, target)
        validate(RAW)
        (RAW / "download_manifest.json").write_text(json.dumps({
            "source_url": args.url,
            "retrieved_at_utc": datetime.now(timezone.utc).isoformat(),
            "validation": "filenames and canonical row counts matched",
        }, indent=2), encoding="utf-8")
        print("Downloaded and validated the nine Olist source CSV files.")
        return 0
    except Exception as exc:
        print(f"Download failed: {exc}", file=sys.stderr)
        print("Use --url with a verified mirror archive, or manually place the nine CSVs in data/raw/.", file=sys.stderr)
        return 1
    finally:
        if archive.exists():
            archive.unlink()


if __name__ == "__main__":
    raise SystemExit(main())
