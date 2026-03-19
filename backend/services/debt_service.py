from database.database import SessionLocal, Debt, DebtStatus, Transaction, BudgetType, FlowType
from datetime import datetime
from sqlalchemy import func


class DebtService:
    def __init__(self):
        self.db = None

    def _get_db(self):
        """Get database session"""
        if self.db is None:
            self.db = SessionLocal()
        return self.db

    def is_connected(self):
        """Check if database is connected"""
        try:
            db = self._get_db()
            db.execute("SELECT 1")
            return True
        except Exception as e:
            print(f"Database connection error: {e}")
            return False

    def add_debt(self, debt_data):
        """Add a new debt to database"""
        try:
            db = self._get_db()
            
            monto_total = float(debt_data.get('monto_total', 0))
            monto_pagado = float(debt_data.get('monto_pagado', 0))
            fecha_vencimiento = debt_data.get('fecha_vencimiento')
            
            # Nuevos campos refactor
            tipo_presupuesto_str = debt_data.get('tipo_presupuesto', 'OBLIGATION')
            tipo_flujo_str = debt_data.get('tipo_flujo', 'Gasto')
            
            # Convertir strings a enums
            tipo_presupuesto = BudgetType.OBLIGATION if tipo_presupuesto_str == 'OBLIGATION' else BudgetType.VARIABLE
            tipo_flujo = FlowType.GASTO if tipo_flujo_str == 'Gasto' else FlowType.INGRESO
            
            # monto_ejecutado: inicializar con monto_pagado para compatibilidad
            monto_ejecutado = monto_pagado
            
            # Calcular estado inicial basado en monto ejecutado
            if monto_ejecutado >= monto_total:
                status = DebtStatus.PAGADA
            elif fecha_vencimiento < datetime.now().strftime('%Y-%m-%d'):
                status = DebtStatus.VENCIDA
            elif monto_ejecutado > 0:
                status = DebtStatus.PAGO_PARCIAL
            else:
                status = DebtStatus.PENDIENTE
            
            # Create debt object
            debt = Debt(
                fecha=debt_data.get('fecha'),
                tipo=debt_data.get('tipo'),
                categoria=debt_data.get('categoria'),
                monto_total=monto_total,
                monto_pagado=monto_pagado,
                detalle=debt_data.get('detalle'),
                fecha_vencimiento=fecha_vencimiento,
                status=status,
                tipo_presupuesto=tipo_presupuesto,
                tipo_flujo=tipo_flujo,
                monto_ejecutado=monto_ejecutado
            )
            
            db.add(debt)
            db.commit()
            db.refresh(debt)
            
            return debt.id
        except Exception as e:
            db.rollback()
            print(f"Error adding debt: {e}")
            return None

    def get_all_debts(self):
        """Get all debts from database"""
        try:
            db = self._get_db()
            debts = db.query(Debt).order_by(Debt.fecha_vencimiento.desc()).all()
            
            result = []
            for debt in debts:
                # Calculate remaining amount
                monto_restante = debt.monto_total - debt.monto_pagado
                
                # Retornar el status actual de la DB (ya actualizado por otras operaciones)
                result.append({
                    'id': debt.id,
                    'fecha': debt.fecha,
                    'tipo': debt.tipo,
                    'categoria': debt.categoria,
                    'monto_total': debt.monto_total,
                    'monto_pagado': debt.monto_pagado,
                    'monto_restante': monto_restante,
                    'detalle': debt.detalle,
                    'fecha_vencimiento': debt.fecha_vencimiento,
                    'status': debt.status.value if hasattr(debt.status, 'value') else debt.status,
                    # Nuevos campos refactor
                    'tipo_presupuesto': debt.tipo_presupuesto.value if hasattr(debt.tipo_presupuesto, 'value') else debt.tipo_presupuesto,
                    'tipo_flujo': debt.tipo_flujo.value if hasattr(debt.tipo_flujo, 'value') else debt.tipo_flujo,
                    'monto_ejecutado': debt.monto_ejecutado,
                    'created_at': debt.created_at.isoformat() if debt.created_at else None,
                    'updated_at': debt.updated_at.isoformat() if debt.updated_at else None
                })
            
            return result
        except Exception as e:
            print(f"Error getting debts: {e}")
            return []

    def get_debt_by_id(self, debt_id):
        """Get a specific debt by ID"""
        try:
            db = self._get_db()
            debt = db.query(Debt).filter(Debt.id == debt_id).first()
            
            if not debt:
                return None
            
            monto_restante = debt.monto_total - debt.monto_pagado
            
            return {
                'id': debt.id,
                'fecha': debt.fecha,
                'tipo': debt.tipo,
                'categoria': debt.categoria,
                'monto_total': debt.monto_total,
                'monto_pagado': debt.monto_pagado,
                'monto_restante': monto_restante,
                'detalle': debt.detalle,
                'fecha_vencimiento': debt.fecha_vencimiento,
                'status': debt.status.value,
                # Nuevos campos refactor
                'tipo_presupuesto': debt.tipo_presupuesto.value if hasattr(debt.tipo_presupuesto, 'value') else debt.tipo_presupuesto,
                'tipo_flujo': debt.tipo_flujo.value if hasattr(debt.tipo_flujo, 'value') else debt.tipo_flujo,
                'monto_ejecutado': debt.monto_ejecutado,
                'created_at': debt.created_at.isoformat() if debt.created_at else None,
                'updated_at': debt.updated_at.isoformat() if debt.updated_at else None
            }
        except Exception as e:
            print(f"Error getting debt: {e}")
            return None

    def update_debt(self, debt_id, debt_data):
        """Update an existing debt"""
        try:
            db = self._get_db()
            debt = db.query(Debt).filter(Debt.id == debt_id).first()
            
            if not debt:
                return False
            
            # Update fields
            if 'fecha' in debt_data:
                debt.fecha = debt_data['fecha']
            if 'tipo' in debt_data:
                debt.tipo = debt_data['tipo']
            if 'categoria' in debt_data:
                debt.categoria = debt_data['categoria']
            if 'monto_total' in debt_data:
                debt.monto_total = float(debt_data['monto_total'])
            if 'monto_pagado' in debt_data:
                debt.monto_pagado = float(debt_data['monto_pagado'])
                # Sincronizar monto_ejecutado con monto_pagado (compatibilidad transitoria)
                if debt.tipo_presupuesto == BudgetType.OBLIGATION:
                    debt.monto_ejecutado = debt.monto_pagado
            if 'detalle' in debt_data:
                debt.detalle = debt_data['detalle']
            if 'fecha_vencimiento' in debt_data:
                debt.fecha_vencimiento = debt_data['fecha_vencimiento']
            if 'status' in debt_data:
                debt.status = debt_data['status']
            
            # Nuevos campos refactor
            if 'tipo_presupuesto' in debt_data:
                tipo_presupuesto_str = debt_data['tipo_presupuesto']
                debt.tipo_presupuesto = BudgetType.OBLIGATION if tipo_presupuesto_str == 'OBLIGATION' else BudgetType.VARIABLE
            if 'tipo_flujo' in debt_data:
                tipo_flujo_str = debt_data['tipo_flujo']
                debt.tipo_flujo = FlowType.GASTO if tipo_flujo_str == 'Gasto' else FlowType.INGRESO
            if 'monto_ejecutado' in debt_data:
                debt.monto_ejecutado = float(debt_data['monto_ejecutado'])
            
            # Recalcular estado basado en monto ejecutado
            if debt.monto_ejecutado >= debt.monto_total:
                debt.status = DebtStatus.PAGADA
            elif debt.fecha_vencimiento < datetime.now().strftime('%Y-%m-%d'):
                debt.status = DebtStatus.VENCIDA
            elif debt.monto_ejecutado > 0:
                debt.status = DebtStatus.PAGO_PARCIAL
            else:
                debt.status = DebtStatus.PENDIENTE
            
            debt.updated_at = datetime.utcnow()
            
            db.commit()
            return True
        except Exception as e:
            db.rollback()
            print(f"Error updating debt: {e}")
            return False

    def delete_debt(self, debt_id):
        """Delete a debt"""
        try:
            db = self._get_db()
            debt = db.query(Debt).filter(Debt.id == debt_id).first()
            
            if not debt:
                return False
            
            # Check if there are transactions linked to this debt
            linked_transactions = db.query(Transaction).filter(Transaction.debt_id == debt_id).count()
            if linked_transactions > 0:
                print(f"Cannot delete debt {debt_id}: {linked_transactions} transactions linked")
                return False
            
            db.delete(debt)
            db.commit()
            return True
        except Exception as e:
            db.rollback()
            print(f"Error deleting debt: {e}")
            return False

    def add_payment_to_debt(self, debt_id, payment_amount):
        """Add a payment to a debt (called when a transaction is linked to it)"""
        try:
            db = self._get_db()
            debt = db.query(Debt).filter(Debt.id == debt_id).first()
            
            if not debt:
                return False
            
            debt.monto_pagado += float(payment_amount)
            
            # Sincronizar monto_ejecutado con monto_pagado (compatibilidad transitoria)
            if debt.tipo_presupuesto == BudgetType.OBLIGATION:
                debt.monto_ejecutado = debt.monto_pagado
            
            debt.updated_at = datetime.utcnow()
            
            # Update status based on monto_ejecutado
            if debt.monto_ejecutado >= debt.monto_total:
                debt.status = DebtStatus.PAGADA
            elif debt.monto_ejecutado > 0:
                debt.status = DebtStatus.PAGO_PARCIAL
            else:
                debt.status = DebtStatus.PENDIENTE
            
            db.commit()
            return True
        except Exception as e:
            db.rollback()
            print(f"Error adding payment to debt: {e}")
            return False

    def remove_payment_from_debt(self, debt_id, payment_amount):
        """Remove a payment from a debt (called when a linked transaction is deleted)"""
        try:
            db = self._get_db()
            debt = db.query(Debt).filter(Debt.id == debt_id).first()
            
            if not debt:
                return False
            
            debt.monto_pagado = max(0, debt.monto_pagado - float(payment_amount))
            
            # Sincronizar monto_ejecutado con monto_pagado (compatibilidad transitoria)
            if debt.tipo_presupuesto == BudgetType.OBLIGATION:
                debt.monto_ejecutado = debt.monto_pagado
            
            debt.updated_at = datetime.utcnow()
            
            # Update status
            if debt.monto_pagado >= debt.monto_total:
                debt.status = DebtStatus.PAGADA
            elif debt.fecha_vencimiento < datetime.now().strftime('%Y-%m-%d'):
                debt.status = DebtStatus.VENCIDA
            elif debt.monto_pagado > 0:
                debt.status = DebtStatus.PAGO_PARCIAL
            else:
                debt.status = DebtStatus.PENDIENTE
            
            db.commit()
            return True
        except Exception as e:
            db.rollback()
            print(f"Error removing payment from debt: {e}")
            return False

    def get_debt_summary(self):
        """Get summary statistics of debts"""
        try:
            db = self._get_db()
            
            total_debts = db.query(func.count(Debt.id)).scalar()
            total_amount = db.query(func.sum(Debt.monto_total)).scalar() or 0
            total_paid = db.query(func.sum(Debt.monto_pagado)).scalar() or 0
            total_remaining = total_amount - total_paid
            
            # Conteos por estado
            pending_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.PENDIENTE
            ).scalar()
            
            partial_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.PAGO_PARCIAL
            ).scalar()
            
            overdue_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.VENCIDA
            ).scalar()
            
            paid_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.PAGADA
            ).scalar()
            
            # Montos por estado (resta de lo pendiente por pagar)
            pending_amount = db.query(
                func.sum(Debt.monto_total - Debt.monto_pagado)
            ).filter(
                Debt.status == DebtStatus.PENDIENTE
            ).scalar() or 0
            
            partial_amount = db.query(
                func.sum(Debt.monto_total - Debt.monto_pagado)
            ).filter(
                Debt.status == DebtStatus.PAGO_PARCIAL
            ).scalar() or 0
            
            overdue_amount = db.query(
                func.sum(Debt.monto_total - Debt.monto_pagado)
            ).filter(
                Debt.status == DebtStatus.VENCIDA
            ).scalar() or 0
            
            return {
                'total_debts': total_debts,
                'total_amount': float(total_amount),
                'total_paid': float(total_paid),
                'total_remaining': float(total_remaining),
                'pending_count': pending_count,
                'pending_amount': float(pending_amount),
                'partial_count': partial_count,
                'partial_amount': float(partial_amount),
                'overdue_count': overdue_count,
                'overdue_amount': float(overdue_amount),
                'paid_count': paid_count
            }
        except Exception as e:
            print(f"Error getting debt summary: {e}")
            return None


# Create global instance
debt_service = DebtService()
