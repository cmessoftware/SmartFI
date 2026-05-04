"""
Integration tests for month-close API endpoints (exp-month-close feature).
Uses FastAPI TestClient with an in-memory SQLite DB and overridden auth.
Run from backend/ with: conda run -n finly pytest tests/test_month_endpoints.py -v
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import pytest
from unittest.mock import patch

from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient  # re-exports starlette TestClient

TEST_DB_URL = "sqlite:///:memory:"


# ---------------------------------------------------------------------------
# DB + App fixtures
# ---------------------------------------------------------------------------

@pytest.fixture(scope="module")
def test_engine():
    with patch.dict(os.environ, {"DATABASE_URL": TEST_DB_URL}):
        from database.database import Base
        engine = create_engine(
            TEST_DB_URL,
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )

        @event.listens_for(engine, "connect")
        def set_sqlite_pragma(dbapi_connection, _):
            cursor = dbapi_connection.cursor()
            cursor.execute("PRAGMA foreign_keys=ON")
            cursor.close()

        Base.metadata.create_all(bind=engine)
        yield engine
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


@pytest.fixture(scope="module")
def TestingSessionLocal(test_engine):
    return sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(scope="module")
def admin_user_obj(TestingSessionLocal):
    """Seed an admin user once per module."""
    from database.database import User, Role
    db = TestingSessionLocal()
    role = Role(name="ADMIN", description="Administrator")
    db.add(role)
    db.flush()
    user = User(
        username="int_admin",
        email="int_admin@test.com",
        hashed_password="hashed",
        is_active=True,
        is_locked=False,
    )
    user.roles = [role]
    db.add(user)
    db.commit()
    db.refresh(user)
    db.close()
    return user


@pytest.fixture(scope="module")
def writer_user_obj(TestingSessionLocal):
    """Seed a writer (non-admin) user once per module."""
    from database.database import User, Role
    db = TestingSessionLocal()
    role = Role(name="WRITER", description="Writer")
    db.add(role)
    db.flush()
    user = User(
        username="int_writer",
        email="int_writer@test.com",
        hashed_password="hashed",
        is_active=True,
        is_locked=False,
    )
    user.roles = [role]
    db.add(user)
    db.commit()
    db.refresh(user)
    db.close()
    return user


@pytest.fixture(scope="module")
def client(TestingSessionLocal, admin_user_obj, writer_user_obj):
    """
    Return a TestClient with:
    - DB dependency overridden to use in-memory SQLite
    - audit log_event patched out
    """
    with patch("services.month_service.log_event", lambda *a, **kw: None):
        from main import app
        from database.database import get_db

        def override_get_db():
            db = TestingSessionLocal()
            try:
                yield db
            finally:
                db.close()

        app.dependency_overrides[get_db] = override_get_db
        with TestClient(app, raise_server_exceptions=True) as c:
            yield c
        app.dependency_overrides.clear()


# ---------------------------------------------------------------------------
# Auth helpers — inject users directly via dependency override
# ---------------------------------------------------------------------------

def make_auth_headers_for(app, user_obj, TestingSessionLocal):
    """Override get_current_user so the endpoint sees the given user."""
    from security.auth_dependencies import get_current_user, require_role
    from main import app as _app

    # Build a stub that returns user_obj freshly loaded from the test DB
    def override_current_user():
        db = TestingSessionLocal()
        from database.database import User
        u = db.query(User).filter(User.id == user_obj.id).first()
        db.close()
        return u

    _app.dependency_overrides[get_current_user] = override_current_user
    # Also override require_role factories that depend on get_current_user
    # by injecting the user directly into all role-checker slots
    return {}  # no headers needed when dependency is overridden


# ---------------------------------------------------------------------------
# Simpler approach: override app deps per test via context managers
# ---------------------------------------------------------------------------

@pytest.fixture()
def as_admin(client, admin_user_obj, TestingSessionLocal):
    """Context that makes all protected endpoints see admin_user_obj."""
    from main import app
    from security.auth_dependencies import get_current_user

    def override():
        db = TestingSessionLocal()
        from database.database import User
        u = db.query(User).filter(User.id == admin_user_obj.id).first()
        db.close()
        return u

    app.dependency_overrides[get_current_user] = override
    yield client
    # Restore only get_current_user; leave get_db in place
    app.dependency_overrides.pop(get_current_user, None)


@pytest.fixture()
def as_writer(client, writer_user_obj, TestingSessionLocal):
    """Context that makes all protected endpoints see writer_user_obj (non-admin)."""
    from main import app
    from security.auth_dependencies import get_current_user

    def override():
        db = TestingSessionLocal()
        from database.database import User
        u = db.query(User).filter(User.id == writer_user_obj.id).first()
        db.close()
        return u

    app.dependency_overrides[get_current_user] = override
    yield client
    app.dependency_overrides.pop(get_current_user, None)


# ===========================================================================
# POST /api/months/{year_month}/close
# ===========================================================================

class TestClosePeriodEndpoint:
    MONTH = "2025-04"

    def test_admin_can_close_open_month(self, as_admin):
        resp = as_admin.post(f"/api/months/{self.MONTH}/close")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "CLOSED"
        assert data["year_month"] == self.MONTH
        assert "snapshot" in data

    def test_admin_close_already_closed_returns_400(self, as_admin):
        resp = as_admin.post(f"/api/months/{self.MONTH}/close")
        assert resp.status_code == 400
        assert resp.json()["detail"]["code"] == "MONTH_ALREADY_CLOSED"

    def test_non_admin_close_returns_403(self, as_writer):
        resp = as_writer.post(f"/api/months/2025-05/close")
        assert resp.status_code == 403

    def test_invalid_month_format_returns_error(self, as_admin):
        """Invalid format causes ValueError from service layer (unhandled → raises in test)."""
        with pytest.raises(Exception):
            as_admin.post("/api/months/invalid-month/close")


# ===========================================================================
# POST /api/months/{year_month}/reopen
# ===========================================================================

class TestReopenPeriodEndpoint:
    MONTH = "2025-06"
    VALID_REASON = "Corrección de datos bancarios del mes de junio"

    @pytest.fixture(autouse=True)
    def ensure_closed(self, as_admin):
        """Make sure MONTH is closed before each test in this class."""
        from main import app
        from database.database import get_db, MonthlyPeriod, MonthPeriodStatus
        from datetime import datetime

        db_override = app.dependency_overrides.get(get_db)
        if db_override:
            gen = db_override()
            db = next(gen)
            period = db.query(MonthlyPeriod).filter(
                MonthlyPeriod.year_month == self.MONTH
            ).first()
            if not period or period.status != MonthPeriodStatus.CLOSED:
                # close it via the API
                as_admin.post(f"/api/months/{self.MONTH}/close")
            try:
                next(gen)
            except StopIteration:
                pass

    def test_admin_reopen_with_valid_reason(self, as_admin):
        resp = as_admin.post(
            f"/api/months/{self.MONTH}/reopen",
            json={"reason": self.VALID_REASON},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "REOPENED"
        assert data["reopen_reason"] == self.VALID_REASON

    def test_admin_reopen_with_short_reason_returns_400(self, as_admin):
        # First re-close so state is CLOSED
        as_admin.post(f"/api/months/{self.MONTH}/close")
        resp = as_admin.post(
            f"/api/months/{self.MONTH}/reopen",
            json={"reason": "corto"},
        )
        assert resp.status_code == 400
        assert resp.json()["detail"]["code"] == "REASON_REQUIRED"

    def test_non_admin_reopen_returns_403(self, as_writer):
        resp = as_writer.post(
            f"/api/months/{self.MONTH}/reopen",
            json={"reason": self.VALID_REASON},
        )
        assert resp.status_code == 403

    def test_reopen_open_month_returns_400(self, as_admin):
        resp = as_admin.post(
            "/api/months/2025-07/reopen",
            json={"reason": self.VALID_REASON},
        )
        assert resp.status_code == 400
        assert resp.json()["detail"]["code"] == "INVALID_STATE_TRANSITION"


# ===========================================================================
# GET /api/months/{year_month}/status
# ===========================================================================

class TestGetMonthStatusEndpoint:
    def test_status_of_unknown_month_returns_open(self, as_admin):
        resp = as_admin.get("/api/months/2030-01/status")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "OPEN"
        assert data["year_month"] == "2030-01"

    def test_status_of_closed_month_returns_closed_with_snapshot(self, as_admin):
        # Close a fresh month
        as_admin.post("/api/months/2025-08/close")
        resp = as_admin.get("/api/months/2025-08/status")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "CLOSED"
        assert "snapshot" in data
        snap = data["snapshot"]
        assert "total_income" in snap
        assert "total_expenses" in snap
        assert "net_balance" in snap

    def test_status_requires_auth(self, client):
        """Without auth override, endpoint should reject (401/403)."""
        resp = client.get("/api/months/2025-01/status")
        assert resp.status_code in (401, 403)

    def test_writer_can_read_status(self, as_writer):
        """GET status is accessible to all authenticated users."""
        resp = as_writer.get("/api/months/2030-02/status")
        assert resp.status_code == 200


# ===========================================================================
# GET /api/months?include_status=true
# ===========================================================================

class TestListMonthsEndpoint:
    def test_list_months_returns_array(self, as_admin):
        resp = as_admin.get("/api/months?include_status=true")
        assert resp.status_code == 200
        assert isinstance(resp.json(), list)

    def test_list_months_without_include_status_returns_empty(self, as_admin):
        resp = as_admin.get("/api/months")
        assert resp.status_code == 200
        assert resp.json() == []

    def test_list_months_includes_known_periods(self, as_admin):
        # Ensure at least one period exists (from previous tests)
        as_admin.post("/api/months/2025-09/close")
        resp = as_admin.get("/api/months?include_status=true")
        assert resp.status_code == 200
        months = resp.json()
        assert len(months) >= 1
        # Every item should have at minimum year_month and status
        for m in months:
            assert "year_month" in m
            assert "status" in m

    def test_writer_can_list_months(self, as_writer):
        resp = as_writer.get("/api/months?include_status=true")
        assert resp.status_code == 200


# ===========================================================================
# POST /api/months + carryover and lineage endpoints
# ===========================================================================

class TestOpenMonthAndCarryoverEndpoints:
    def _seed_tx_direct(self, TestingSessionLocal, admin_user_obj, year_month, amount, tx_type="INGRESO"):
        """Insert a transaction directly into the test DB (bypasses API service singletons)."""
        from database.database import (
            Transaction as DBTx, TransactionType, NecessityType, Category,
        )
        db = TestingSessionLocal()
        cat = db.query(Category).filter(Category.name == "Test").first()
        if not cat:
            cat = Category(name="Test")
            db.add(cat)
            db.flush()
        t = DBTx(
            date=f"{year_month}-10",
            amount=float(amount),
            type=TransactionType.INGRESO if tx_type == "INGRESO" else TransactionType.GASTO,
            category_id=cat.id,
            necessity=NecessityType.NECESARIO,
            payment_method="Débito",
            detail=f"Seed {year_month}",
            origin="MANUAL",
            user_id=admin_user_obj.id,
        )
        db.add(t)
        db.commit()
        db.close()

    def test_open_month_creates_carryover_when_prior_closed(
        self, as_admin, TestingSessionLocal, admin_user_obj
    ):
        # Build prior month snapshot directly in test DB: +1000 -300 = +700
        self._seed_tx_direct(TestingSessionLocal, admin_user_obj, "2025-10", 1000, "INGRESO")
        self._seed_tx_direct(TestingSessionLocal, admin_user_obj, "2025-10", 300, "GASTO")
        close_resp = as_admin.post("/api/months/2025-10/close")
        assert close_resp.status_code == 200

        open_resp = as_admin.post("/api/months", json={
            "year_month": "2025-11",
            "include_carryover": True,
            "include_budget_clone": False,
        })
        assert open_resp.status_code == 200
        data = open_resp.json()
        assert data["status"] == "OPEN"
        assert data["carryover"] is not None
        assert data["carryover"]["net_balance"] == pytest.approx(700.0)

        carry_resp = as_admin.get("/api/months/2025-11/carryover")
        assert carry_resp.status_code == 200
        carry = carry_resp.json()
        assert carry["source_month"] == "2025-10"
        assert carry["target_month"] == "2025-11"
        assert carry["balance_amount"] == pytest.approx(700.0)

    def test_open_month_fails_if_prior_not_closed(self, as_admin):
        # create open prior period (2031-04) by opening it directly
        open_prior = as_admin.post("/api/months", json={
            "year_month": "2031-04",
            "include_carryover": False,
            "include_budget_clone": False,
        })
        assert open_prior.status_code == 200

        resp = as_admin.post("/api/months", json={
            "year_month": "2031-05",
            "include_carryover": True,
            "include_budget_clone": False,
        })
        assert resp.status_code == 400
        assert resp.json()["detail"]["code"] == "PRIOR_MONTH_NOT_CLOSED"

    def test_budget_items_endpoint_supports_clone_info_and_lineage(
        self, as_admin, TestingSessionLocal, admin_user_obj
    ):
        # Create one budget item directly in test DB
        from database.database import BudgetItem, BudgetType, FlowType, DebtStatus
        db = TestingSessionLocal()
        item = BudgetItem(
            user_id=admin_user_obj.id,
            fecha="2032-01-10",
            tipo="Servicio",
            categoria="Hogar",
            monto_total=500.0,
            monto_pagado=0.0,
            detalle="Internet",
            fecha_vencimiento="2032-01-20",
            status=DebtStatus.PENDIENTE,
            tipo_presupuesto=BudgetType.OBLIGATION,
            tipo_flujo=FlowType.GASTO,
            monto_ejecutado=0.0,
            estimated_payment=500.0,
        )
        db.add(item)
        db.commit()
        db.close()

        # Force close prior and open target with clone
        as_admin.post("/api/months/2032-01/close")
        opened = as_admin.post("/api/months", json={
            "year_month": "2032-02",
            "include_carryover": False,
            "include_budget_clone": True,
        })
        assert opened.status_code == 200

        list_resp = as_admin.get("/api/months/2032-02/budget-items?include_clone_info=true")
        assert list_resp.status_code == 200
        items = list_resp.json()
        assert isinstance(items, list)
        assert len(items) >= 1
        assert "clone_info" in items[0]

        cloned_item = next((x for x in items if x.get("clone_info", {}).get("cloned_from_item_id")), None)
        assert cloned_item is not None

        lineage_resp = as_admin.get(f"/api/budget-items/{cloned_item['id']}/clone-lineage")
        assert lineage_resp.status_code == 200
        lineage_data = lineage_resp.json()
        assert lineage_data["item_id"] == cloned_item["id"]
        assert len(lineage_data["lineage"]) >= 1
