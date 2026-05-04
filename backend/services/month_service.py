"""
Month Period Service
Handles close/reopen logic for monthly periods (exp-month-close feature).
"""
import logging
from datetime import datetime
from typing import Optional, Dict, Any

from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException, status

from database.database import (
    MonthlyPeriod, MonthlyPeriodSnapshot, MonthPeriodStatus,
    MonthlyPeriodEvent, MonthPeriodEventType,
    Transaction, TransactionType, get_db,
)
from security.audit_service import log_event

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _validate_year_month(year_month: str) -> None:
    """Raise ValueError if year_month is not a valid 'YYYY-MM' string."""
    try:
        datetime.strptime(year_month, "%Y-%m")
    except ValueError:
        raise ValueError(f"Formato de periodo inválido: '{year_month}'. Debe ser YYYY-MM")


def _get_or_create_period(db: Session, year_month: str, user_id: int) -> MonthlyPeriod:
    """Return existing MonthlyPeriod row for the user or create a new OPEN one."""
    period = db.query(MonthlyPeriod).filter(
        MonthlyPeriod.year_month == year_month,
        MonthlyPeriod.user_id == user_id,
    ).first()
    if not period:
        period = MonthlyPeriod(year_month=year_month, status=MonthPeriodStatus.OPEN, user_id=user_id)
        db.add(period)
        db.flush()
    return period


def _log_period_event(
    db: Session,
    period: MonthlyPeriod,
    user_id: int,
    username: str,
    event_type: MonthPeriodEventType,
    reason: Optional[str] = None,
) -> None:
    """Insert a MonthlyPeriodEvent row (no commit — caller must commit)."""
    event = MonthlyPeriodEvent(
        monthly_period_id=period.id,
        user_id=user_id,
        username=username,
        event_type=event_type,
        occurred_at=datetime.utcnow(),
        reason=reason,
    )
    db.add(event)


def _build_snapshot(db: Session, period: MonthlyPeriod, admin_user_id: int) -> MonthlyPeriodSnapshot:
    """Calculate snapshot figures from transactions and persist."""
    year, month = period.year_month.split("-")
    prefix = f"{year}-{month}"  # e.g. "2025-04"

    transactions = (
        db.query(Transaction)
        .filter(
            Transaction.date.like(f"{prefix}%"),
            Transaction.user_id == admin_user_id,
        )
        .all()
    )

    income_types = {TransactionType.INGRESO}
    expense_types = {TransactionType.GASTO}

    total_income = sum(float(t.amount) for t in transactions if t.type in income_types)
    total_expenses = sum(float(t.amount) for t in transactions if t.type in expense_types)
    net_balance = total_income - total_expenses
    transaction_count = len(transactions)

    snapshot = MonthlyPeriodSnapshot(
        monthly_period_id=period.id,
        snapshot_at=datetime.utcnow(),
        total_expenses=total_expenses,
        total_income=total_income,
        net_balance=net_balance,
        transaction_count=transaction_count,
        created_by=admin_user_id,
    )
    db.add(snapshot)
    db.flush()
    return snapshot


def _period_to_dict(period: MonthlyPeriod) -> Dict[str, Any]:
    return {
        "id": period.id,
        "year_month": period.year_month,
        "status": period.status.value if hasattr(period.status, "value") else period.status,
        "closed_at": period.closed_at.isoformat() if period.closed_at else None,
        "closed_by": period.closed_by,
        "reopened_at": period.reopened_at.isoformat() if period.reopened_at else None,
        "reopened_by": period.reopened_by,
        "reopen_reason": period.reopen_reason,
        "created_at": period.created_at.isoformat() if period.created_at else None,
        "updated_at": period.updated_at.isoformat() if period.updated_at else None,
    }


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def get_month_status(year_month: str, db: Session, user_id: int) -> Dict[str, Any]:
    """Return the status of a monthly period for the given user."""
    _validate_year_month(year_month)
    period = db.query(MonthlyPeriod).filter(
        MonthlyPeriod.year_month == year_month,
        MonthlyPeriod.user_id == user_id,
    ).first()
    if not period:
        return {"year_month": year_month, "status": "OPEN", "id": None}
    return _period_to_dict(period)


def get_months_with_status(db: Session, user_id: int) -> list:
    """Return all known monthly periods for the given user."""
    periods = (
        db.query(MonthlyPeriod)
        .filter(MonthlyPeriod.user_id == user_id)
        .order_by(MonthlyPeriod.year_month.desc())
        .all()
    )
    return [_period_to_dict(p) for p in periods]


