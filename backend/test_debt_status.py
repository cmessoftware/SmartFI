#!/usr/bin/env python
"""Quick test to check debt status values"""

from database.database import DebtStatus

print("Testing DebtStatus enum:")
print(f"PENDIENTE value: '{DebtStatus.PENDIENTE.value}'")
print(f"PAGO_PARCIAL value: '{DebtStatus.PAGO_PARCIAL.value}'")
print(f"PAGADA value: '{DebtStatus.PAGADA.value}'")
print(f"VENCIDA value: '{DebtStatus.VENCIDA.value}'")

# Test conversion
status = DebtStatus.PAGO_PARCIAL
print(f"\nUsing .value: '{status.value}'")
print(f"Direct string: '{status}'")
