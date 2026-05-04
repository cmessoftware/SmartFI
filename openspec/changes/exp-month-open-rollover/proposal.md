## Why

Al abrir un nuevo mes en el módulo de gastos, los usuarios deben recrear manualmente los ítems de presupuesto y no existe mecanismo para trasladar el saldo neto (positivo o negativo) del mes anterior. Esto genera trabajo repetitivo, pérdida de continuidad contable y falta de visibilidad del balance acumulado entre meses.

## What Changes

- Al abrir un nuevo mes, el sistema calcula el balance neto del mes anterior cerrado y crea automáticamente una transacción de tipo `CARRYOVER` ("Saldo Anterior").
- Los ítems de presupuesto del mes anterior se clonan automáticamente al nuevo mes en estado editable.
- Se mantiene trazabilidad: cada ítem clonado referencia al ítem origen y al mes de origen.
- La transacción de carryover aparece como primer ítem en la lista del nuevo mes con estilo diferenciado.

## Capabilities

### New Capabilities

- `month-balance-carryover`: Al abrir un nuevo mes, calcular el balance neto del mes anterior cerrado (ingresos - gastos + ajustes bancarios) y crear automáticamente una transacción especial `CARRYOVER` con categoría "Saldo Anterior".
- `month-budget-clone`: Al abrir un nuevo mes, clonar todos los ítems de presupuesto del mes anterior, preservando referencia al origen para trazabilidad y auditoría.

### Modified Capabilities

- `POST /months`: El endpoint existente (si aplica) debe orquestar carryover + clonado de presupuesto al crear un nuevo mes.

## Impact

- **Backend** (`backend/database/database.py`): Nuevos modelos `MonthlyBalance`; columnas adicionales en `BudgetItem` (`cloned_from_item_id`, `base_cloned`, `version_source_month`) y en `Transaction` (`source_month`).
- **Backend** (`backend/main.py`): Endpoint `POST /months` actualizado para orquestar carryover y clonado de presupuesto.
- **Database**: Nueva tabla `monthly_balances`, columnas en `budget_items` y `transactions`.
- **Frontend**: Componente carryover en header del mes, transacción especial "Saldo Anterior" en lista, ícono de clonado en ítems de presupuesto, modal de apertura con opciones de carryover y clonado.
