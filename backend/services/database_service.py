from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import text, extract, func
from database.database import Transaction as DBTransaction, Category, User as DBUser, Debt as DBDebt, MonthClosing
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

    def _resolve_category_id(self, db, transaction_data: Dict) -> int:
        """Resolve category_id from transaction data. Accepts category_id directly or category name."""
        category_id = transaction_data.get('category_id')
        if category_id:
            return int(category_id)
        # Fallback: look up by category name
        category_name = transaction_data.get('category', '')
        if category_name:
            cat = db.query(Category).filter(Category.name == category_name).first()
            if cat:
                return cat.id
            # Auto-create if not found
            new_cat = Category(name=category_name)
            db.add(new_cat)
            db.flush()
            return new_cat.id
        raise ValueError("category_id or category name is required")

    def add_transaction(self, transaction_data: Dict) -> Optional[int]:
        """Add a single transaction to the database"""
        db = next(get_db())
        try:
            # Parse timestamp if it's a string
            ts = transaction_data.get('timestamp')
            if isinstance(ts, str):
                try:
                    ts = datetime.fromisoformat(ts.replace('Z', '+00:00'))
                except:
                    ts = datetime.utcnow()
            else:
                ts = datetime.utcnow()

            category_id = self._resolve_category_id(db, transaction_data)

            db_transaction = DBTransaction(
                timestamp=ts,
                date=transaction_data['date'],
                type=transaction_data['type'],
                category_id=category_id,
                amount=float(transaction_data['amount']),
                necessity=transaction_data['necessity'],
                payment_method=transaction_data.get('payment_method', 'Débito'),
                detail=transaction_data.get('detail', ''),
                debt_id=transaction_data.get('debt_id'),
                assignment_status=transaction_data.get('assignment_status', 'ASIGNADA_MANUAL')
            )
            
            db.add(db_transaction)
            db.commit()
            db.refresh(db_transaction)
            
            # Si la transacción está vinculada a un presupuesto, actualizar monto ejecutado
            if db_transaction.debt_id:
                debt = db.query(DBDebt).filter(DBDebt.id == db_transaction.debt_id).first()
                if debt:
                    debt.monto_ejecutado = (debt.monto_ejecutado or 0) + float(transaction_data['amount'])
                    
                    if transaction_data['type'] == 'Gasto':
                        if debt.monto_ejecutado >= debt.monto_total:
                            debt.status = 'PAGADA'
                        elif debt.monto_ejecutado > 0:
                            debt.status = 'Pago parcial'
                        else:
                            debt.status = 'PENDIENTE'
                    
                    debt.updated_at = datetime.utcnow()
                    db.commit()
                    logger.info(f"✅ Updated debt {debt.id} executed amount: {debt.monto_ejecutado}/{debt.monto_total} - Type: {transaction_data['type']}")
            
            logger.info(f"✅ Transaction {db_transaction.id} saved to database")
            return db_transaction.id
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error saving transaction: {e}")
            print(f"❌ SQLAlchemyError details: {e}")
            import traceback
            traceback.print_exc()
            raise
        finally:
            db.close()

    def add_transactions_batch(self, transactions: List[Dict]) -> bool:
        """Add multiple transactions to the database"""
        db = next(get_db())
        try:
            db_transactions = []
            for t_data in transactions:
                ts = t_data.get('timestamp')
                if isinstance(ts, str):
                    try:
                        ts = datetime.fromisoformat(ts.replace('Z', '+00:00'))
                    except:
                        ts = datetime.utcnow()
                else:
                    ts = datetime.utcnow()

                category_id = self._resolve_category_id(db, t_data)

                db_transaction = DBTransaction(
                    timestamp=ts,
                    date=t_data['date'],
                    type=t_data['type'],
                    category_id=category_id,
                    amount=float(t_data['amount']),
                    necessity=t_data['necessity'],
                    payment_method=t_data.get('payment_method', 'Débito'),
                    detail=t_data.get('detail', ''),
                    debt_id=t_data.get('debt_id'),
                    assignment_status=t_data.get('assignment_status', 'ASIGNADA_MANUAL')
                )
                db_transactions.append(db_transaction)
            
            db.bulk_save_objects(db_transactions)
            db.commit()
            
            for t_data in transactions:
                if t_data.get('debt_id'):
                    debt = db.query(DBDebt).filter(DBDebt.id == t_data['debt_id']).first()
                    if debt:
                        debt.monto_ejecutado = (debt.monto_ejecutado or 0) + float(t_data['amount'])
                        debt.updated_at = datetime.utcnow()
            
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
            transactions = db.query(DBTransaction).order_by(DBTransaction.date.desc()).all()
            
            result = []
            for t in transactions:
                result.append({
                    'id': t.id,
                    'timestamp': t.timestamp.isoformat() if t.timestamp else None,
                    'date': t.date,
                    'type': t.type.value if hasattr(t.type, 'value') else t.type,
                    'category_id': t.category_id,
                    'category': t.category.name if t.category else '',
                    'amount': float(t.amount),
                    'necessity': t.necessity.value if hasattr(t.necessity, 'value') else t.necessity,
                    'payment_method': t.payment_method,
                    'detail': t.detail or '',
                    'debt_id': t.debt_id
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
            
            old_debt_id = db_transaction.debt_id
            old_amount = db_transaction.amount
            new_debt_id = transaction_data.get('debt_id', db_transaction.debt_id)
            new_amount = float(transaction_data.get('amount', old_amount))
            
            if old_debt_id != new_debt_id or old_amount != new_amount:
                if old_debt_id:
                    old_debt = db.query(DBDebt).filter(DBDebt.id == old_debt_id).first()
                    if old_debt:
                        old_debt.monto_ejecutado = max(0, (old_debt.monto_ejecutado or 0) - old_amount)
                        if db_transaction.type == 'Gasto':
                            if old_debt.monto_ejecutado >= old_debt.monto_total:
                                old_debt.status = 'PAGADA'
                            elif old_debt.monto_ejecutado > 0:
                                old_debt.status = 'Pago parcial'
                            else:
                                old_debt.status = 'PENDIENTE'
                        old_debt.updated_at = datetime.utcnow()
                        logger.info(f"✅ Removed {old_amount} from budget {old_debt_id} - Executed: {old_debt.monto_ejecutado}")
                
                if new_debt_id:
                    new_debt = db.query(DBDebt).filter(DBDebt.id == new_debt_id).first()
                    if new_debt:
                        new_debt.monto_ejecutado = (new_debt.monto_ejecutado or 0) + new_amount
                        if db_transaction.type == 'Gasto':
                            if new_debt.monto_ejecutado >= new_debt.monto_total:
                                new_debt.status = 'PAGADA'
                            elif new_debt.monto_ejecutado > 0:
                                new_debt.status = 'Pago parcial'
                            else:
                                new_debt.status = 'PENDIENTE'
                        new_debt.updated_at = datetime.utcnow()
                        logger.info(f"✅ Added {new_amount} to budget {new_debt_id} - Executed: {new_debt.monto_ejecutado}")
            
            # Update fields
            if 'date' in transaction_data:
                db_transaction.date = transaction_data['date']
            if 'type' in transaction_data:
                db_transaction.type = transaction_data['type']
            if 'category' in transaction_data or 'category_id' in transaction_data:
                db_transaction.category_id = self._resolve_category_id(db, transaction_data)
            if 'amount' in transaction_data:
                db_transaction.amount = new_amount
            if 'necessity' in transaction_data:
                db_transaction.necessity = transaction_data['necessity']
            if 'payment_method' in transaction_data:
                db_transaction.payment_method = transaction_data['payment_method']
            if 'detail' in transaction_data:
                db_transaction.detail = transaction_data['detail']
            if 'debt_id' in transaction_data:
                db_transaction.debt_id = transaction_data['debt_id']
            
            db.commit()
            logger.info(f"✅ Transaction {transaction_id} updated in database")
            return True
        except (SQLAlchemyError, ValueError) as e:
            db.rollback()
            logger.error(f"❌ Error updating transaction {transaction_id}: {e}")
            raise
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
            
            if db_transaction.debt_id:
                debt = db.query(DBDebt).filter(DBDebt.id == db_transaction.debt_id).first()
                if debt:
                    debt.monto_ejecutado = max(0, (debt.monto_ejecutado or 0) - float(db_transaction.amount))
                    if db_transaction.type == 'Gasto':
                        if debt.monto_ejecutado >= debt.monto_total:
                            debt.status = 'PAGADA'
                        elif debt.monto_ejecutado > 0:
                            debt.status = 'Pago parcial'
                        else:
                            debt.status = 'PENDIENTE'
                    debt.updated_at = datetime.utcnow()
                    db.commit()
                    logger.info(f"✅ Updated budget {debt.id} after deletion: Executed={debt.monto_ejecutado}/{debt.monto_total}")
            
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

    def get_categories(self) -> List[Dict]:
        """Get all categories from the database"""
        db = next(get_db())
        try:
            cats = db.query(Category).order_by(Category.name).all()
            return [{'id': c.id, 'name': c.name} for c in cats]
        except SQLAlchemyError as e:
            logger.error(f"❌ Error getting categories: {e}")
            return []
        finally:
            db.close()

    def add_category(self, name: str) -> Dict:
        """Add a new category to the database"""
        db = next(get_db())
        try:
            existing = db.query(Category).filter(Category.name == name).first()
            if existing:
                raise ValueError(f"La categoría '{name}' ya existe")
            new_cat = Category(name=name)
            db.add(new_cat)
            db.commit()
            db.refresh(new_cat)
            return {'id': new_cat.id, 'name': new_cat.name}
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error adding category: {e}")
            raise
        finally:
            db.close()

    def delete_category(self, category_id: int) -> bool:
        """Delete a category from the database"""
        db = next(get_db())
        try:
            cat = db.query(Category).filter(Category.id == category_id).first()
            if not cat:
                raise ValueError(f"Categoría con id {category_id} no encontrada")
            db.delete(cat)
            db.commit()
            return True
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"❌ Error deleting category: {e}")
            raise
        finally:
            db.close()

    # ======================================================================
    # MONTH CLOSING
    # ======================================================================

    def get_month_closing(self, year: int, month: int) -> Optional[Dict]:
        """Get the closing record for a specific month, if it exists"""
        db = next(get_db())
        try:
            closing = db.query(MonthClosing).filter(
                MonthClosing.year == year,
                MonthClosing.month == month
            ).first()
            if not closing:
                return None
            return {
                'id': closing.id,
                'year': closing.year,
                'month': closing.month,
                'total_ingresos': closing.total_ingresos,
                'total_gastos': closing.total_gastos,
                'balance': closing.balance,
                'carry_over_transaction_id': closing.carry_over_transaction_id,
                'closed_by': closing.closed_by,
                'closed_at': closing.closed_at.isoformat() if closing.closed_at else None,
            }
        finally:
            db.close()

    def get_all_closings(self) -> List[Dict]:
        """Get all month closings ordered by date desc"""
        db = next(get_db())
        try:
            closings = db.query(MonthClosing).order_by(
                MonthClosing.year.desc(), MonthClosing.month.desc()
            ).all()
            return [{
                'id': c.id,
                'year': c.year,
                'month': c.month,
                'total_ingresos': c.total_ingresos,
                'total_gastos': c.total_gastos,
                'balance': c.balance,
                'carry_over_transaction_id': c.carry_over_transaction_id,
                'closed_by': c.closed_by,
                'closed_at': c.closed_at.isoformat() if c.closed_at else None,
            } for c in closings]
        finally:
            db.close()

    def calculate_month_balance(self, year: int, month: int, cc_purchases_total: float = 0.0) -> Dict:
        """Calculate ingresos, gastos, and balance for a month without closing it"""
        db = next(get_db())
        try:
            month_prefix = f"{year}-{month:02d}"
            ingresos = float(db.query(
                func.coalesce(func.sum(DBTransaction.amount), 0)
            ).filter(
                DBTransaction.date.like(f"{month_prefix}%"),
                DBTransaction.type == 'Ingreso'
            ).scalar())
            gastos_txn = float(db.query(
                func.coalesce(func.sum(DBTransaction.amount), 0)
            ).filter(
                DBTransaction.date.like(f"{month_prefix}%"),
                DBTransaction.type == 'Gasto'
            ).scalar())
            total_gastos = gastos_txn + cc_purchases_total
            balance = round(ingresos - total_gastos, 2)
            return {'total_ingresos': ingresos, 'total_gastos': total_gastos, 'balance': balance}
        finally:
            db.close()

    def close_month(self, year: int, month: int, closed_by: str, cc_purchases_total: float = 0.0) -> Dict:
        """
        Close a month: calculate balance and create carry-over transaction in next month.
        If the month is already closed, it will be reopened and re-closed.
        """
        db = next(get_db())
        try:
            # If already closed, reopen first (delete old closing + carry-over)
            existing = db.query(MonthClosing).filter(
                MonthClosing.year == year,
                MonthClosing.month == month
            ).first()
            if existing:
                if existing.carry_over_transaction_id:
                    old_txn = db.query(DBTransaction).filter(
                        DBTransaction.id == existing.carry_over_transaction_id
                    ).first()
                    if old_txn:
                        db.delete(old_txn)
                db.delete(existing)
                db.flush()
                logger.info(f"🔄 Re-cerrando mes {month}/{year} (cierre anterior eliminado)")

            month_prefix = f"{year}-{month:02d}"
            
            ingresos = db.query(
                func.coalesce(func.sum(DBTransaction.amount), 0)
            ).filter(
                DBTransaction.date.like(f"{month_prefix}%"),
                DBTransaction.type == 'Ingreso'
            ).scalar()
            ingresos = float(ingresos)

            gastos_txn = db.query(
                func.coalesce(func.sum(DBTransaction.amount), 0)
            ).filter(
                DBTransaction.date.like(f"{month_prefix}%"),
                DBTransaction.type == 'Gasto'
            ).scalar()
            gastos_txn = float(gastos_txn)

            total_gastos = gastos_txn + cc_purchases_total
            balance = round(ingresos - total_gastos, 2)

            # Determine next month
            if month == 12:
                next_month, next_year = 1, year + 1
            else:
                next_month, next_year = month + 1, year

            carry_over_txn_id = None
            if balance != 0:
                # Find or create "Saldo mes anterior" category
                cat = db.query(Category).filter(Category.name == "Saldo mes anterior").first()
                if not cat:
                    cat = Category(name="Saldo mes anterior")
                    db.add(cat)
                    db.flush()

                # Transaction type: Ingreso if positive balance, Gasto if negative
                txn_type = 'Ingreso' if balance > 0 else 'Gasto'
                txn_amount = abs(balance)
                next_date = f"{next_year}-{next_month:02d}-01"

                carry_over_txn = DBTransaction(
                    timestamp=datetime.utcnow(),
                    date=next_date,
                    type=txn_type,
                    category_id=cat.id,
                    amount=txn_amount,
                    necessity='Necesario',
                    payment_method='Cierre de mes',
                    detail=f"Saldo {MONTH_NAMES[month - 1]} {year}",
                    assignment_status='ASIGNADA_AUTOMATICA'
                )
                db.add(carry_over_txn)
                db.flush()
                carry_over_txn_id = carry_over_txn.id

            # Record the closing
            closing = MonthClosing(
                year=year,
                month=month,
                total_ingresos=ingresos,
                total_gastos=total_gastos,
                balance=balance,
                carry_over_transaction_id=carry_over_txn_id,
                closed_by=closed_by
            )
            db.add(closing)
            db.commit()

            logger.info(f"✅ Mes {month}/{year} cerrado. Balance: {balance}. Carry-over txn: {carry_over_txn_id}")
            
            return {
                'id': closing.id,
                'year': year,
                'month': month,
                'total_ingresos': ingresos,
                'total_gastos': total_gastos,
                'balance': balance,
                'carry_over_transaction_id': carry_over_txn_id,
                'closed_by': closed_by,
                'closed_at': closing.closed_at.isoformat() if closing.closed_at else None,
            }
        except ValueError:
            db.rollback()
            raise
        except Exception as e:
            db.rollback()
            logger.error(f"❌ Error closing month {month}/{year}: {e}")
            raise
        finally:
            db.close()

    def reopen_month(self, year: int, month: int) -> bool:
        """Reopen a closed month: delete the closing record and the carry-over transaction"""
        db = next(get_db())
        try:
            closing = db.query(MonthClosing).filter(
                MonthClosing.year == year,
                MonthClosing.month == month
            ).first()
            if not closing:
                raise ValueError(f"El mes {month}/{year} no está cerrado")

            # Delete carry-over transaction if it exists
            if closing.carry_over_transaction_id:
                txn = db.query(DBTransaction).filter(
                    DBTransaction.id == closing.carry_over_transaction_id
                ).first()
                if txn:
                    db.delete(txn)

            db.delete(closing)
            db.commit()
            logger.info(f"✅ Mes {month}/{year} reabierto")
            return True
        except ValueError:
            db.rollback()
            raise
        except Exception as e:
            db.rollback()
            logger.error(f"❌ Error reopening month {month}/{year}: {e}")
            raise
        finally:
            db.close()

MONTH_NAMES = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

# Create singleton instance
database_service = DatabaseService()
