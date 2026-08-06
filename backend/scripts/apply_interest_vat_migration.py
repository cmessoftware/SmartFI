"""One-off helper: ensure interest_vat_rate column exists and reconcile debt projections."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import inspect, text
from database.database import engine, DebtRecord
from services.debt_record_service import DebtRecordService


def main():
    insp = inspect(engine)
    cols = {c["name"] for c in insp.get_columns("debt_records")}

    if "interest_vat_rate" not in cols:
        print("Adding interest_vat_rate column...")
        with engine.begin() as conn:
            conn.execute(
                text(
                    "ALTER TABLE debt_records "
                    "ADD COLUMN interest_vat_rate DOUBLE PRECISION NOT NULL DEFAULT 21"
                )
            )
        print("Column added.")
    else:
        print("interest_vat_rate column already exists.")

    svc = DebtRecordService()
    records = svc.db.query(DebtRecord).all()
    for record in records:
        if getattr(record, "interest_vat_rate", None) is None:
            record.interest_vat_rate = 21.0
        svc._upsert_budget_projection(record)
        svc.db.commit()
        print(f"Reconciled debt #{record.id} {record.debt_name}")

    svc.close()
    print("Done.")


if __name__ == "__main__":
    main()
