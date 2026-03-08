from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import text
from database.database import Transaction as DBTransaction, Category, User as DBUser
from database.database import get_db, init_db, engine
from typing import List, Dict, Optional
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class DatabaseService:
    def __init__(self):
        """Initialize database service"""
        self.initialized = False
        try:
            init_db()
            self.initialized = True
            logger.info("✅ Database initialized successfully")
        except Exception as e:
            logger.error(f"❌ Failed to initialize database: {e}")
            self.initialized = False

    def is_connected(self) -> bool:
        """Check if database is connected"""
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return True
        except Exception:
            return False

    def add_transaction(self, transaction_data: Dict) -> Optional[int]:
        """Add a single transaction to the database"""
        db = next(get_db())
        try:
            # Parse marca_temporal if it's a string
            marca_temporal = transaction_data.get('marca_temporal')
            if isinstance(marca_temporal, str):
                try:
                    marca_temporal = datetime.fromisoformat(marca_temporal.replace('Z', '+00:00'))
                except:
                    marca_temporal = datetime.utcnow()
            else:
                marca_temporal = datetime.utcnow()

            db_transaction = DBTransaction(
                marca_temporal=marca_temporal,
                fecha=transaction_data['fecha'],
                tipo=transaction_data['tipo'],
                categoria=transaction_data['categoria'],
                monto=float(transaction_data['monto']),
                necesidad=transaction_data['necesidad'],
                forma_pago=transaction_data.get('forma_pago', 'Débito'),
                partida=transaction_data.get('partida', transaction_data['categoria']),
                detalle=transaction_data.get('detalle', '')
            )
            
            db.add(db_transaction)
            db.commit()
            db.refresh(db_transaction)
            
            logger.info(f"✅ Transaction {db_transaction.id} saved to database")
            return db_transaction.id
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error saving transaction: {e}")
            return None
        finally:
            db.close()

    def add_transactions_batch(self, transactions: List[Dict]) -> bool:
        """Add multiple transactions to the database"""
        db = next(get_db())
        try:
            db_transactions = []
            for t_data in transactions:
                # Parse marca_temporal if it's a string
                marca_temporal = t_data.get('marca_temporal')
                if isinstance(marca_temporal, str):
                    try:
                        marca_temporal = datetime.fromisoformat(marca_temporal.replace('Z', '+00:00'))
                    except:
                        marca_temporal = datetime.utcnow()
                else:
                    marca_temporal = datetime.utcnow()

                db_transaction = DBTransaction(
                    marca_temporal=marca_temporal,
                    fecha=t_data['fecha'],
                    tipo=t_data['tipo'],
                    categoria=t_data['categoria'],
                    monto=float(t_data['monto']),
                    necesidad=t_data['necesidad'],
                    forma_pago=t_data.get('forma_pago', 'Débito'),
                    partida=t_data.get('partida', t_data['categoria']),
                    detalle=t_data.get('detalle', '')
                )
                db_transactions.append(db_transaction)
            
            db.bulk_save_objects(db_transactions)
            db.commit()
            
            logger.info(f"✅ {len(transactions)} transactions saved to database")
            return True
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error saving batch transactions: {e}")
            return False
        finally:
            db.close()

    def get_all_transactions(self) -> List[Dict]:
        """Get all transactions from the database"""
        db = next(get_db())
        try:
            transactions = db.query(DBTransaction).order_by(DBTransaction.fecha.desc()).all()
            
            result = []
            for t in transactions:
                result.append({
                    'id': t.id,
                    'marca_temporal': t.marca_temporal.isoformat() if t.marca_temporal else None,
                    'fecha': t.fecha,
                    'tipo': t.tipo.value if hasattr(t.tipo, 'value') else t.tipo,
                    'categoria': t.categoria,
                    'monto': float(t.monto),
                    'necesidad': t.necesidad.value if hasattr(t.necesidad, 'value') else t.necesidad,
                    'forma_pago': t.forma_pago,
                    'partida': t.partida,
                    'detalle': t.detalle or ''
                })
            
            logger.info(f"✅ Retrieved {len(result)} transactions from database")
            return result
        except SQLAlchemyError as e:
            logger.error(f"❌ Error getting transactions: {e}")
            return []
        finally:
            db.close()

    def update_transaction(self, transaction_id: int, transaction_data: Dict) -> bool:
        """Update a transaction in the database"""
        db = next(get_db())
        try:
            db_transaction = db.query(DBTransaction).filter(DBTransaction.id == transaction_id).first()
            
            if not db_transaction:
                logger.warning(f"⚠️ Transaction {transaction_id} not found")
                return False
            
            # Update fields
            if 'fecha' in transaction_data:
                db_transaction.fecha = transaction_data['fecha']
            if 'tipo' in transaction_data:
                db_transaction.tipo = transaction_data['tipo']
            if 'categoria' in transaction_data:
                db_transaction.categoria = transaction_data['categoria']
            if 'monto' in transaction_data:
                db_transaction.monto = float(transaction_data['monto'])
            if 'necesidad' in transaction_data:
                db_transaction.necesidad = transaction_data['necesidad']
            if 'forma_pago' in transaction_data:
                db_transaction.forma_pago = transaction_data['forma_pago']
            if 'partida' in transaction_data:
                db_transaction.partida = transaction_data['partida']
            if 'detalle' in transaction_data:
                db_transaction.detalle = transaction_data['detalle']
            
            db.commit()
            logger.info(f"✅ Transaction {transaction_id} updated in database")
            return True
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error updating transaction {transaction_id}: {e}")
            return False
        finally:
            db.close()

    def delete_transaction(self, transaction_id: int) -> bool:
        """Delete a transaction from the database"""
        db = next(get_db())
        try:
            db_transaction = db.query(DBTransaction).filter(DBTransaction.id == transaction_id).first()
            
            if not db_transaction:
                logger.warning(f"⚠️ Transaction {transaction_id} not found")
                return False
            
            db.delete(db_transaction)
            db.commit()
            logger.info(f"✅ Transaction {transaction_id} deleted from database")
            return True
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error deleting transaction {transaction_id}: {e}")
            return False
        finally:
            db.close()

    def get_categories(self) -> List[str]:
        """Get all categories from the database"""
        # For now, return hardcoded categories
        # TODO: Store in database when implementing admin panel
        return [
            "Ahorro", "Comida", "Cuidado Personal", "Tarjeta VISA",
            "Educación", "Alquiler", "Hogar", "Impuestos",
            "Ingresos", "Ocio", "Préstamos", "Ropa",
            "Salud", "Seguros", "Servicios", "Trámites", "Transporte"
        ]

# Create singleton instance
database_service = DatabaseService()
