"""
Script para sincronizar monto_ejecutado con los valores reales de las transacciones vinculadas
"""
from database.database import get_db, Debt, Transaction as DBTransaction
from sqlalchemy import func

def sync_monto_ejecutado():
    """Recalcula monto_ejecutado sumando todas las transacciones vinculadas"""
    db = next(get_db())
    
    try:
        # Obtener todas las deudas
        debts = db.query(Debt).all()
        updated_count = 0
        
        for debt in debts:
            # Sumar todas las transacciones de tipo Gasto vinculadas a esta deuda
            total_executed = db.query(func.sum(DBTransaction.monto)).filter(
                DBTransaction.debt_id == debt.id,
                DBTransaction.tipo == 'Gasto'
            ).scalar() or 0.0
            
            # Actualizar si hay diferencia
            if debt.monto_ejecutado != total_executed:
                print(f"Deuda {debt.id}: monto_ejecutado antes={debt.monto_ejecutado}, después={total_executed}")
                debt.monto_ejecutado = total_executed
                
                # Recalcular estado
                if debt.monto_ejecutado >= debt.monto_total:
                    debt.status = 'PAGADA'
                elif debt.monto_ejecutado > 0:
                    debt.status = 'Pago parcial'
                else:
                    debt.status = 'PENDIENTE'
                
                print(f"  Estado actualizado a: {debt.status}")
                updated_count += 1
        
        db.commit()
        print(f"\n✅ Sincronización completada. {updated_count} deudas actualizadas.")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error en sincronización: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("Iniciando sincronización de monto_ejecutado...")
    sync_monto_ejecutado()
