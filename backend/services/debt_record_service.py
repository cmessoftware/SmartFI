"""Service for real-debt tracking: DebtRecord and DebtPayment CRUD."""
from database.database import (
    SessionLocal, DebtRecord, DebtPayment, DebtRecordStatus, DebtType,
    BudgetItem, BudgetType, FlowType, ExpenseType, DebtStatus
)
from datetime import date, datetime
import calendar
import logging

logger = logging.getLogger(__name__)


class DebtRecordService:
    def __init__(self):
        self.db = SessionLocal()

    def close(self):
        if self.db:
            self.db.close()

    # ──────────────────────────────────────────────────────────
    # DEBT RECORDS
    # ──────────────────────────────────────────────────────────

    def _projection_base_date(self, record: DebtRecord) -> date:
        # start_date = debt acquisition date (not first installment date).
        # Projection must start on first installment date (due_date).
        # If due_date is not provided, default to next month from start_date.
        if record.due_date is not None:
            return record.due_date
        if record.start_date is not None:
            return self._add_months(record.start_date, 1)
        return date.today()

    def _projection_installment_count(self, record: DebtRecord) -> int:
        total = float(record.total_installments) if record.total_installments is not None else None
        current = float(record.current_installment) if record.current_installment is not None else None

        if total is not None and current is not None:
            remaining = int(round(total - current + 1.0))
            return max(1, remaining)
        if total is not None:
            return max(1, int(round(total)))
        return 1

    def _add_months(self, dt: date, months: int) -> date:
        year = dt.year + (dt.month - 1 + months) // 12
        month = ((dt.month - 1 + months) % 12) + 1
        day = min(dt.day, calendar.monthrange(year, month)[1])
        return date(year, month, day)

    def _projection_schedule(self, record: DebtRecord) -> list:
        base = self._projection_base_date(record)
        count = self._projection_installment_count(record)
        current = float(record.current_installment) if record.current_installment is not None else None

        schedule = []
        for idx in range(count):
            projection_date = self._add_months(base, idx)
            month_key = projection_date.strftime("%Y-%m")
            quota = (current + idx) if current is not None else (idx + 1)
            schedule.append((month_key, projection_date, quota))
        return schedule

    def _projection_amount(self, record: DebtRecord) -> float:
        outstanding = float(record.outstanding_amount or 0)
        if outstanding <= 0:
            return 0.0

        pending = float(record.pending_installments) if record.pending_installments is not None else None
        if pending and pending > 0:
            return outstanding / pending

        count = self._projection_installment_count(record)
        return outstanding / count if count > 0 else outstanding

    def _build_projection_detail(self, record: DebtRecord) -> str:
        quota_label = ""
        if record.current_installment is not None and record.total_installments is not None:
            quota_label = f" - cuota {self._fmt_quota(record.current_installment)}/{self._fmt_quota(record.total_installments)}"
        return f"DBT {record.debt_name}{quota_label} (debt-record {record.id})"

    def _fmt_quota(self, value: float) -> str:
        n = float(value)
        if n.is_integer():
            return str(int(n))
        return f"{n:.2f}".rstrip("0").rstrip(".")

    def _normalize_installments(self, data: dict, existing: DebtRecord = None) -> dict:
        normalized = dict(data)

        total = normalized.get("total_installments")
        current = normalized.get("current_installment")
        pending = normalized.get("pending_installments")

        if total is None and existing is not None:
            total = existing.total_installments
        if current is None and existing is not None:
            current = existing.current_installment
        if pending is None and existing is not None:
            pending = existing.pending_installments

        total = float(total) if total is not None else None
        current = float(current) if current is not None else None
        pending = float(pending) if pending is not None else None

        if total is not None and total <= 0:
            raise ValueError("total_installments must be greater than 0")
        if current is not None and current < 0:
            raise ValueError("current_installment must be greater or equal to 0")
        if pending is not None and pending < 0:
            raise ValueError("pending_installments must be greater or equal to 0")
        if total is not None and current is not None and current > total:
            raise ValueError("current_installment cannot be greater than total_installments")

        if pending is None and total is not None and current is not None:
            pending = max(0.0, total - current + 1.0)

        normalized["total_installments"] = total
        normalized["current_installment"] = current
        normalized["pending_installments"] = pending
        return normalized

    def _upsert_budget_projection(self, record: DebtRecord):
        """Create/update monthly budget projections linked to a debt record."""
        schedule = self._projection_schedule(record)
        per_installment_amount = self._projection_amount(record)

        existing = self.db.query(BudgetItem).filter(
            BudgetItem.debt_record_id == record.id,
            BudgetItem.user_id == record.user_id,
        ).all()
        existing_by_month = {item.version_source_month: item for item in existing if item.version_source_month}

        valid_months = {month_key for month_key, _, _ in schedule}

        for month_key, projection_date, quota in schedule:
            projection_date_iso = projection_date.isoformat()
            budget_item = existing_by_month.get(month_key)

            if not budget_item:
                budget_item = BudgetItem(
                    user_id=record.user_id,
                    debt_record_id=record.id,
                    version_source_month=month_key,
                    fecha=projection_date_iso,
                    fecha_vencimiento=projection_date_iso,
                    tipo="Deuda no tarjeta",
                    categoria="Deudas",
                    detalle=self._build_projection_detail(record),
                    monto_total=per_installment_amount,
                    monto_pagado=0.0,
                    monto_ejecutado=0.0,
                    estimated_payment=per_installment_amount,
                    status=DebtStatus.PENDIENTE,
                    tipo_presupuesto=BudgetType.OBLIGATION,
                    tipo_flujo=FlowType.INGRESO,
                    expense_type=ExpenseType.VARIABLE,
                    debt_source=record.debt_source or record.creditor,
                    debt_quota_number=quota,
                    debt_total_quotas=record.total_installments,
                )
                self.db.add(budget_item)
            else:
                budget_item.fecha = projection_date_iso
                budget_item.fecha_vencimiento = projection_date_iso
                budget_item.detalle = self._build_projection_detail(record)
                budget_item.monto_total = per_installment_amount
                budget_item.estimated_payment = per_installment_amount
                budget_item.debt_source = record.debt_source or record.creditor
                budget_item.debt_quota_number = quota
                budget_item.debt_total_quotas = record.total_installments
                budget_item.updated_at = datetime.utcnow()

            budget_item.status = (
                DebtStatus.PAGADA if float(record.outstanding_amount or 0) <= 0 else DebtStatus.PENDIENTE
            )

        # Remove obsolete projections when dates/installments changed.
        for item in existing:
            if item.version_source_month not in valid_months:
                self.db.delete(item)

    def _projection_to_dict(self, projection: BudgetItem) -> dict:
        if not projection:
            return None
        return {
            "id": projection.id,
            "debt_record_id": projection.debt_record_id,
            "fecha": projection.fecha,
            "fecha_vencimiento": projection.fecha_vencimiento,
            "monto_total": projection.monto_total,
            "monto_ejecutado": projection.monto_ejecutado,
            "status": projection.status.value if hasattr(projection.status, "value") else projection.status,
            "tipo_flujo": projection.tipo_flujo.value if hasattr(projection.tipo_flujo, "value") else projection.tipo_flujo,
            "version_source_month": projection.version_source_month,
        }

    def get_debt_records(self, user_id: int, status: str = None) -> list:
        """Return all debt records for a user, optionally filtered by status."""
        q = self.db.query(DebtRecord).filter(DebtRecord.user_id == user_id)
        if status:
            try:
                status_enum = DebtRecordStatus(status)
                q = q.filter(DebtRecord.status == status_enum)
            except ValueError:
                pass
        records = q.order_by(DebtRecord.created_at.desc()).all()
        return [self._record_to_dict(r) for r in records]

    def get_debt_records_with_projection(self, user_id: int, status: str = None) -> list:
        """Return debt records enriched with linked budget projection summary."""
        q = self.db.query(DebtRecord).filter(DebtRecord.user_id == user_id)
        if status:
            try:
                q = q.filter(DebtRecord.status == DebtRecordStatus(status))
            except ValueError:
                pass

        records = q.order_by(DebtRecord.created_at.desc()).all()
        record_ids = [r.id for r in records]
        projections = []
        if record_ids:
            projections = self.db.query(BudgetItem).filter(
                BudgetItem.user_id == user_id,
                BudgetItem.debt_record_id.in_(record_ids)
            ).all()

        by_record = {}
        for p in projections:
            by_record.setdefault(p.debt_record_id, []).append(p)

        result = []
        for record in records:
            projections_for_record = by_record.get(record.id, [])
            projection_current = None
            if projections_for_record and record.current_installment is not None:
                current = float(record.current_installment)
                projection_current = next(
                    (
                        p for p in projections_for_record
                        if p.debt_quota_number is not None and abs(float(p.debt_quota_number) - current) < 0.0001
                    ),
                    None,
                )

            if projection_current is None and projections_for_record:
                projection_current = sorted(
                    projections_for_record,
                    key=lambda i: (i.version_source_month or "", i.id)
                )[0]

            item = self._record_to_dict(record)
            item["projection_count"] = len(projections_for_record)
            item["projection_current"] = self._projection_to_dict(projection_current)
            result.append(item)

        return result

    def get_debt_record(self, record_id: int, user_id: int) -> dict:
        """Return a single debt record (must belong to user)."""
        record = self.db.query(DebtRecord).filter(
            DebtRecord.id == record_id,
            DebtRecord.user_id == user_id
        ).first()
        if not record:
            return None
        return self._record_to_dict(record)

    def create_debt_record(self, data: dict, user_id: int) -> dict:
        """Create a new debt record."""
        payload = self._normalize_installments(data)
        record = DebtRecord(
            user_id=user_id,
            debt_name=payload["debt_name"],
            debt_type=DebtType(payload["debt_type"]),
            debt_source=payload.get("debt_source"),
            creditor=payload.get("creditor"),
            currency=payload.get("currency", "ARS"),
            principal_amount=float(payload["principal_amount"]),
            outstanding_amount=float(payload.get("outstanding_amount", payload["principal_amount"])),
            annual_interest_rate=float(payload["annual_interest_rate"]) if payload.get("annual_interest_rate") is not None else None,
            total_installments=payload.get("total_installments"),
            current_installment=payload.get("current_installment"),
            pending_installments=payload.get("pending_installments"),
            start_date=_parse_date(payload.get("start_date")),
            due_date=_parse_date(payload.get("due_date")),
            status=DebtRecordStatus(payload.get("status", DebtRecordStatus.ACTIVA.value)),
            notes=payload.get("notes"),
        )
        self.db.add(record)
        self.db.flush()
        self._upsert_budget_projection(record)
        self.db.commit()
        self.db.refresh(record)
        logger.info(f"✅ DebtRecord created (id={record.id}) for user {user_id}")
        return self._record_to_dict(record)

    def update_debt_record(self, record_id: int, data: dict, user_id: int) -> dict:
        """Update fields of an existing debt record."""
        record = self.db.query(DebtRecord).filter(
            DebtRecord.id == record_id,
            DebtRecord.user_id == user_id
        ).first()
        if not record:
            return None

        payload = self._normalize_installments(data, existing=record)

        updatable = [
            "debt_name", "creditor", "currency", "principal_amount",
            "outstanding_amount", "annual_interest_rate", "notes",
            "debt_source", "total_installments", "current_installment", "pending_installments",
        ]
        for field in updatable:
            if field in payload:
                setattr(record, field, payload[field])

        if "debt_type" in payload:
            record.debt_type = DebtType(payload["debt_type"])
        if "status" in payload:
            record.status = DebtRecordStatus(payload["status"])
        if "start_date" in payload:
            record.start_date = _parse_date(payload["start_date"])
        if "due_date" in payload:
            record.due_date = _parse_date(payload["due_date"])

        record.updated_at = datetime.utcnow()
        self._upsert_budget_projection(record)
        self.db.commit()
        self.db.refresh(record)
        return self._record_to_dict(record)

    def delete_debt_record(self, record_id: int, user_id: int) -> bool:
        """Delete a debt record and its payments (cascade)."""
        record = self.db.query(DebtRecord).filter(
            DebtRecord.id == record_id,
            DebtRecord.user_id == user_id
        ).first()
        if not record:
            return False

        projections = self.db.query(BudgetItem).filter(
            BudgetItem.debt_record_id == record_id,
            BudgetItem.user_id == user_id
        ).all()
        for projection in projections:
            self.db.delete(projection)

        self.db.delete(record)
        self.db.commit()
        logger.info(f"🗑️ DebtRecord {record_id} deleted by user {user_id}")
        return True

    # ──────────────────────────────────────────────────────────
    # DEBT PAYMENTS
    # ──────────────────────────────────────────────────────────

    def get_payments(self, debt_record_id: int, user_id: int) -> list:
        """Return all payments for a debt record (verifying ownership)."""
        record = self.db.query(DebtRecord).filter(
            DebtRecord.id == debt_record_id,
            DebtRecord.user_id == user_id
        ).first()
        if not record:
            return None  # signals not found / unauthorized
        payments = self.db.query(DebtPayment).filter(
            DebtPayment.debt_record_id == debt_record_id
        ).order_by(DebtPayment.payment_date.desc()).all()
        return [self._payment_to_dict(p) for p in payments]

    def add_payment(self, debt_record_id: int, data: dict, user_id: int) -> dict:
        """Register a payment against a debt record, reducing outstanding_amount."""
        record = self.db.query(DebtRecord).filter(
            DebtRecord.id == debt_record_id,
            DebtRecord.user_id == user_id
        ).first()
        if not record:
            return None

        amount = float(data["amount"])
        payment = DebtPayment(
            debt_record_id=debt_record_id,
            transaction_id=data.get("transaction_id"),
            payment_date=_parse_date(data.get("payment_date")) or date.today(),
            amount=amount,
            notes=data.get("notes"),
        )
        self.db.add(payment)

        # Reduce outstanding amount
        record.outstanding_amount = max(0.0, float(record.outstanding_amount) - amount)
        if record.outstanding_amount == 0.0:
            record.status = DebtRecordStatus.CANCELADA
        record.updated_at = datetime.utcnow()
        self._upsert_budget_projection(record)

        self.db.commit()
        self.db.refresh(payment)
        self.db.refresh(record)
        logger.info(f"✅ Payment {payment.id} registered for DebtRecord {debt_record_id}")
        return self._payment_to_dict(payment)

    def delete_payment(self, payment_id: int, user_id: int) -> bool:
        """Delete a payment and restore outstanding_amount on the parent record."""
        payment = self.db.query(DebtPayment).filter(
            DebtPayment.id == payment_id
        ).first()
        if not payment:
            return False

        # Verify ownership via parent record
        record = self.db.query(DebtRecord).filter(
            DebtRecord.id == payment.debt_record_id,
            DebtRecord.user_id == user_id
        ).first()
        if not record:
            return False

        # Restore outstanding amount
        record.outstanding_amount = float(record.outstanding_amount) + float(payment.amount)
        if record.status == DebtRecordStatus.CANCELADA and record.outstanding_amount > 0:
            record.status = DebtRecordStatus.ACTIVA
        record.updated_at = datetime.utcnow()
        self._upsert_budget_projection(record)

        self.db.delete(payment)
        self.db.commit()
        logger.info(f"🗑️ Payment {payment_id} deleted, outstanding restored for DebtRecord {payment.debt_record_id}")
        return True

    # ──────────────────────────────────────────────────────────
    # SERIALIZATION HELPERS
    # ──────────────────────────────────────────────────────────

    def _record_to_dict(self, record: DebtRecord) -> dict:
        return {
            "id": record.id,
            "user_id": record.user_id,
            "debt_name": record.debt_name,
            "debt_type": record.debt_type.value if record.debt_type else None,
            "debt_source": record.debt_source,
            "creditor": record.creditor,
            "currency": record.currency,
            "principal_amount": record.principal_amount,
            "outstanding_amount": record.outstanding_amount,
            "annual_interest_rate": record.annual_interest_rate,
            "total_installments": record.total_installments,
            "current_installment": record.current_installment,
            "pending_installments": record.pending_installments,
            "start_date": record.start_date.isoformat() if record.start_date else None,
            "due_date": record.due_date.isoformat() if record.due_date else None,
            "status": record.status.value if record.status else None,
            "notes": record.notes,
            "created_at": record.created_at.isoformat() if record.created_at else None,
            "updated_at": record.updated_at.isoformat() if record.updated_at else None,
        }

    def _payment_to_dict(self, payment: DebtPayment) -> dict:
        return {
            "id": payment.id,
            "debt_record_id": payment.debt_record_id,
            "transaction_id": payment.transaction_id,
            "payment_date": payment.payment_date.isoformat() if payment.payment_date else None,
            "amount": payment.amount,
            "notes": payment.notes,
            "created_at": payment.created_at.isoformat() if payment.created_at else None,
        }


# ── Helpers ───────────────────────────────────────────────────

def _parse_date(value) -> date:
    if value is None:
        return None
    if isinstance(value, date):
        return value
    try:
        return date.fromisoformat(str(value))
    except (ValueError, TypeError):
        return None
