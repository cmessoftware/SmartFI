"""Service for real-debt tracking: DebtRecord and DebtPayment CRUD."""
from database.database import (
    SessionLocal, DebtRecord, DebtPayment, DebtRecordStatus, DebtType
)
from datetime import date, datetime
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
        record = DebtRecord(
            user_id=user_id,
            debt_name=data["debt_name"],
            debt_type=DebtType(data["debt_type"]),
            creditor=data.get("creditor"),
            currency=data.get("currency", "ARS"),
            principal_amount=float(data["principal_amount"]),
            outstanding_amount=float(data.get("outstanding_amount", data["principal_amount"])),
            annual_interest_rate=float(data["annual_interest_rate"]) if data.get("annual_interest_rate") is not None else None,
            start_date=_parse_date(data.get("start_date")),
            due_date=_parse_date(data.get("due_date")),
            status=DebtRecordStatus(data.get("status", DebtRecordStatus.ACTIVA.value)),
            notes=data.get("notes"),
        )
        self.db.add(record)
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

        updatable = [
            "debt_name", "creditor", "currency", "principal_amount",
            "outstanding_amount", "annual_interest_rate", "notes",
        ]
        for field in updatable:
            if field in data:
                setattr(record, field, data[field])

        if "debt_type" in data:
            record.debt_type = DebtType(data["debt_type"])
        if "status" in data:
            record.status = DebtRecordStatus(data["status"])
        if "start_date" in data:
            record.start_date = _parse_date(data["start_date"])
        if "due_date" in data:
            record.due_date = _parse_date(data["due_date"])

        record.updated_at = datetime.utcnow()
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
            payment_date=_parse_date(data["payment_date"]) or date.today(),
            amount=amount,
            notes=data.get("notes"),
        )
        self.db.add(payment)

        # Reduce outstanding amount
        record.outstanding_amount = max(0.0, float(record.outstanding_amount) - amount)
        if record.outstanding_amount == 0.0:
            record.status = DebtRecordStatus.CANCELADA
        record.updated_at = datetime.utcnow()

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
            "creditor": record.creditor,
            "currency": record.currency,
            "principal_amount": record.principal_amount,
            "outstanding_amount": record.outstanding_amount,
            "annual_interest_rate": record.annual_interest_rate,
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
