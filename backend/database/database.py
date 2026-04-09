from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Enum as SQLEnum, ForeignKey, Date, Boolean, Text, UniqueConstraint, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import os
from dotenv import load_dotenv
import enum

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://admin:admin123@localhost:5432/fin_per_db")

# Create engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Enums
class TransactionType(str, enum.Enum):
    GASTO = "Gasto"
    INGRESO = "Ingreso"

class NecessityType(str, enum.Enum):
    NECESARIO = "Necesario"
    SUPERFLUO = "Superfluo"
    IMPORTANTE_NO_URGENTE = "Importante pero no urgente"

class DebtStatus(str, enum.Enum):
    PENDIENTE = "PENDIENTE"
    PAGO_PARCIAL = "Pago parcial"
    PAGADA = "PAGADA"
    VENCIDA = "VENCIDA"

class BudgetType(str, enum.Enum):
    OBLIGATION = "OBLIGATION"
    VARIABLE = "VARIABLE"

class FlowType(str, enum.Enum):
    GASTO = "Gasto"
    INGRESO = "Ingreso"

class AssignmentStatus(str, enum.Enum):
    ASIGNADA_MANUAL = "ASIGNADA_MANUAL"
    ASIGNADA_AUTOMATICA = "ASIGNADA_AUTOMATICA"
    NO_PLANIFICADA = "NO_PLANIFICADA"
    REASIGNADA_AUTOMATICA = "REASIGNADA_AUTOMATICA"

class InstallmentStatus(str, enum.Enum):
    PENDING = "PENDING"
    PAID = "PAID"

class StatementStatus(str, enum.Enum):
    PENDING = "PENDING"
    PARTIALLY_PAID = "PARTIALLY_PAID"
    PAID = "PAID"
    OVERDUE = "OVERDUE"

class InstallmentPlanType(str, enum.Enum):
    REGULAR = "REGULAR"
    PROMOTIONAL = "PROMOTIONAL"
    ZERO_INTEREST = "ZERO_INTEREST"

# Models
class BudgetItem(Base):
    """
    Budget Item model - represents planned or actual financial items
    
    This table was renamed from 'debts' to 'budget_items' for better semantic clarity.
    Budget items can represent:
    - Debts (credit cards, loans)
    - Planned expenses (obligations, variable costs)
    - Expected income
    """
    __tablename__ = "budget_items"
    
    id = Column(Integer, primary_key=True, index=True)
    fecha = Column(String, nullable=False)
    tipo = Column(String, nullable=False)  # Tarjeta, Préstamo, Crédito, Gasto Planificado, etc.
    categoria = Column(String, nullable=False)
    monto_total = Column(Float, nullable=False)
    monto_pagado = Column(Float, default=0.0, nullable=False)
    detalle = Column(String, nullable=True)
    fecha_vencimiento = Column(String, nullable=False)
    status = Column(SQLEnum(DebtStatus, values_callable=lambda x: [e.value for e in x]), default=DebtStatus.PENDIENTE, nullable=False)
    
    # Budget Model columns
    tipo_presupuesto = Column(SQLEnum(BudgetType, values_callable=lambda x: [e.value for e in x]), default=BudgetType.OBLIGATION, nullable=False)
    tipo_flujo = Column(SQLEnum(FlowType, values_callable=lambda x: [e.value for e in x]), default=FlowType.GASTO, nullable=False)
    monto_ejecutado = Column(Float, default=0.0, nullable=False)
    estimated_payment = Column(Float, nullable=True)  # monto_a_pagar: defaults to monto_total (100%)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Backward compatibility alias
Debt = BudgetItem

