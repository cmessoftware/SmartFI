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
