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
    MonthlyPeriod, MonthlyPeriodSnapshot, MonthPeriodStatus, ExpenseType,
    MonthlyPeriodEvent, MonthPeriodEventType,
    Transaction, TransactionType, get_db,
)
from database.database import BudgetItem, Category, MonthlyBalance
from database.database import DebtStatus
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
    include_carryover: bool = True,
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

    # Create carryover if requested
    if include_carryover:
        prev_month = _prev_year_month(year_month)
        try:
            balance = calculate_month_balance(prev_month, admin_user_id, db)
            if balance['net_balance'] != 0:
                create_carryover_transaction(year_month, prev_month, balance['net_balance'], admin_user_id, db)
                # Also create the monthly_balance record
                mb = MonthlyBalance(
                    user_id=admin_user_id,
                    source_month=prev_month,
                    target_month=year_month,
                    balance_amount=balance['net_balance'],
                    balance_type='NET',
                    carryover_date=now
                )
                db.add(mb)
                db.commit()
        except Exception as e:
            # Silently skip carryover if previous month doesn't exist or has no balance
            pass

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


# ---------------------------------------------------------------------------
# Rollover / open_month logic  (exp-month-open-rollover)
# ---------------------------------------------------------------------------

def _prev_year_month(year_month: str) -> str:
    """Return the previous 'YYYY-MM' string (e.g. '2025-04' -> '2025-03')."""
    dt = datetime.strptime(year_month, "%Y-%m")
    if dt.month == 1:
        return f"{dt.year - 1}-12"
    return f"{dt.year}-{dt.month - 1:02d}"


def _ensure_saldo_anterior_category(db: Session) -> int:
    """Return the id of the 'Saldo Anterior' category, creating it if missing."""
    cat = db.query(Category).filter(Category.name == "Saldo Anterior").first()
    if not cat:
        cat = Category(name="Saldo Anterior")
        db.add(cat)
        db.flush()
    return cat.id


def calculate_month_balance(year_month: str, user_id: int, db: Session) -> Dict[str, Any]:
    """Calculate net balance of a CLOSED period from its latest snapshot."""
    _validate_year_month(year_month)
    period = db.query(MonthlyPeriod).filter(
        MonthlyPeriod.year_month == year_month,
        MonthlyPeriod.user_id == user_id,
    ).first()

    if not period or period.status != MonthPeriodStatus.CLOSED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code": "PRIOR_MONTH_NOT_CLOSED",
                "message": f"El mes anterior {year_month} no está cerrado. Ciérralo antes de abrir el nuevo.",
            },
        )

    snapshot = (
        db.query(MonthlyPeriodSnapshot)
        .filter(MonthlyPeriodSnapshot.monthly_period_id == period.id)
        .order_by(MonthlyPeriodSnapshot.snapshot_at.desc())
        .first()
    )
    if not snapshot:
        return {"total_income": 0.0, "total_expenses": 0.0, "net_balance": 0.0}

    return {
        "total_income": snapshot.total_income,
        "total_expenses": snapshot.total_expenses,
        "net_balance": snapshot.net_balance,
    }


def create_carryover_transaction(
    target_month: str,
    source_month: str,
    balance_amount: float,
    user_id: int,
    db: Session,
) -> Transaction:
    """Create a CARRYOVER transaction in target_month representing prior month net balance."""
    from database.database import NecessityType, AssignmentStatus  # local import to avoid circular

    category_id = _ensure_saldo_anterior_category(db)
    year, month = target_month.split("-")
    txn_date = f"{year}-{month}-01"

    txn = Transaction(
        user_id=user_id,
        date=txn_date,
        type=TransactionType.INGRESO if balance_amount >= 0 else TransactionType.GASTO,
        category_id=category_id,
        amount=abs(balance_amount),
        necessity=NecessityType.NECESARIO,
        payment_method="Carryover",
        detail=f"Saldo trasladado de {source_month}",
        origin="CARRYOVER",
        source_month=source_month,
        assignment_status=AssignmentStatus.ASIGNADA_AUTOMATICA,
    )
    db.add(txn)
    db.flush()
    return txn


