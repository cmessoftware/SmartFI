"""
Unit tests for services/month_service.py (exp-month-close feature).
Uses an in-memory SQLite DB to avoid touching the real PostgreSQL instance.
Run from backend/ with: conda run -n finly pytest tests/test_month_service.py -v
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import pytest
from datetime import datetime
from unittest.mock import patch, MagicMock

from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
# Use SQLite in-memory for unit tests
TEST_DB_URL = "sqlite:///:memory:"


@pytest.fixture(scope="function")
def db_session():
    """Provide a transactional SQLite session for each test."""
    # Patch DATABASE_URL before importing models
    with patch.dict(os.environ, {"DATABASE_URL": TEST_DB_URL}):
        from database.database import Base
        engine = create_engine(
            TEST_DB_URL,
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
        # SQLite FK support
        @event.listens_for(engine, "connect")
        def set_sqlite_pragma(dbapi_connection, _):
            cursor = dbapi_connection.cursor()
            cursor.execute("PRAGMA foreign_keys=ON")
            cursor.close()

        Base.metadata.create_all(bind=engine)
        TestingSession = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        session = TestingSession()
        try:
            yield session
        finally:
            session.close()
            Base.metadata.drop_all(bind=engine)
            engine.dispose()


@pytest.fixture()
def admin_user(db_session):
    """Create a minimal User row for use as admin."""
    from database.database import User, Role
    role = Role(name="ADMIN", description="Administrator")
    db_session.add(role)
    db_session.flush()

    user = User(
        username="test_admin",
        email="admin@test.com",
        hashed_password="hashed",
        is_active=True,
        is_locked=False,
    )
    user.roles = [role]
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture()
def writer_user(db_session):
    """Create a minimal User row for use as writer (non-admin)."""
    from database.database import User, Role
    role = Role(name="WRITER", description="Writer")
    db_session.add(role)
    db_session.flush()

    user = User(
        username="test_writer",
        email="writer@test.com",
        hashed_password="hashed",
        is_active=True,
        is_locked=False,
    )
    user.roles = [role]
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


# ---------------------------------------------------------------------------
# Patch log_event so it doesn't fail when AuditLog table isn't wired up
# ---------------------------------------------------------------------------
@pytest.fixture(autouse=True)
def mock_audit(monkeypatch):
    monkeypatch.setattr(
        "services.month_service.log_event",
        lambda *a, **kw: None,
    )


# ===========================================================================
# close_month()
# ===========================================================================

class TestCloseMonth:
    def test_close_open_month_creates_closed_period(self, db_session, admin_user):
        from services.month_service import close_month
        result = close_month("2025-04", admin_user.id, admin_user.username, db_session)

        assert result["status"] == "CLOSED"
        assert result["year_month"] == "2025-04"
        assert "snapshot" in result
        assert result["closed_by"] == admin_user.id

    def test_close_month_snapshot_has_correct_fields(self, db_session, admin_user):
        from services.month_service import close_month
        result = close_month("2025-05", admin_user.id, admin_user.username, db_session)

        snap = result["snapshot"]
        assert "total_income" in snap
        assert "total_expenses" in snap
        assert "net_balance" in snap
        assert "transaction_count" in snap
        assert snap["transaction_count"] == 0  # no transactions seeded

    def test_close_month_snapshot_totals_match_transactions(self, db_session, admin_user):
        from database.database import Transaction as DBTransaction, TransactionType, NecessityType, Category
        from services.month_service import close_month

        # Seed a category (required FK)
        cat = Category(name="Test Category June")
        db_session.add(cat)
        db_session.flush()

        # Seed 2 transactions for the same month
        t1 = DBTransaction(
            date="2025-06-10",
            amount=1000.0,
            detail="Salary",
            type=TransactionType.INGRESO,
            category_id=cat.id,
            necessity=NecessityType.NECESARIO,
            origin="MANUAL",
            user_id=admin_user.id,
        )
        t2 = DBTransaction(
            date="2025-06-15",
            amount=300.0,
            detail="Groceries",
            type=TransactionType.GASTO,
            category_id=cat.id,
            necessity=NecessityType.NECESARIO,
            origin="MANUAL",
            user_id=admin_user.id,
        )
        db_session.add_all([t1, t2])
        db_session.commit()

        result = close_month("2025-06", admin_user.id, admin_user.username, db_session)
        snap = result["snapshot"]

        assert snap["total_income"] == pytest.approx(1000.0)
        assert snap["total_expenses"] == pytest.approx(300.0)
        assert snap["net_balance"] == pytest.approx(700.0)
        assert snap["transaction_count"] == 2

    def test_close_already_closed_month_raises_400(self, db_session, admin_user):
        from fastapi import HTTPException
        from services.month_service import close_month

        close_month("2025-07", admin_user.id, admin_user.username, db_session)

        with pytest.raises(HTTPException) as exc_info:
            close_month("2025-07", admin_user.id, admin_user.username, db_session)

        assert exc_info.value.status_code == 400
        assert exc_info.value.detail["code"] == "MONTH_ALREADY_CLOSED"

    def test_close_month_invalid_format_raises_value_error(self, db_session, admin_user):
        from services.month_service import close_month

        with pytest.raises(ValueError):
            close_month("2025-13", admin_user.id, admin_user.username, db_session)


# ===========================================================================
# reopen_month()
# ===========================================================================

class TestReopenMonth:
    def _close(self, year_month, admin_user, db_session):
        from services.month_service import close_month
        close_month(year_month, admin_user.id, admin_user.username, db_session)

    def test_reopen_closed_month_sets_reopened_status(self, db_session, admin_user):
        from services.month_service import reopen_month
        self._close("2025-08", admin_user, db_session)

        result = reopen_month(
            "2025-08", admin_user.id, admin_user.username,
            "Corrección de datos bancarios del mes", db_session
        )

        assert result["status"] == "REOPENED"
        assert result["reopen_reason"] == "Corrección de datos bancarios del mes"
        assert result["reopened_by"] == admin_user.id

    def test_reopen_with_short_reason_raises_400(self, db_session, admin_user):
        from fastapi import HTTPException
        from services.month_service import reopen_month
        self._close("2025-09", admin_user, db_session)

        with pytest.raises(HTTPException) as exc_info:
            reopen_month("2025-09", admin_user.id, admin_user.username, "corto", db_session)

        assert exc_info.value.status_code == 400
        assert exc_info.value.detail["code"] == "REASON_REQUIRED"

    def test_reopen_with_empty_reason_raises_400(self, db_session, admin_user):
        from fastapi import HTTPException
        from services.month_service import reopen_month
        self._close("2025-10", admin_user, db_session)

        with pytest.raises(HTTPException) as exc_info:
            reopen_month("2025-10", admin_user.id, admin_user.username, "", db_session)

        assert exc_info.value.status_code == 400
        assert exc_info.value.detail["code"] == "REASON_REQUIRED"

    def test_reopen_open_month_raises_400_invalid_transition(self, db_session, admin_user):
        from fastapi import HTTPException
        from services.month_service import reopen_month

        # Month has never been closed
        with pytest.raises(HTTPException) as exc_info:
            reopen_month(
                "2025-11", admin_user.id, admin_user.username,
                "Motivo suficientemente largo aqui", db_session
            )

        assert exc_info.value.status_code == 400
        assert exc_info.value.detail["code"] == "INVALID_STATE_TRANSITION"

    def test_reopen_trimmed_reason_too_short_raises_400(self, db_session, admin_user):
        """Reason with whitespace padding shouldn't bypass the 10-char check."""
        from fastapi import HTTPException
        from services.month_service import reopen_month
        self._close("2025-12", admin_user, db_session)

        with pytest.raises(HTTPException) as exc_info:
            reopen_month(
                "2025-12", admin_user.id, admin_user.username,
                "   short   ", db_session
            )

        assert exc_info.value.status_code == 400
        assert exc_info.value.detail["code"] == "REASON_REQUIRED"


