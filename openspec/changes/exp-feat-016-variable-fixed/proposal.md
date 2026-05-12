# Proposal: Atributo Variable/Fijo en ítems de gastos e ingresos

## Why

Actualmente los ítems de presupuesto (`BudgetItem`) no distinguen si un gasto es fijo (alquiler, servicios) o variable (supermercado, salidas). Esta distinción es necesaria para:

1. Permitir que la apertura del nuevo mes clone automáticamente los ítems fijos (EXP-FEAT-17).
2. Dar visibilidad en la UI sobre qué gastos son recurrentes y cuáles son ocasionales.
3. Permitir análisis futuros de presupuesto por tipo de gasto.

## What Changes

- Agregar columna `expense_type` (enum: `FIJO` / `VARIABLE`) a la tabla `budget_items`.
- Permitir que el usuario marque cada ítem como Fijo o Variable al crearlo o editarlo (formulario manual y carga CSV).
- Mostrar el tipo en la lista de ítems de presupuesto.

## Capabilities

### Nueva: `budget-item-type`
- Campo `expense_type: FIJO | VARIABLE` en el modelo `BudgetItem`.
- Default: `VARIABLE` (para no romper ítems existentes).
- Editable desde el formulario de presupuesto.
- Incluido en la respuesta de la API de budget items.
- Soportado en carga masiva CSV (columna opcional `tipo_gasto`).

## Impact

- **Base de datos**: nueva columna en `budget_items` con default `VARIABLE`.
- **Backend**: modelo SQLAlchemy, endpoints GET/POST/PUT de budget items.
- **Frontend**: formulario de alta/edición de ítems, listado con badge Visual/Fijo.
- **CSV import**: columna opcional (si no está presente, default VARIABLE).
- **Dependencias**: EXP-FEAT-17 depende de este atributo.
