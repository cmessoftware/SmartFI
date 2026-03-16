#!/usr/bin/env python
"""Test get_all_debts function"""

from services.debt_service import DebtService

service = DebtService()
debts = service.get_all_debts()

print(f"Total debts: {len(debts)}")
for debt in debts:
    print(f"\nID: {debt['id']}")
    print(f"Detalle: {debt['detalle']}")
    print(f"Status: {debt['status']}")
    print(f"Status type: {type(debt['status'])}")
