from database.database import SessionLocal, BudgetItem, Debt, DebtStatus, Transaction, BudgetType, FlowType, InstallmentPlan, InstallmentScheduleItem, InstallmentStatus
from datetime import datetime
from sqlalchemy import func, case


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
            
            # estimated_payment: defaults to monto_total (100%)
            estimated_payment_val = debt_data.get('estimated_payment')
            if estimated_payment_val is not None:
                estimated_payment_val = float(estimated_payment_val)
            else:
                estimated_payment_val = monto_total
            
            # Create budget item object
            budget_item = BudgetItem(
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
                monto_ejecutado=monto_ejecutado,
                estimated_payment=estimated_payment_val
            )
            
            db.add(budget_item)
            db.commit()
            db.refresh(budget_item)
            
            return budget_item.id
        except Exception as e:
            db.rollback()
            print(f"Error adding debt: {e}")
            return None

    def get_all_debts(self):
        """Get all budget items from database"""
        try:
            db = self._get_db()
            budget_items = db.query(BudgetItem).order_by(BudgetItem.fecha_vencimiento.desc()).all()
            
            result = []
            for budget_item in budget_items:
                # Calculate remaining amount
                monto_restante = budget_item.monto_total - budget_item.monto_pagado
                
                # Retornar el status actual de la DB (ya actualizado por otras operaciones)
                result.append({
                    'id': budget_item.id,
                    'fecha': budget_item.fecha,
                    'tipo': budget_item.tipo,
                    'categoria': budget_item.categoria,
                    'monto_total': budget_item.monto_total,
                    'monto_pagado': budget_item.monto_pagado,
                    'monto_restante': monto_restante,
                    'detalle': budget_item.detalle,
                    'fecha_vencimiento': budget_item.fecha_vencimiento,
                    'status': budget_item.status.value if hasattr(budget_item.status, 'value') else budget_item.status,
                    # Budget Model fields
                    'tipo_presupuesto': budget_item.tipo_presupuesto.value if hasattr(budget_item.tipo_presupuesto, 'value') else budget_item.tipo_presupuesto,
                    'tipo_flujo': budget_item.tipo_flujo.value if hasattr(budget_item.tipo_flujo, 'value') else budget_item.tipo_flujo,
                    'monto_ejecutado': budget_item.monto_ejecutado,
                    'estimated_payment': budget_item.estimated_payment if budget_item.estimated_payment is not None else budget_item.monto_total,
                    'created_at': budget_item.created_at.isoformat() if budget_item.created_at else None,
                    'updated_at': budget_item.updated_at.isoformat() if budget_item.updated_at else None
                })

                # Check for linked installment plan
                plan = db.query(InstallmentPlan).filter(InstallmentPlan.debt_id == budget_item.id).first()
                if plan:
                    paid_count = db.query(InstallmentScheduleItem).filter(
                        InstallmentScheduleItem.plan_id == plan.id,
                        InstallmentScheduleItem.status == InstallmentStatus.PAID
                    ).count()
                    result[-1]['paid_installments'] = paid_count
                    result[-1]['total_installments'] = plan.number_of_installments

            return result
        except Exception as e:
            print(f"Error getting budget items: {e}")
            return []

    def get_debt_by_id(self, debt_id):
        """Get a specific budget item by ID"""
        try:
            db = self._get_db()
            budget_item = db.query(BudgetItem).filter(BudgetItem.id == debt_id).first()
            
            if not budget_item:
                return None
            
            monto_restante = budget_item.monto_total - budget_item.monto_pagado
            
            return {
                'id': budget_item.id,
                'fecha': budget_item.fecha,
                'tipo': budget_item.tipo,
                'categoria': budget_item.categoria,
                'monto_total': budget_item.monto_total,
                'monto_pagado': budget_item.monto_pagado,
                'monto_restante': monto_restante,
                'detalle': budget_item.detalle,
                'fecha_vencimiento': budget_item.fecha_vencimiento,
                'status': budget_item.status.value,
                # Nuevos campos refactor
                'tipo_presupuesto': budget_item.tipo_presupuesto.value if hasattr(budget_item.tipo_presupuesto, 'value') else budget_item.tipo_presupuesto,
                'tipo_flujo': budget_item.tipo_flujo.value if hasattr(budget_item.tipo_flujo, 'value') else budget_item.tipo_flujo,
                'monto_ejecutado': budget_item.monto_ejecutado,
                'estimated_payment': budget_item.estimated_payment if budget_item.estimated_payment is not None else budget_item.monto_total,
                'created_at': budget_item.created_at.isoformat() if budget_item.created_at else None,
                'updated_at': budget_item.updated_at.isoformat() if budget_item.updated_at else None
            }
        except Exception as e:
            print(f"Error getting debt: {e}")
            return None

    def update_debt(self, debt_id, debt_data):
        """Update an existing debt"""
        try:
            db = self._get_db()
            debt = db.query(BudgetItem).filter(BudgetItem.id == debt_id).first()
            
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
            if 'estimated_payment' in debt_data:
                debt.estimated_payment = float(debt_data['estimated_payment']) if debt_data['estimated_payment'] is not None else None
            
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
            debt = db.query(BudgetItem).filter(BudgetItem.id == debt_id).first()
            
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
            debt = db.query(BudgetItem).filter(BudgetItem.id == debt_id).first()
            
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
            debt = db.query(BudgetItem).filter(BudgetItem.id == debt_id).first()
            
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

    def get_debt_summary(self, month=None, year=None):
        """Get summary statistics of debts, optionally filtered by month/year"""
        try:
            db = self._get_db()
            
            # Base query filter for month/year
            month_filter = []
            if month and year:
                prefix = f"{year}-{month:02d}"
                month_filter = [Debt.fecha_vencimiento.like(f"{prefix}%")]
            
            # Filtro para excluir Ingresos de los montos a pagar
            gasto_filter = [Debt.tipo_flujo == FlowType.GASTO]
            
            total_debts = db.query(func.count(Debt.id)).filter(*month_filter).scalar()
            total_amount = db.query(func.sum(Debt.monto_total)).filter(*gasto_filter, *month_filter).scalar() or 0
            total_paid = db.query(func.sum(Debt.monto_pagado)).filter(*gasto_filter, *month_filter).scalar() or 0
            total_remaining = total_amount - total_paid
            
            # Total ingresos presupuestados
            total_ingresos = db.query(func.sum(Debt.monto_total)).filter(
                Debt.tipo_flujo == FlowType.INGRESO, *month_filter
            ).scalar() or 0
            
            # Conteos por estado (solo gastos)
            pending_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.PENDIENTE, *gasto_filter, *month_filter
            ).scalar()
            
            partial_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.PAGO_PARCIAL, *gasto_filter, *month_filter
            ).scalar()
            
            overdue_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.VENCIDA, *gasto_filter, *month_filter
            ).scalar()
            
            paid_count = db.query(func.count(Debt.id)).filter(
                Debt.status == DebtStatus.PAGADA, *gasto_filter, *month_filter
            ).scalar()
            
            # Montos por estado (resta de lo pendiente por pagar, solo gastos)
            pending_amount = db.query(
                func.sum(Debt.monto_total - Debt.monto_pagado)
            ).filter(
                Debt.status == DebtStatus.PENDIENTE, *gasto_filter, *month_filter
            ).scalar() or 0
            
            partial_amount = db.query(
                func.sum(Debt.monto_total - Debt.monto_pagado)
            ).filter(
                Debt.status == DebtStatus.PAGO_PARCIAL, *gasto_filter, *month_filter
            ).scalar() or 0
            
            overdue_amount = db.query(
                func.sum(Debt.monto_total - Debt.monto_pagado)
            ).filter(
                Debt.status == DebtStatus.VENCIDA, *gasto_filter, *month_filter
            ).scalar() or 0
            
            # Balance Pendiente por tipo de presupuesto (solo PENDIENTE y PAGO_PARCIAL)
            # Balance Pendiente Obligatorio = items OBLIGATION que están PENDIENTE o PAGO_PARCIAL
            obligation_pending = db.query(
                func.sum(Debt.monto_total - Debt.monto_ejecutado)
            ).filter(
                Debt.tipo_presupuesto == BudgetType.OBLIGATION,
                Debt.tipo_flujo == FlowType.GASTO,
                Debt.status.in_([DebtStatus.PENDIENTE, DebtStatus.PAGO_PARCIAL, DebtStatus.VENCIDA]),
                *month_filter
            ).scalar() or 0
            
            # Balance Pendiente Variable = items VARIABLE que están PENDIENTE o PAGO_PARCIAL
            variable_pending = db.query(
                func.sum(Debt.monto_total - Debt.monto_ejecutado)
            ).filter(
                Debt.tipo_presupuesto == BudgetType.VARIABLE,
                Debt.tipo_flujo == FlowType.GASTO,
                Debt.status.in_([DebtStatus.PENDIENTE, DebtStatus.PAGO_PARCIAL, DebtStatus.VENCIDA]),
                *month_filter
            ).scalar() or 0
            
            # Total estimated payment (monto_a_pagar) for gastos only
            # Use estimated_payment if set, otherwise monto_total
            estimated_payment_expr = case(
                (Debt.estimated_payment.isnot(None), Debt.estimated_payment),
                else_=Debt.monto_total
            )
            total_estimated_payment = db.query(func.sum(estimated_payment_expr)).filter(
                *gasto_filter, *month_filter
            ).scalar() or 0
            
            return {
                'total_debts': total_debts,
                'total_amount': float(total_amount),
                'total_paid': float(total_paid),
                'total_remaining': float(total_remaining),
                'total_ingresos': float(total_ingresos),
                'total_estimated_payment': float(total_estimated_payment),
                'pending_count': pending_count,
                'pending_amount': float(pending_amount),
                'partial_count': partial_count,
                'partial_amount': float(partial_amount),
                'overdue_count': overdue_count,
                'overdue_amount': float(overdue_amount),
                'paid_count': paid_count,
                'obligation_pending': float(obligation_pending),
                'variable_pending': float(variable_pending)
            }
        except Exception as e:
            print(f"Error getting debt summary: {e}")
            return None


# Create global instance
debt_service = DebtService()
