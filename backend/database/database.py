from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Enum as SQLEnum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
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

# Models
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
    partida = Column(String, nullable=False)
    detalle = Column(String(50), nullable=True)
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
