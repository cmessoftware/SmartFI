## Backend

- [ ] 1.1 Migración Alembic: agregar columna `es_fijo` (Boolean, default=False) a `budget_items`
- [ ] 1.2 Actualizar modelo SQLAlchemy `BudgetItem` con campo `es_fijo`
- [ ] 1.3 Agregar valor `PROJECTED` al enum `origin` en modelo `Transaction`
- [ ] 1.4 Extender `clone_budget_items` en `month_service.py`: por cada ítem clonado con `es_fijo=True`, crear `Transaction(origin=PROJECTED)` con `amount=base_cloned`
- [ ] 1.5 Extender `open_month` para retornar `projected_fixed_expenses` (count, total, items) en el response
- [ ] 1.6 Extender `GET /months/{year_month}/status` para incluir `projected_fixed_expenses_total`
- [ ] 1.7 Extender `PATCH /api/budget-items/{item_id}` para aceptar y persistir `es_fijo`
- [ ] 1.8 Asegurar que `get_all_debts` y `get_debt_by_id` retornan `es_fijo` en el response

## Frontend

- [ ] 2.1 Agregar toggle "Gasto fijo" en formulario de creación/edición de budget item (`DebtManager`)
- [ ] 2.2 Mostrar badge "Fijo" en ítems marcados como `es_fijo=true` en la lista de presupuesto
- [ ] 2.3 Mostrar transacciones `PROJECTED` con estilo diferenciado (badge azul/gris, tooltip "Generado por gasto fijo")
- [ ] 2.4 Extender `OpenMonthModal` para mostrar resumen de gastos fijos proyectados antes de confirmar apertura
- [ ] 2.5 Mostrar en header del mes: balance proyectado = carryover - total gastos fijos proyectados
- [ ] 2.6 Extender `api.js`: `debtsAPI.update` debe incluir `es_fijo` en el body

## Testing

- [ ] 3.1 Tests unitarios para `clone_budget_items` con ítems fijos: verifica creación de transacciones PROJECTED
- [ ] 3.2 Tests unitarios: ítems sin `es_fijo` no generan transacciones PROJECTED
- [ ] 3.3 Tests de integración: `POST /months` retorna `projected_fixed_expenses` con datos correctos
- [ ] 3.4 Tests de integración: `PATCH /budget-items/{id}` persiste `es_fijo`
- [ ] 3.5 Test: eliminar transacción PROJECTED manualmente no afecta el budget item ni reabre el mes
