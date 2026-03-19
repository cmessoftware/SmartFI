from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Enum as SQLEnum, ForeignKey, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import os
from dotenv import load_dotenv
import enum

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://admin:admin123@localhost:5432/fin_per_db")

# Create engine
engine = create_engine(DATABASE_URL)
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

# Models
class Debt(Base):
    __tablename__ = "debts"
    
    id = Column(Integer, primary_key=True, index=True)
    fecha = Column(String, nullable=False)
    tipo = Column(String, nullable=False)  # Tarjeta, Préstamo, Crédito, etc.
    categoria = Column(String, nullable=False)
    monto_total = Column(Float, nullable=False)
    monto_pagado = Column(Float, default=0.0, nullable=False)
    detalle = Column(String, nullable=True)
    fecha_vencimiento = Column(String, nullable=False)
    status = Column(SQLEnum(DebtStatus, values_callable=lambda x: [e.value for e in x]), default=DebtStatus.PENDIENTE, nullable=False)
    
    # Nuevas columnas Fase A - Budget Model Refactor
    tipo_presupuesto = Column(SQLEnum(BudgetType, values_callable=lambda x: [e.value for e in x]), default=BudgetType.OBLIGATION, nullable=False)
    tipo_flujo = Column(SQLEnum(FlowType, values_callable=lambda x: [e.value for e in x]), default=FlowType.GASTO, nullable=False)
    monto_ejecutado = Column(Float, default=0.0, nullable=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    marca_temporal = Column(DateTime, default=datetime.utcnow)
    fecha = Column(String, nullable=False)
    tipo = Column(SQLEnum(TransactionType), nullable=False)
    categoria = Column(String, nullable=False)
    monto = Column(Float, nullable=False)
    necesidad = Column(SQLEnum(NecessityType), nullable=False)
    forma_pago = Column(String, default="Débito", nullable=False)
    detalle = Column(String(50), nullable=True)
    debt_id = Column(Integer, ForeignKey('debts.id'), nullable=True)  # Nueva relación con deudas
    
    # Nueva columna - estado de asignación automática/manual
    estado_asignacion = Column(SQLEnum(AssignmentStatus, values_callable=lambda x: [e.value for e in x]), default=AssignmentStatus.ASIGNADA_MANUAL, nullable=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)

class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False, index=True)
    full_name = Column(String, nullable=True)
    role = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

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
