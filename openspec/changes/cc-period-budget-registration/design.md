## Context

El módulo de tarjetas maneja periodos de facturación con cierre y vencimiento. Al cerrar un periodo, el sistema calcula el monto total adeudado pero no lo vincula al módulo de presupuesto. El modelo `BudgetItem` ya existe en `database.py` y tiene campos `amount`, `month`, `year`, `category`, `description`. El módulo de presupuesto es independiente pero comparte la misma BD.

## Goals / Non-Goals

**Goals:**
- Al cerrar un periodo, crear un `BudgetItem` en el mes siguiente al cierre con el monto total del periodo.
- Corregir visibilidad de botones al registrar gasto de nuevo periodo.

**Non-Goals:**
- No modificar el módulo de presupuesto ni su UI.
- No crear `BudgetItem` retroactivamente para periodos ya cerrados (solo futuros cierres).

## Decisions

### D1: Creación del BudgetItem en el mismo transaction que el cierre de periodo

El `BudgetItem` se crea dentro de la misma transacción que el cierre de periodo para garantizar consistencia (si falla uno, falla todo).

### D2: Categoría fija para el BudgetItem de tarjeta

El `BudgetItem` generado tendrá categoría `"Tarjeta de Crédito"` y descripción `"Cierre periodo {nombre_periodo} — {nombre_tarjeta}"`. No se pide al usuario que elija categoría.

### D3: Idempotencia del cierre

Si se intenta cerrar un periodo ya cerrado, el sistema debe verificar si ya existe un `BudgetItem` vinculado para no crear duplicados.

## Risks / Trade-offs

- [Risk: El monto del BudgetItem queda desactualizado si se editan compras después del cierre] → Mitigación: los periodos cerrados no deberían tener ediciones de compras (esto se refuerza con `period-window-enforcement`).
- [Risk: Mes siguiente puede no estar configurado en el presupuesto] → Mitigación: el `BudgetItem` se crea igualmente; el módulo de presupuesto lo mostrará cuando ese mes esté activo.

## Migration Plan

- No requiere migración de schema (usa `BudgetItem` existente).
- Deploy: rebuild backend. Sin downtime.
