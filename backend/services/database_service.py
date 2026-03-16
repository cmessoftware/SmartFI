from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import text
from database.database import Transaction as DBTransaction, Category, User as DBUser, Debt as DBDebt
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
                detalle=transaction_data.get('detalle', ''),
                debt_id=transaction_data.get('debt_id')  # Agrega relación con deuda
            )
            
            db.add(db_transaction)
            db.commit()
            db.refresh(db_transaction)
            
            # Si la transacción está vinculada a una deuda, actualizar monto pagado
            if db_transaction.debt_id and transaction_data['tipo'] == 'Gasto':
                debt = db.query(DBDebt).filter(DBDebt.id == db_transaction.debt_id).first()
                if debt:
                    debt.monto_pagado += float(transaction_data['monto'])
                    
                    # Actualizar estado según monto pagado usando strings directamente
                    if debt.monto_pagado >= debt.monto_total:
                        debt.status = 'PAGADA'
                    elif debt.monto_pagado > 0:
                        debt.status = 'Pago parcial'
                    else:
                        debt.status = 'PENDIENTE'
                    
                    debt.updated_at = datetime.utcnow()
                    db.commit()
                    logger.info(f"✅ Updated debt {debt.id} payment: {debt.monto_pagado}/{debt.monto_total} - Status: {debt.status}")
            
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
                    'detalle': t.detalle or '',
                    'debt_id': t.debt_id  # Agregar debt_id para mostrar vinculación
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
            
            # Manejar cambios en debt_id o monto
            old_debt_id = db_transaction.debt_id
            old_monto = db_transaction.monto
            new_debt_id = transaction_data.get('debt_id', db_transaction.debt_id)
            new_monto = float(transaction_data.get('monto', old_monto))
            
            # Si cambia la deuda o el monto, actualizar deudas
            if db_transaction.tipo == 'Gasto' and (old_debt_id != new_debt_id or old_monto != new_monto):
                # Restar monto de deuda anterior
                if old_debt_id:
                    old_debt = db.query(DBDebt).filter(DBDebt.id == old_debt_id).first()
                    if old_debt:
                        old_debt.monto_pagado = max(0, old_debt.monto_pagado - old_monto)
                        # Actualizar estado según monto pagado
                        if old_debt.monto_pagado >= old_debt.monto_total:
                            old_debt.status = 'PAGADA'
                        elif old_debt.monto_pagado > 0:
                            old_debt.status = 'Pago parcial'
                        else:
                            old_debt.status = 'PENDIENTE'
                        old_debt.updated_at = datetime.utcnow()
                        logger.info(f"✅ Removed {old_monto} from debt {old_debt_id} - Status: {old_debt.status}")
                
                # Sumar monto a deuda nueva
                if new_debt_id:
                    new_debt = db.query(DBDebt).filter(DBDebt.id == new_debt_id).first()
                    if new_debt:
                        new_debt.monto_pagado += new_monto
                        # Actualizar estado según monto pagado
                        if new_debt.monto_pagado >= new_debt.monto_total:
                            new_debt.status = 'PAGADA'
                        elif new_debt.monto_pagado > 0:
                            new_debt.status = 'Pago parcial'
                        else:
                            new_debt.status = 'PENDIENTE'
                        new_debt.updated_at = datetime.utcnow()
                        logger.info(f"✅ Added {new_monto} to debt {new_debt_id} - Status: {new_debt.status}")
            
            # Update fields
            if 'fecha' in transaction_data:
                db_transaction.fecha = transaction_data['fecha']
            if 'tipo' in transaction_data:
                db_transaction.tipo = transaction_data['tipo']
            if 'categoria' in transaction_data:
                db_transaction.categoria = transaction_data['categoria']
            if 'monto' in transaction_data:
                db_transaction.monto = new_monto
            if 'necesidad' in transaction_data:
                db_transaction.necesidad = transaction_data['necesidad']
            if 'forma_pago' in transaction_data:
                db_transaction.forma_pago = transaction_data['forma_pago']
            if 'partida' in transaction_data:
                db_transaction.partida = transaction_data['partida']
            if 'detalle' in transaction_data:
                db_transaction.detalle = transaction_data['detalle']
            if 'debt_id' in transaction_data:
                db_transaction.debt_id = transaction_data['debt_id']
            
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
            
            # Si la transacción estaba vinculada a una deuda, actualizar monto pagado
            if db_transaction.debt_id:
                debt = db.query(DBDebt).filter(DBDebt.id == db_transaction.debt_id).first()
                if debt:
                    debt.monto_pagado = max(0, debt.monto_pagado - float(db_transaction.monto))
                    # Actualizar estado según monto pagado
                    if debt.monto_pagado >= debt.monto_total:
                        debt.status = 'PAGADA'
                    elif debt.monto_pagado > 0:
                        debt.status = 'Pago parcial'
                    else:
                        debt.status = 'PENDIENTE'
                    debt.updated_at = datetime.utcnow()
                    db.commit()
                    logger.info(f"✅ Updated debt {debt.id} payment after deletion: {debt.monto_pagado}/{debt.monto_total} - Status: {debt.status}")
            
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
