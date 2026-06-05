"""
Unit tests for DebtRecord monthly projection behavior (DBT-FEAT-003).
Run from backend/ with: conda run -n finly pytest tests/test_debt_record_projection_service.py -v
"""
import os
import sys
from pathlib import Path
from uuid import uuid4

# Use a local SQLite database for deterministic service-level tests.
TEST_DB_PATH = Path(__file__).resolve().parent / "test_dbt_projection.db"
os.environ["DATABASE_URL"] = f"sqlite:///{TEST_DB_PATH.as_posix()}"

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pytest
import math

from database.database import Base, engine, SessionLocal, User, Role, BudgetItem, DebtRecord
from services.debt_record_service import DebtRecordService


@pytest.fixture(scope="module", autouse=True)
def setup_db():
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()

    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)
    engine.dispose()

    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()


@pytest.fixture(scope="function")
def seeded_user_id():
    db = SessionLocal()
    role = Role(name=f"WRITER_PROJ_{uuid4().hex[:8]}", description="Writer for projection tests")
    db.add(role)
    db.flush()

    user = User(
        username=f"projection_user_{role.id}",
        email=f"projection_user_{role.id}@test.local",
        hashed_password="hashed",
        is_active=True,
        is_locked=False,
    )
    user.roles = [role]
    db.add(user)
    db.commit()

    user_id = user.id
    db.close()
    return user_id


@pytest.fixture(scope="function")
def service():
    svc = DebtRecordService()
    try:
        yield svc
    finally:
        svc.close()


def _count_projection_months(record_id):
    db = SessionLocal()
    months = [
        row.version_source_month
        for row in db.query(BudgetItem)
        .filter(BudgetItem.debt_record_id == record_id)
        .order_by(BudgetItem.version_source_month.asc())
        .all()
    ]
    db.close()
    return months


def test_create_without_due_date_defaults_next_month_and_generates_12(service, seeded_user_id):
    rec = service.create_debt_record(
        {
            "debt_name": "TEST_12",
            "debt_type": "PERSONAL",
            "principal_amount": 1200000,
            "outstanding_amount": 1200000,
            "total_installments": 12,
            "current_installment": 1,
            "start_date": "2026-06-02",
        },
        user_id=seeded_user_id,
    )

    db = SessionLocal()
    row = db.query(DebtRecord).filter(DebtRecord.id == rec["id"]).first()
    db.close()

    assert str(row.due_date) == "2026-07-02"

    months = _count_projection_months(rec["id"])
    assert len(months) == 12
    assert months[0] == "2026-07"
    assert months[-1] == "2027-06"


def test_projection_count_matches_remaining_installments(service, seeded_user_id):
    rec = service.create_debt_record(
        {
            "debt_name": "TEST_REMAINING",
            "debt_type": "PERSONAL",
            "principal_amount": 600000,
            "outstanding_amount": 600000,
            "total_installments": 6,
            "current_installment": 3,
            "start_date": "2026-01-10",
        },
        user_id=seeded_user_id,
    )

    months = _count_projection_months(rec["id"])
    # total - current + 1 = 4
    assert len(months) == 4


def test_reconcile_restores_missing_projection_rows(service, seeded_user_id):
    rec = service.create_debt_record(
        {
            "debt_name": "TEST_RECONCILE",
            "debt_type": "PERSONAL",
            "principal_amount": 300000,
            "outstanding_amount": 300000,
            "total_installments": 6,
            "current_installment": 1,
            "start_date": "2026-03-01",
        },
        user_id=seeded_user_id,
    )

    db = SessionLocal()
    rows = (
        db.query(BudgetItem)
        .filter(BudgetItem.debt_record_id == rec["id"])
        .order_by(BudgetItem.version_source_month.asc())
        .all()
    )

    # Corrupt one projection row to simulate inconsistent historic data.
    db.delete(rows[-1])
    db.commit()
    db.close()

    result = service.get_debt_records_with_projection(user_id=seeded_user_id)
    target = next(r for r in result if r["id"] == rec["id"])

    assert target["projection_count"] == 6
    assert len(target.get("projections", [])) == 6


def test_projection_amount_applies_annual_interest_annuity(service, seeded_user_id):
    rec = service.create_debt_record(
        {
            "debt_name": "TEST_INTEREST_ANNUITY",
            "debt_type": "PERSONAL",
            "principal_amount": 5000000,
            "outstanding_amount": 5000000,
            "annual_interest_rate": 88,
            "total_installments": 12,
            "current_installment": 1,
            "start_date": "2026-06-01",
        },
        user_id=seeded_user_id,
    )

    records = service.get_debt_records_with_projection(user_id=seeded_user_id)
    target = next(r for r in records if r["id"] == rec["id"])
    first_projection = target["projection_current"]

    monthly_rate = 0.88 / 12.0
    n = 12
    expected_quota = 5000000 * monthly_rate / (1 - math.pow(1 + monthly_rate, -n))

    assert first_projection is not None
    assert first_projection["monto_total"] == pytest.approx(expected_quota, rel=1e-9)