def clone_budget_items(source_month: str, target_month: str, user_id: int, db: Session, only_fixed: bool = False) -> list:
    """Clone budget items from source_month into target_month with traceability.
    EXP-FEAT-017: when only_fixed=True, only items with expense_type=FIJO are cloned.
    """
    src_year, src_month_str = source_month.split("-")

    source_items = db.query(BudgetItem).filter(
        BudgetItem.user_id == user_id,
        BudgetItem.fecha.like(f"{src_year}-{src_month_str}%"),
    ).all()

    if only_fixed:
        source_items = [i for i in source_items if i.expense_type == ExpenseType.FIJO]

    tgt_year, tgt_month_str = target_month.split("-")

    # Idempotency guard: if an item cloned from the same source already exists in target month,
    # skip creating another duplicate clone.
    existing_rows = db.query(BudgetItem.cloned_from_item_id).filter(
        BudgetItem.user_id == user_id,
        BudgetItem.fecha.like(f"{tgt_year}-{tgt_month_str}%"),
        BudgetItem.cloned_from_item_id.isnot(None),
    ).all()
    existing_cloned_source_ids = {
        row[0] for row in existing_rows if row and row[0] is not None
    }

    cloned = []
    for item in source_items:
        if item.id in existing_cloned_source_ids:
            continue

        new_fecha = item.fecha.replace(f"{src_year}-{src_month_str}", f"{tgt_year}-{tgt_month_str}", 1)
        new_fecha_vto = item.fecha_vencimiento.replace(
            f"{src_year}-{src_month_str}", f"{tgt_year}-{tgt_month_str}", 1
        ) if item.fecha_vencimiento else new_fecha

        new_item = BudgetItem(
            user_id=user_id,
            fecha=new_fecha,
            tipo=item.tipo,
            categoria=item.categoria,
            monto_total=item.monto_total,
            monto_pagado=0.0,
            detalle=item.detalle,
            fecha_vencimiento=new_fecha_vto,
            status=DebtStatus.PENDIENTE,
            tipo_presupuesto=item.tipo_presupuesto,
            tipo_flujo=item.tipo_flujo,
            monto_ejecutado=0.0,
            estimated_payment=item.estimated_payment,
            cloned_from_item_id=item.id,
            base_cloned=item.monto_total,
            version_source_month=source_month,
        )
        new_item.expense_type = item.expense_type
        db.add(new_item)
        cloned.append(new_item)

    db.flush()
    return cloned


def open_month(
    year_month: str,
    user_id: int,
    username: str,
    db: Session,
    skip_carryover: bool = False,
    skip_clone: bool = False,
    only_fixed: bool = True,
) -> Dict[str, Any]:
    """Open a monthly period, optionally creating carryover transaction and cloned budget items."""
    _validate_year_month(year_month)

    existing = db.query(MonthlyPeriod).filter(
        MonthlyPeriod.year_month == year_month,
        MonthlyPeriod.user_id == user_id,
    ).first()
    if existing and existing.status in (MonthPeriodStatus.OPEN, MonthPeriodStatus.REOPENED):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": "MONTH_ALREADY_OPEN", "message": f"El mes {year_month} ya está abierto."},
        )

    prior_month = _prev_year_month(year_month)
    prior_period = db.query(MonthlyPeriod).filter(
        MonthlyPeriod.year_month == prior_month,
        MonthlyPeriod.user_id == user_id,
    ).first()

    carryover_info: Optional[Dict[str, Any]] = None
    cloned_count = 0

    if prior_period and not skip_carryover:
        balance = calculate_month_balance(prior_month, user_id, db)
        txn = create_carryover_transaction(
            target_month=year_month,
            source_month=prior_month,
            balance_amount=balance["net_balance"],
            user_id=user_id,
            db=db,
        )
        carryover_info = {
            "source_month": prior_month,
            "net_balance": balance["net_balance"],
            "total_income": balance["total_income"],
            "total_expenses": balance["total_expenses"],
            "transaction_id": txn.id,
        }

    if prior_period and not skip_clone:
        cloned = clone_budget_items(prior_month, year_month, user_id, db, only_fixed=only_fixed)
        cloned_count = len(cloned)

    period = existing or MonthlyPeriod(
        year_month=year_month,
        user_id=user_id,
        status=MonthPeriodStatus.OPEN,
    )
    if not existing:
        db.add(period)
    else:
        period.status = MonthPeriodStatus.OPEN
    period.updated_at = datetime.utcnow()
    db.flush()

    if carryover_info:
        mb = MonthlyBalance(
            user_id=user_id,
            source_month=prior_month,
            target_month=year_month,
            balance_amount=carryover_info["net_balance"],
            balance_type="NET",
            carryover_date=datetime.utcnow(),
            transaction_id=carryover_info["transaction_id"],
        )
        db.add(mb)

    _log_period_event(db, period, user_id, username, MonthPeriodEventType.OPEN)
    db.commit()
    db.refresh(period)

    log_event(
        db,
        action="MONTH_OPENED",
        user_id=user_id,
        username=username,
        entity="monthly_period",
        entity_id=period.id,
        details=f"Mes {year_month} abierto. Carryover: {carryover_info}. Ítems clonados: {cloned_count}",
    )

    result = _period_to_dict(period)
    result["carryover"] = carryover_info
    result["cloned_items_count"] = cloned_count
    return result
