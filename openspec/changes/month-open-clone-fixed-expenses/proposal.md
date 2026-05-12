## Why

Al abrir un nuevo mes, el clonado actual de budget items no distingue entre gastos fijos (alquiler, servicios, suscripciones) y gastos variables o únicos. Esto significa que al momento de la apertura el mes nuevo tiene un balance de $0, sin reflejar la carga de compromisos fijos ya conocidos. El usuario no tiene visibilidad inmediata del "piso de gasto" del mes ni puede planificar sobre una base real.

La intención es que al abrir un mes, los ítems de presupuesto fijos ya clonados generen automáticamente un **balance proyectado negativo** equivalente al total de gastos fijos, dando al usuario un punto de partida realista antes de cargar ingresos o gastos variables.

## What Changes

- Se agrega un flag `es_fijo` (booleano) a `BudgetItem` para marcar gastos fijos recurrentes.
- Al clonar presupuesto en la apertura de mes, los ítems con `es_fijo = true` se clonan y además se crea automáticamente una **transacción de gasto proyectado** (`origin = PROJECTED`) por cada uno en el nuevo mes.
- Estas transacciones proyectadas son editables/eliminables pero se distinguen visualmente (badge "Proyectado").
- El balance inicial del mes refleja: carryover del mes anterior **menos** total de gastos fijos proyectados.

## Capabilities

### New Capabilities

- `budget-item-fixed-flag`: Campo `es_fijo` en `BudgetItem`. Al marcar un ítem como fijo, se propaga en el clonado y genera transacciones proyectadas en la apertura del siguiente mes.
- `month-open-projected-expenses`: Al abrir un mes, por cada ítem clonado con `es_fijo = true`, crear una transacción `origin = PROJECTED` con el monto base como gasto estimado.
- `projected-balance-summary`: En el header del mes mostrar: Carryover + Ingresos reales - Gastos fijos proyectados = Balance proyectado.

### Modified Capabilities

- `month-budget-clone` (de `exp-month-open-rollover`): Extender para respetar `es_fijo` y disparar creación de transacciones proyectadas.
- `GET /months/{year_month}/status`: Incluir `projected_fixed_expenses` en el response.
- `POST /months`: Orquestar creación de transacciones proyectadas junto al carryover.

## Impact

- **Backend** (`backend/database/database.py`): Nuevo campo `es_fijo` en `BudgetItem`; nuevo valor `PROJECTED` en enum `origin` de `Transaction`.
- **Backend** (`backend/services/month_service.py`): Extender `clone_budget_items` para crear transacciones proyectadas por ítems fijos.
- **Backend** (`backend/main.py`): `POST /months` incluye resumen de gastos fijos proyectados en response.
- **Database**: Migración Alembic para columna `es_fijo` en `budget_items`.
- **Frontend**: Badge "Fijo" en ítems de presupuesto, toggle en UI para marcar/desmarcar, transacciones proyectadas con estilo diferenciado, balance proyectado en header del mes.
