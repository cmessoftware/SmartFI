"""Service for BankAccount CRUD (Phase 1 MVP)."""
from database.database import (
    SessionLocal, BankAccount, AccountType
)
from datetime import datetime
import logging

logger = logging.getLogger(__name__)


class BankAccountService:
    def __init__(self):
        self.db = SessionLocal()

    def close(self):
        if self.db:
            self.db.close()

    # ──────────────────────────────────────────────────────────
    # CRUD
    # ──────────────────────────────────────────────────────────

    def get_accounts(self, user_id: int, is_admin: bool = False, active_only: bool = True) -> list:
        """Return accounts. Admin sees all; regular user sees only own."""
        q = self.db.query(BankAccount)
        if not is_admin:
            q = q.filter(BankAccount.user_id == user_id)
        if active_only:
            q = q.filter(BankAccount.is_active == True)
        accounts = q.order_by(BankAccount.account_name).all()
        return [self._to_dict(a) for a in accounts]

    def get_account(self, account_id: int, user_id: int, is_admin: bool = False) -> dict:
        """Return a single account. Admin can view any; user only owns."""
        q = self.db.query(BankAccount).filter(BankAccount.id == account_id)
        if not is_admin:
            q = q.filter(BankAccount.user_id == user_id)
        account = q.first()
        return self._to_dict(account) if account else None

    def create_account(self, data: dict, user_id: int) -> dict:
        """Create a new bank account."""
        account = BankAccount(
            user_id=user_id,
            account_name=data["account_name"],
            institution_name=data["institution_name"],
            account_type=AccountType(data["account_type"]),
            currency=data.get("currency", "ARS"),
            balance=float(data.get("balance", 0.0)),
            is_active=data.get("is_active", True),
            cbu_cvu=data.get("cbu_cvu"),
            alias=data.get("alias"),
            notes=data.get("notes"),
        )
        self.db.add(account)
        self.db.commit()
        self.db.refresh(account)
        logger.info(f"✅ BankAccount '{account.account_name}' created (id={account.id}) for user {user_id}")
        return self._to_dict(account)

    def update_account(self, account_id: int, data: dict, user_id: int, is_admin: bool = False) -> dict:
        """Update a bank account."""
        q = self.db.query(BankAccount).filter(BankAccount.id == account_id)
        if not is_admin:
            q = q.filter(BankAccount.user_id == user_id)
        account = q.first()
        if not account:
            return None

        updatable = [
            "account_name", "institution_name", "currency",
            "balance", "is_active", "cbu_cvu", "alias", "notes",
        ]
        for field in updatable:
            if field in data:
                setattr(account, field, data[field])

        if "account_type" in data:
            account.account_type = AccountType(data["account_type"])

        account.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(account)
        return self._to_dict(account)

    def delete_account(self, account_id: int, user_id: int, is_admin: bool = False) -> bool:
        """Soft-delete (deactivate) a bank account."""
        q = self.db.query(BankAccount).filter(BankAccount.id == account_id)
        if not is_admin:
            q = q.filter(BankAccount.user_id == user_id)
        account = q.first()
        if not account:
            return False
        account.is_active = False
        account.updated_at = datetime.utcnow()
        self.db.commit()
        logger.info(f"🗑️ BankAccount {account_id} deactivated by user {user_id}")
        return True

    # ──────────────────────────────────────────────────────────
    # SERIALIZATION
    # ──────────────────────────────────────────────────────────

    def _to_dict(self, account: BankAccount) -> dict:
        return {
            "id": account.id,
            "user_id": account.user_id,
            "account_name": account.account_name,
            "institution_name": account.institution_name,
            "account_type": account.account_type.value if account.account_type else None,
            "currency": account.currency,
            "balance": account.balance,
            "is_active": account.is_active,
            "cbu_cvu": account.cbu_cvu,
            "alias": account.alias,
            "notes": account.notes,
            "created_at": account.created_at.isoformat() if account.created_at else None,
            "updated_at": account.updated_at.isoformat() if account.updated_at else None,
        }
