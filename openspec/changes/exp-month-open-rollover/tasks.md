## Backend

- [x] 1.1 Crear migración Alembic para tabla `monthly_balances` (id, source_month, target_month, balance_amount, balance_type, carryover_date, created_at)
- [x] 1.2 Agregar columnas a `budget_items`: `cloned_from_item_id` (FK nullable), `base_cloned` (decimal nullable), `version_source_month` (varchar nullable)
- [x] 1.3 Agregar columna `source_month` (varchar nullable) a tabla `transactions`
- [x] 1.4 Actualizar modelos SQLAlchemy: `MonthlyBalance`, campos de clonación en `BudgetItem`, `source_month` en `Transaction`
- [x] 1.5 Implementar `calculate_month_balance(year_month)` — suma ingresos, gastos y ajustes del mes anterior cerrado
- [x] 1.6 Implementar `create_carryover_transaction(year_month, balance_amount, balance_type)` — crea transacción con `origin = CARRYOVER`
- [x] 1.7 Implementar `clone_budget_items(source_month, target_month)` — clona ítems con trazabilidad
- [x] 1.8 Implementar `open_month(year_month)` orquestando: validar mes anterior cerrado → calcular carryover → crear transacción → clonar presupuesto → crear registro `MonthlyBalance`
- [x] 1.9 Actualizar `POST /months` para invocar `open_month()` y retornar carryover + ítems clonados
- [x] 1.10 Crear `GET /months/{year_month}/carryover` para detalle del carryover
- [x] 1.11 Agregar parámetro `include_clone_info=true` a `GET /months/{year_month}/budget-items`
- [x] 1.12 Crear `GET /budget-items/{item_id}/clone-lineage` para trazabilidad de ítems clonados
- [x] 1.13 Seed/auto-creación de categoría del sistema "Saldo Anterior" si no existe

## Frontend

- [x] 2.1 Crear componente de carryover en header del mes (muestra "Saldo Anterior: $X.XX" con link "Detalles")
- [x] 2.2 Crear transacción especial "Saldo Anterior" en lista (estilo diferenciado: gris/muted, badge, tooltip)
- [x] 2.3 Crear modal de detalle de carryover (desglose: ingresos, gastos, ajustes, balance neto)
- [x] 2.4 Agregar ícono de clonado en ítems de presupuesto del mes con tooltip (origen + base_cloned)
- [x] 2.5 Crear diálogo de apertura de mes con checkboxes para carryover y clonado de presupuesto
- [x] 2.6 Mostrar preview en diálogo de apertura: estado del mes anterior, monto de carryover, cantidad de ítems a clonar
- [x] 2.7 Implementar drill-down de linaje de ítem de presupuesto (modal con historial de meses)

## Testing

- [x] 3.1 Tests unitarios para `calculate_month_balance()`, `create_carryover_transaction()`, `clone_budget_items()`
- [x] 3.2 Tests de integración para `POST /months` con carryover y clonado
- [x] 3.3 Tests de integración para endpoints de carryover y linaje de ítems
- [ ] 3.4 Tests de UI para transacción carryover, ícono de clonado, modal de carryover
- [x] 3.5 Validar escenarios de error (tabla de 5 errores del spec)
- [ ] 3.6 Test end-to-end: Cerrar mes → Abrir nuevo → Verificar carryover creado → Inspeccionar drill-down → Editar ítem clonado → Verificar trazabilidad preservada