def close_month(year_month: str, admin_user_id: int, admin_username: str, db: Session) -> Dict[str, Any]:
    """Close a monthly period. Creates snapshot. Raises HTTPException on error."""
    _validate_year_month(year_month)

    period = _get_or_create_period(db, year_month, admin_user_id)

    if period.status in (MonthPeriodStatus.CLOSED,):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": "MONTH_ALREADY_CLOSED", "message": "Este mes ya está cerrado"},
        )

    now = datetime.utcnow()
    period.status = MonthPeriodStatus.CLOSED
    period.closed_at = now
    period.closed_by = admin_user_id
    period.updated_at = now

    snapshot = _build_snapshot(db, period, admin_user_id)
    _log_period_event(db, period, admin_user_id, admin_username, MonthPeriodEventType.CLOSE)
    db.commit()
    db.refresh(period)
    db.refresh(snapshot)

    log_event(
        db,
        action="MONTH_CLOSED",
        user_id=admin_user_id,
        username=admin_username,
        entity="monthly_period",
        entity_id=period.id,
        details=f"Mes {year_month} cerrado. Snapshot: ingresos={snapshot.total_income}, "
                f"egresos={snapshot.total_expenses}, balance={snapshot.net_balance}, "
                f"transacciones={snapshot.transaction_count}",
    )

    result = _period_to_dict(period)
    result["snapshot"] = {
        "id": snapshot.id,
        "total_income": snapshot.total_income,
        "total_expenses": snapshot.total_expenses,
        "net_balance": snapshot.net_balance,
        "transaction_count": snapshot.transaction_count,
        "snapshot_at": snapshot.snapshot_at.isoformat(),
    }
    return result


def reopen_month(
    year_month: str,
    admin_user_id: int,
    admin_username: str,
    reason: str,
    db: Session,
    is_admin: bool = True,
) -> Dict[str, Any]:
    """Reopen a closed monthly period. Requires reason ≥ 10 chars.
    ADMIN can reopen any period. WRITER can only reopen their own (closed_by == their user_id).
    """
    _validate_year_month(year_month)

    if not reason or len(reason.strip()) < 10:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": "REASON_REQUIRED", "message": "El motivo debe tener al menos 10 caracteres"},
        )

    period = db.query(MonthlyPeriod).filter(
        MonthlyPeriod.year_month == year_month,
        MonthlyPeriod.user_id == admin_user_id,
    ).first()

    if not period or period.status not in (MonthPeriodStatus.CLOSED, MonthPeriodStatus.REOPENED):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": "INVALID_STATE_TRANSITION", "message": "Solo se pueden reabrir meses que están cerrados"},
        )

    # WRITER can only reopen a period they closed themselves
    if not is_admin and period.closed_by != admin_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "FORBIDDEN", "message": "Solo puedes reabrir meses que cerraste tú mismo"},
        )

    now = datetime.utcnow()
    period.status = MonthPeriodStatus.REOPENED
    period.reopened_at = now
    period.reopened_by = admin_user_id
    period.reopen_reason = reason.strip()
    period.updated_at = now

    _log_period_event(db, period, admin_user_id, admin_username, MonthPeriodEventType.REOPEN, reason.strip())
    db.commit()
    db.refresh(period)

    log_event(
        db,
        action="MONTH_REOPENED",
        user_id=admin_user_id,
        username=admin_username,
        entity="monthly_period",
        entity_id=period.id,
        details=f"Mes {year_month} reabierto. Motivo: {reason.strip()}",
    )

    return _period_to_dict(period)


def get_latest_snapshot(year_month: str, db: Session, user_id: int = None) -> Optional[Dict[str, Any]]:
    """Return the most recent snapshot for a monthly period, or None."""
    query = db.query(MonthlyPeriod).filter(MonthlyPeriod.year_month == year_month)
    if user_id is not None:
        query = query.filter(MonthlyPeriod.user_id == user_id)
    period = query.first()
    if not period:
        return None

    snapshot = (
        db.query(MonthlyPeriodSnapshot)
        .filter(MonthlyPeriodSnapshot.monthly_period_id == period.id)
        .order_by(MonthlyPeriodSnapshot.snapshot_at.desc())
        .first()
    )
    if not snapshot:
        return None

    return {
        "id": snapshot.id,
        "total_income": snapshot.total_income,
        "total_expenses": snapshot.total_expenses,
        "net_balance": snapshot.net_balance,
        "transaction_count": snapshot.transaction_count,
        "snapshot_at": snapshot.snapshot_at.isoformat(),
    }


def validate_period_for_mutation(
    year_month: str,
    is_admin: bool,
    origin: str,
    db: Session,
    user_id: int = None,
) -> None:
    """
    Raise HTTPException(403) if mutation is not allowed for the given period.

    Rules:
    - OPEN or REOPENED → always allowed
    - CLOSED + is_admin + origin == 'bank_adjustment' → allowed (audit separately)
    - CLOSED + is_admin + other origin → allowed
    - CLOSED + not admin → raise 403
    """
    query = db.query(MonthlyPeriod).filter(MonthlyPeriod.year_month == year_month)
    if user_id is not None:
        query = query.filter(MonthlyPeriod.user_id == user_id)
    period = query.first()

    if not period or period.status != MonthPeriodStatus.CLOSED:
        return  # OPEN / REOPENED / unknown → permit

    if is_admin:
        return  # admins always allowed

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail={
            "code": "MONTH_CLOSED",
            "message": f"El mes {year_month} está cerrado. No se pueden modificar transacciones.",
        },
    )
