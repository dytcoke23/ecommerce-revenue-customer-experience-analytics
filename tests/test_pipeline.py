import shutil
import sqlite3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests" / "fixtures" / "synthetic_olist"

def test_pipeline_loads_reconciles_and_exports(tmp_path):
    raw = tmp_path / "raw"
    shutil.copytree(FIXTURE, raw)
    database = tmp_path / "olist.sqlite"
    report = tmp_path / "quality.md"
    exports = tmp_path / "exports"
    subprocess.run([sys.executable, "src/load_data.py", "--raw-dir", str(raw), "--database", str(database)], cwd=ROOT, check=True)
    subprocess.run([sys.executable, "src/validate_data.py", "--database", str(database), "--report", str(report)], cwd=ROOT, check=True)
    subprocess.run([sys.executable, "src/export_powerbi_tables.py", "--database", str(database), "--output-dir", str(exports)], cwd=ROOT, check=True)
    assert "PASS" in report.read_text(encoding="utf-8")
    assert (exports / "fact_order_items.csv").exists()
    with sqlite3.connect(database) as con:
        assert con.execute("SELECT COUNT(*) FROM fact_orders").fetchone()[0] == 2
        assert con.execute("SELECT SUM(item_revenue) FROM fact_order_items").fetchone()[0] == 300
        assert con.execute("SELECT SUM(payment_value) FROM fact_payments").fetchone()[0] == 300

def test_sql_queries_execute_against_fixture(tmp_path):
    raw = tmp_path / "raw"
    shutil.copytree(FIXTURE, raw)
    database = tmp_path / "olist.sqlite"
    subprocess.run([sys.executable, "src/load_data.py", "--raw-dir", str(raw), "--database", str(database)], cwd=ROOT, check=True)
    with sqlite3.connect(database) as con:
        for filename in sorted((ROOT / "sql").glob("0[2-9]_*.sql")):
            con.executescript(filename.read_text(encoding="utf-8"))
