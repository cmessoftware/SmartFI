# Proposal: Mejorar apertura de mes — Clonar solo ítems fijos como Pendientes

## Why

La apertura de un mes actualmente clona **todos** los ítems de presupuesto del mes anterior. Esto incluye gastos variables y únicos que no deberían repetirse. El usuario quiere que:

1. Solo se clonen automáticamente los ítems marcados como **Fijo** (requiere EXP-FEAT-16).
2. Los ítems clonados queden en estado **Pendiente** para que el usuario los confirme/ajuste.
3. El modal de apertura de mes incluya un checkbox opcional para activar este comportamiento.

Esta feature es una mejora del flujo de `open_month` implementado en `exp-month-open-rollover`, corrigiendo el concepto original de carryover (que era incorrecto).

## What Changes

- En `open_month()`, filtrar el clon de ítems para incluir solo los que tienen `expense_type = FIJO`.
- Los ítems clonados se crean con `status = PENDIENTE`.
- El modal `OpenMonthModal` muestra un checkbox "Solo clonar gastos fijos" que activa este filtro.
- Si no hay mes anterior con ítems FIJO, se informa en el preview.

## Capabilities

### Modificada: `month-budget-clone` (de exp-month-open-rollover)
- Nuevo parámetro `only_fixed: bool = True` (default True cuando `include_fixed_clone=True`).
- `clone_budget_items()` acepta filtro `only_fixed`.
- Preview en modal muestra cantidad de ítems FIJO del mes anterior.

## Impact

- **Depende de**: EXP-FEAT-016 (atributo FIJO/VARIABLE debe existir).
- **Backend**: `clone_budget_items()` y `open_month()` en `month_service.py`.
- **Frontend**: `OpenMonthModal.jsx` — lógica de preview y checkbox.
- **No requiere migración**: usa columna `expense_type` de FEAT-016.