# ===========================================================================
# validate_period_for_mutation()
# ===========================================================================

class TestValidatePeriodForMutation:
    def _close_month(self, year_month, admin_user, db_session):
        from services.month_service import close_month
        close_month(year_month, admin_user.id, admin_user.username, db_session)

    def test_open_period_allows_non_admin(self, db_session):
        from services.month_service import validate_period_for_mutation
        # Should not raise
        validate_period_for_mutation("2026-01", is_admin=False, origin="MANUAL", db=db_session)

    def test_open_period_allows_admin(self, db_session):
        from services.month_service import validate_period_for_mutation
        # Should not raise
        validate_period_for_mutation("2026-02", is_admin=True, origin="MANUAL", db=db_session)

    def test_unknown_period_allows_non_admin(self, db_session):
        """Period with no DB row is treated as OPEN → allowed."""
        from services.month_service import validate_period_for_mutation
        validate_period_for_mutation("2030-01", is_admin=False, origin="MANUAL", db=db_session)

    def test_closed_period_blocks_non_admin(self, db_session, admin_user):
        from fastapi import HTTPException
        from services.month_service import validate_period_for_mutation
        self._close_month("2026-03", admin_user, db_session)

        with pytest.raises(HTTPException) as exc_info:
            validate_period_for_mutation("2026-03", is_admin=False, origin="MANUAL", db=db_session)

        assert exc_info.value.status_code == 403
        assert exc_info.value.detail["code"] == "MONTH_CLOSED"

    def test_closed_period_allows_admin(self, db_session, admin_user):
        from services.month_service import validate_period_for_mutation
        self._close_month("2026-04", admin_user, db_session)

        # Should not raise
        validate_period_for_mutation("2026-04", is_admin=True, origin="MANUAL", db=db_session)

    def test_closed_period_allows_admin_bank_adjustment(self, db_session, admin_user):
        from services.month_service import validate_period_for_mutation
        self._close_month("2026-05", admin_user, db_session)

        # Should not raise
        validate_period_for_mutation(
            "2026-05", is_admin=True, origin="bank_adjustment", db=db_session
        )

    def test_closed_period_blocks_non_admin_even_bank_adjustment(self, db_session, admin_user):
        """bank_adjustment origin does NOT bypass for non-admins."""
        from fastapi import HTTPException
        from services.month_service import validate_period_for_mutation
        self._close_month("2026-06", admin_user, db_session)

        with pytest.raises(HTTPException) as exc_info:
            validate_period_for_mutation(
                "2026-06", is_admin=False, origin="bank_adjustment", db=db_session
            )

        assert exc_info.value.status_code == 403

    def test_reopened_period_allows_non_admin(self, db_session, admin_user):
        from services.month_service import validate_period_for_mutation, reopen_month
        self._close_month("2026-07", admin_user, db_session)
        reopen_month(
            "2026-07", admin_user.id, admin_user.username,
            "Reapertura por corrección necesaria de datos", db_session
        )

        # Should not raise — REOPENED is treated as open
        validate_period_for_mutation("2026-07", is_admin=False, origin="MANUAL", db=db_session)


