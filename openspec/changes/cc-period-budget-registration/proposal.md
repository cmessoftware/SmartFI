## Why

Cuando se cierra un periodo de tarjeta de crédito, el monto total adeudado no queda registrado automáticamente como un ítem de presupuesto del mes siguiente. Esto rompe la visibilidad financiera: el usuario no puede ver el impacto de la tarjeta en el presupuesto mensual. Además, existe una regresión en los botones de visibilidad al registrar un gasto de un nuevo periodo.

## What Changes

- Al cerrar un periodo de tarjeta de crédito, registrar automáticamente el monto total como un ítem de presupuesto en el mes siguiente al cierre.
- Corregir la regresión de visibilidad de botones al registrar un gasto de un nuevo periodo.

## Capabilities

### New Capabilities

- `period-close-budget-registration`: Al cerrar un periodo, crear automáticamente un `BudgetItem` en el mes siguiente con el monto total del periodo.
- `new-period-expense-button-fix`: Corregir la visibilidad de botones al registrar un gasto de nuevo periodo.

### Modified Capabilities

<!-- No hay specs existentes que modificar -->

## Impact

- **Backend** (`backend/services/credit_card_service.py`): lógica de cierre de periodo (`close_period()` o equivalente).
- **Backend** (`backend/database/database.py`): modelo `BudgetItem` ya existe.
- **Backend** (`backend/main.py`): endpoint de cierre de periodo.
- **Frontend** (`frontend/src/`): flujo de registro de gasto de nuevo periodo y visibilidad de botones.
