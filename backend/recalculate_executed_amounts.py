"""
Script para recalcular monto_ejecutado de todos los items de presupuesto
basándose en las transacciones vinculadas existentes.
"""
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from database.database import Debt, Transaction
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configuración de base de datos
DATABASE_URL = os.getenv(
    'DATABASE_URL',
    'postgresql://admin:admin123@localhost:5433/fin_per_db'
)

def recalculate_executed_amounts():
    """Recalcular monto_ejecutado para todos los items de presupuesto"""
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()
    
    try:
        # Obtener todos los items de presupuesto
        debts = db.query(Debt).all()
        print(f"\n📊 Procesando {len(debts)} items de presupuesto...")
        
        updated_count = 0
        for debt in debts:
            # Calcular el total de transacciones vinculadas a este debt
            total_executed = db.query(text("COALESCE(SUM(monto), 0)")).select_from(Transaction).filter(
                Transaction.debt_id == debt.id
            ).scalar()
            
            old_value = debt.monto_ejecutado or 0
            debt.monto_ejecutado = float(total_executed)
            
            if old_value != debt.monto_ejecutado:
                print(f"  ✓ Item {debt.id} ({debt.detalle or debt.tipo}): ${old_value:,.2f} → ${debt.monto_ejecutado:,.2f}")
                updated_count += 1
        
        # Guardar cambios
        db.commit()
        print(f"\n✅ Actualización completada: {updated_count} items modificados")
        
        # Mostrar resumen
        print("\n📈 Resumen por tipo de flujo:")
        gastos = [d for d in debts if d.tipo_flujo == 'Gasto']
        ingresos = [d for d in debts if d.tipo_flujo == 'Ingreso']
        
        if gastos:
            total_gasto_presupuestado = sum(d.monto_total for d in gastos)
            total_gasto_ejecutado = sum(d.monto_ejecutado or 0 for d in gastos)
            print(f"  💸 Gastos: ${total_gasto_ejecutado:,.2f} / ${total_gasto_presupuestado:,.2f}")
        
        if ingresos:
            total_ingreso_presupuestado = sum(d.monto_total for d in ingresos)
            total_ingreso_ejecutado = sum(d.monto_ejecutado or 0 for d in ingresos)
            print(f"  💰 Ingresos: ${total_ingreso_ejecutado:,.2f} / ${total_ingreso_presupuestado:,.2f}")
        
        return True
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    print("="*60)
    print("🔄 RECALCULAR MONTOS EJECUTADOS DE PRESUPUESTOS")
    print("="*60)
    
    # Aceptar --yes o -y para ejecutar sin confirmación
    auto_confirm = '--yes' in sys.argv or '-y' in sys.argv
    
    if auto_confirm:
        print("\n✓ Ejecución automática confirmada")
        success = recalculate_executed_amounts()
        sys.exit(0 if success else 1)
    else:
        confirm = input("\n¿Desea recalcular los montos ejecutados? (s/n): ")
        if confirm.lower() == 's':
            success = recalculate_executed_amounts()
            sys.exit(0 if success else 1)
        else:
            print("❌ Operación cancelada")
            sys.exit(0)
