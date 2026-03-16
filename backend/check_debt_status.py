#!/usr/bin/env python
"""Check current debt statuses in database"""

from database.database import SessionLocal, Debt

db = SessionLocal()

try:
    debts = db.query(Debt).all()
    
    print(f"Total debts: {len(debts)}\n")
    print("ID | Detalle | Total | Pagado | Status (DB)")
    print("-" * 80)
    
    for debt in debts:
        print(f"{debt.id:3} | {debt.detalle[:20]:20} | ${debt.monto_total:10.2f} | ${debt.monto_pagado:10.2f} | {debt.status}")
    
finally:
    db.close()