# ===========================================================================
# open_month() / carryover / clone
# ===========================================================================

class TestOpenMonthRollover:
    def _seed_category(self, db_session, name):
        from database.database import Category
        cat = Category(name=name)
        db_session.add(cat)
        db_session.flush()
        return cat

    def test_open_month_with_closed_prior_creates_carryover_and_balance(self, db_session, admin_user):
        from services.month_service import close_month, open_month
        from database.database import Transaction as DBTransaction, TransactionType, NecessityType, MonthlyBalance

        cat = self._seed_category(db_session, "Test Rollover Cat")
        db_session.add(DBTransaction(
            user_id=admin_user.id,
            date="2026-08-10",
            type=TransactionType.INGRESO,
            category_id=cat.id,
            amount=1000.0,
            necessity=NecessityType.NECESARIO,
            payment_method="Débito",
            detail="Ingreso Agosto",
            origin="MANUAL",
        ))
        db_session.add(DBTransaction(
            user_id=admin_user.id,
            date="2026-08-12",
            type=TransactionType.GASTO,
            category_id=cat.id,
            amount=300.0,
            necessity=NecessityType.NECESARIO,
            payment_method="Débito",
            detail="Gasto Agosto",
            origin="MANUAL",
        ))
        db_session.commit()

        close_month("2026-08", admin_user.id, admin_user.username, db_session)

        result = open_month("2026-09", admin_user.id, admin_user.username, db_session)

        assert result["status"] == "OPEN"
        assert result["carryover"] is not None
        assert result["carryover"]["net_balance"] == pytest.approx(700.0)

        mb = db_session.query(MonthlyBalance).filter(
            MonthlyBalance.user_id == admin_user.id,
            MonthlyBalance.source_month == "2026-08",
            MonthlyBalance.target_month == "2026-09",
        ).first()
        assert mb is not None
        assert mb.balance_amount == pytest.approx(700.0)

    def test_open_month_blocks_when_prior_exists_but_not_closed(self, db_session, admin_user):
        from services.month_service import open_month
        from database.database import MonthlyPeriod, MonthPeriodStatus
        from fastapi import HTTPException

        # Create prior month explicitly open (not closed)
        db_session.add(MonthlyPeriod(year_month="2026-10", user_id=admin_user.id, status=MonthPeriodStatus.OPEN))
        db_session.commit()

        with pytest.raises(HTTPException) as exc_info:
            open_month("2026-11", admin_user.id, admin_user.username, db_session)

        assert exc_info.value.status_code == 400
        assert exc_info.value.detail["code"] == "PRIOR_MONTH_NOT_CLOSED"

    def test_open_month_without_prior_period_still_opens(self, db_session, admin_user):
        from services.month_service import open_month

        result = open_month("2030-01", admin_user.id, admin_user.username, db_session)

        assert result["status"] == "OPEN"
        assert result["carryover"] is None

    def test_clone_budget_items_preserves_traceability(self, db_session, admin_user):
        from services.month_service import clone_budget_items
        from database.database import BudgetItem, DebtStatus, BudgetType, FlowType

        item = BudgetItem(
            user_id=admin_user.id,
            fecha="2027-01-05",
            tipo="Servicio",
            categoria="Hogar",
            monto_total=250.0,
            monto_pagado=0.0,
            detalle="Internet",
            fecha_vencimiento="2027-01-20",
            status=DebtStatus.PENDIENTE,
            tipo_presupuesto=BudgetType.OBLIGATION,
            tipo_flujo=FlowType.GASTO,
            monto_ejecutado=0.0,
            estimated_payment=250.0,
        )
        db_session.add(item)
        db_session.commit()

        cloned = clone_budget_items("2027-01", "2027-02", admin_user.id, db_session)

        assert len(cloned) == 1
        assert cloned[0].cloned_from_item_id == item.id
        assert cloned[0].version_source_month == "2027-01"
        assert cloned[0].base_cloned == pytest.approx(250.0)
        assert cloned[0].fecha.startswith("2027-02")
