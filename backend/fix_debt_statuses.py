#!/usr/bin/env python
"""Fix existing debt statuses in database"""

from database.database import SessionLocal, Debt, DebtStatus
from datetime import datetime

db = SessionLocal()

try:
    debts = db.query(Debt).all()
    updated = 0
    
    print("Updating debt statuses...\n")
    
    for debt in debts:
        old_status = str(debt.status)
        
        # Calcular el estado correcto
        if debt.monto_pagado >= debt.monto_total:
            new_status = DebtStatus.PAGADA
        elif debt.fecha_vencimiento < datetime.now().strftime('%Y-%m-%d'):
            new_status = DebtStatus.VENCIDA
        elif debt.monto_pagado > 0:
            new_status = DebtStatus.PAGO_PARCIAL
        else:
            new_status = DebtStatus.PENDIENTE
        
        if old_status != new_status.value:
            debt.status = new_status
            debt.updated_at = datetime.utcnow()
            print(f"ID {debt.id:3} | {debt.detalle[:25]:25} | ${debt.monto_pagado:8.2f}/${debt.monto_total:8.2f} | {old_status:20} → {new_status.value}")
            updated += 1
    
    if updated > 0:
        db.commit()
        print(f"\n✅ Updated {updated} debt(s)")
    else:
        print("✅ All debts have correct status")
    
finally:
    db.close()
