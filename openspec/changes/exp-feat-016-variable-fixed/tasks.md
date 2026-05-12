# Tasks: EXP-FEAT-016 — Atributo Variable/Fijo en ítems de presupuesto

## Backend

- [ ] 1.1 Crear migración Alembic: agregar columna `expense_type` (enum FIJO/VARIABLE, default VARIABLE) a `budget_items` [#93]
- [ ] 1.2 Agregar enum `ExpenseType` (FIJO/VARIABLE) al modelo SQLAlchemy `BudgetItem` [#94]
- [ ] 1.3 Actualizar endpoints de budget items (GET/POST/PUT) para exponer y aceptar `expense_type` [#95]
- [ ] 1.4 Soportar columna opcional `tipo_gasto` en importación CSV de budget items (default VARIABLE) [#96]

## Frontend

- [ ] 2.1 Agregar campo `expense_type` (selector FIJO/VARIABLE) al formulario de alta/edición de ítems de presupuesto [#97]
- [ ] 2.2 Mostrar badge "Fijo" / "Variable" en la lista de ítems de presupuesto [#98]

## Testing

- [ ] 3.1 Tests unitarios: creación de ítem FIJO y VARIABLE, default VARIABLE [#99]
- [ ] 3.2 Tests de integración: filtrar ítems por `expense_type=FIJO` [#100]
- [ ] 3.3 Validar import CSV con y sin columna `tipo_gasto` [#101]