class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    date = Column(String, nullable=False)
    type = Column(SQLEnum(TransactionType), nullable=False)
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=False)
    amount = Column(Float, nullable=False)
    necessity = Column(SQLEnum(NecessityType), nullable=False)
    payment_method = Column(String, default="Débito", nullable=False)
    detail = Column(Text, nullable=True)
    debt_id = Column(Integer, ForeignKey('budget_items.id'), nullable=True)
    assignment_status = Column(SQLEnum(AssignmentStatus, values_callable=lambda x: [e.value for e in x]), default=AssignmentStatus.ASIGNADA_MANUAL, nullable=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    category = relationship("Category")

class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

# ============================================================================
# SECURITY MODULE
# ============================================================================

# Association tables
user_roles = Table(
    'user_roles', Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('role_id', Integer, ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
)

role_permissions = Table(
    'role_permissions', Base.metadata,
    Column('role_id', Integer, ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
    Column('permission_id', Integer, ForeignKey('permissions.id', ondelete='CASCADE'), primary_key=True),
)

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    is_locked = Column(Boolean, default=False, nullable=False)
    failed_login_attempts = Column(Integer, default=0, nullable=False)
    force_password_change = Column(Boolean, default=False, nullable=False)
    last_login_at = Column(DateTime, nullable=True)
    password_changed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    roles = relationship("Role", secondary=user_roles, back_populates="users", lazy="joined")
    refresh_tokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")

class Role(Base):
    __tablename__ = "roles"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False, index=True)
    description = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    users = relationship("User", secondary=user_roles, back_populates="roles")
    permissions = relationship("Permission", secondary=role_permissions, back_populates="roles", lazy="joined")

class Permission(Base):
    __tablename__ = "permissions"
    
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    description = Column(String(255), nullable=True)
    module = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    roles = relationship("Role", secondary=role_permissions, back_populates="permissions")

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    token_hash = Column(String(255), nullable=False, index=True)
    expires_at = Column(DateTime, nullable=False)
    revoked_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(String(500), nullable=True)
    
    user = relationship("User", back_populates="refresh_tokens")

class AuditLog(Base):
    __tablename__ = "audit_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='SET NULL'), nullable=True)
    username = Column(String(50), nullable=True)
    action = Column(String(50), nullable=False, index=True)
    entity = Column(String(50), nullable=True)
    entity_id = Column(Integer, nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

# ============================================================================
# CREDIT CARD MANAGEMENT MODULE
# ============================================================================

class CreditCard(Base):
    __tablename__ = "credit_cards"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)  # Future FK to users table
    card_name = Column(String(100), nullable=False, unique=True)
    bank_name = Column(String(100), nullable=False)
    closing_day = Column(Integer, nullable=False)  # 1-31
    due_day = Column(Integer, nullable=False)  # 1-31
    currency = Column(String(3), default="USD")
    credit_limit = Column(Float, nullable=True)
    is_active = Column(Boolean, default=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class CreditCardPurchase(Base):
    __tablename__ = "credit_card_purchases"
    
    id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey('credit_cards.id', ondelete='CASCADE'), nullable=False)
    transaction_id = Column(Integer, ForeignKey('transactions.id', ondelete='SET NULL'), nullable=True)
    purchase_date = Column(Date, nullable=False)
    total_amount = Column(Float, nullable=False)
    category = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    installments = Column(Integer, default=1)
    has_financing = Column(Boolean, default=False)
    currency = Column(String(3), default="ARS")  # ARS or USD
    exchange_rate = Column(Float, nullable=True)  # Exchange rate at purchase time (for USD purchases)
    amount_in_pesos = Column(Float, nullable=True)  # Total in ARS (for USD: total_amount * exchange_rate)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class InstallmentPlan(Base):
    __tablename__ = "installment_plans"
    
    id = Column(Integer, primary_key=True, index=True)
    purchase_id = Column(Integer, ForeignKey('credit_card_purchases.id', ondelete='CASCADE'), nullable=False, unique=True)
    debt_id = Column(Integer, ForeignKey('budget_items.id', ondelete='SET NULL'), nullable=True)
    total_amount = Column(Float, nullable=False)
    number_of_installments = Column(Integer, nullable=False)
    interest_rate = Column(Float, default=0.0)
    start_date = Column(Date, nullable=False)
    plan_type = Column(SQLEnum(InstallmentPlanType, values_callable=lambda x: [e.value for e in x]), default=InstallmentPlanType.REGULAR)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class InstallmentScheduleItem(Base):
    __tablename__ = "installment_schedule"
    
    id = Column(Integer, primary_key=True, index=True)
    plan_id = Column(Integer, ForeignKey('installment_plans.id', ondelete='CASCADE'), nullable=False)
    installment_number = Column(Integer, nullable=False)
    due_date = Column(Date, nullable=False)
    principal_amount = Column(Float, nullable=False)
    interest_amount = Column(Float, default=0.0)
    total_installment_amount = Column(Float, nullable=False)
    status = Column(SQLEnum(InstallmentStatus, values_callable=lambda x: [e.value for e in x]), default=InstallmentStatus.PENDING)
    paid_date = Column(Date, nullable=True)
    payment_transaction_id = Column(Integer, ForeignKey('transactions.id', ondelete='SET NULL'), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class CreditCardStatement(Base):
    __tablename__ = "credit_card_statements"
    
    id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey('credit_cards.id', ondelete='CASCADE'), nullable=False)
    period_start = Column(Date, nullable=False)
    period_end = Column(Date, nullable=False)
    statement_date = Column(Date, nullable=False)
    due_date = Column(Date, nullable=False)
    previous_balance = Column(Float, default=0.0)
    total_purchases = Column(Float, default=0.0)
    total_installments = Column(Float, default=0.0)
    total_interest = Column(Float, default=0.0)
    total_fees = Column(Float, default=0.0)
    total_taxes = Column(Float, default=0.0)
    total_credits = Column(Float, default=0.0)
    total_amount = Column(Float, nullable=False)
    minimum_payment = Column(Float, default=0.0)
    paid_amount = Column(Float, default=0.0)
    status = Column(SQLEnum(StatementStatus, values_callable=lambda x: [e.value for e in x]), default=StatementStatus.PENDING)
    payment_date = Column(Date, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class CreditCardPayment(Base):
    __tablename__ = "credit_card_payments"
    
    id = Column(Integer, primary_key=True, index=True)
    transaction_id = Column(Integer, ForeignKey('transactions.id', ondelete='SET NULL'), nullable=True)
    statement_id = Column(Integer, ForeignKey('credit_card_statements.id', ondelete='SET NULL'), nullable=True)
    card_id = Column(Integer, ForeignKey('credit_cards.id', ondelete='CASCADE'), nullable=False)
    payment_date = Column(Date, nullable=False)
    amount_paid = Column(Float, nullable=False)
    payment_method = Column(String(50), default="Transfer")
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# ============================================================================
# APP SETTINGS
# ============================================================================

class CreditCardPeriodConfig(Base):
    """Per-period override for closing_day and due_day.
    Falls back to CreditCard defaults when no row exists."""
    __tablename__ = "credit_card_period_configs"

    id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey('credit_cards.id', ondelete='CASCADE'), nullable=False)
    year = Column(Integer, nullable=False)
    month = Column(Integer, nullable=False)  # 1-12
    closing_day = Column(Integer, nullable=False)  # 1-31
    due_day = Column(Integer, nullable=False)  # 1-31
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        UniqueConstraint('card_id', 'year', 'month', name='uq_card_period_config'),
    )

# ============================================================================

class AppSetting(Base):
    __tablename__ = "app_settings"
    
    id = Column(Integer, primary_key=True, index=True)
    key = Column(String(100), unique=True, nullable=False, index=True)
    value = Column(String(500), nullable=False)
    description = Column(String(255), nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# ============================================================================
# MONTHLY CLOSING
# ============================================================================

class MonthClosing(Base):
    __tablename__ = "month_closings"

    id = Column(Integer, primary_key=True, index=True)
    year = Column(Integer, nullable=False)
    month = Column(Integer, nullable=False)  # 1-12
    total_ingresos = Column(Float, nullable=False, default=0.0)
    total_gastos = Column(Float, nullable=False, default=0.0)
    balance = Column(Float, nullable=False, default=0.0)
    carry_over_transaction_id = Column(Integer, ForeignKey('transactions.id', ondelete='SET NULL'), nullable=True)
    closed_by = Column(String(100), nullable=True)
    closed_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        UniqueConstraint('year', 'month', name='uq_month_closings_year_month'),
    )

def init_db():
    """Initialize database tables"""
    Base.metadata.create_all(bind=engine)

def get_db():
    """Dependency for getting database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
