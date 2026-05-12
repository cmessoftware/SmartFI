## Módulos afectados

- `backend/database/database.py` — modelo `BudgetItem`, enum `TransactionOrigin`
- `backend/alembic/versions/` — nueva migración
- `backend/services/month_service.py` — `clone_budget_items`, `open_month`
- `backend/main.py` — `POST /months`, `GET /months/{year_month}/status`
- `frontend/src/components/DebtManager.jsx` — badge "Fijo", toggle
- `frontend/src/components/TransactionReport.jsx` — transacciones PROJECTED
- `frontend/src/components/OpenMonthModal.jsx` — resumen de gastos fijos proyectados

## Cambios al modelo de datos

### `BudgetItem` (tabla `budget_items`)
```
+ es_fijo: Boolean, default=False, nullable=False
```
Un ítem fijo se clona siempre y genera transacción proyectada al abrir el mes siguiente.

### `Transaction.origin` (enum)
```
Valores actuales: MANUAL | CARRYOVER | BANK_ADJUSTMENT
+ PROJECTED   ← nueva transacción generada por gasto fijo al abrir mes
```

### Flujo de apertura de mes (extendido)
```
open_month(year_month)
  ├── [existente] calculate_month_balance → create_carryover_transaction (CARRYOVER)
  ├── [existente] clone_budget_items → copia todos los budget items
  └── [nuevo]     create_projected_transactions → por cada ítem clonado con es_fijo=True
                      → Transaction(origin=PROJECTED, tipo_flujo=Gasto, amount=base_cloned)
```

## Contrato API

### `POST /api/months/{year_month}` — response extendido
```json
{
  "year_month": "2026-05",
  "status": "OPEN",
  "carryover": { "net_balance": 50000, ... },
  "cloned_items_count": 8,
  "projected_fixed_expenses": {
    "count": 3,
    "total_amount": 95000,
    "items": [
      { "budget_item_id": 12, "name": "Alquiler", "amount": 80000 },
      { "budget_item_id": 15, "name": "Internet", "amount": 5000 },
      { "budget_item_id": 18, "name": "Gimnasio", "amount": 10000 }
    ]
  }
}
```

### `GET /api/months/{year_month}/status` — campo adicional
```json
{
  ...
  "projected_fixed_expenses_total": 95000
}
```

### `PATCH /api/budget-items/{item_id}` — campo adicional en body
```json
{ "es_fijo": true }
```

## Consideraciones de seguridad

- Las transacciones PROJECTED se crean con `user_id` del usuario que abre el mes (mismo que el carryover).
- Si el usuario elimina una transacción PROJECTED manualmente, no afecta al budget item original.
- `es_fijo` es editable post-apertura pero el cambio solo aplica al próximo mes.
