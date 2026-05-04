## Context

Los meses calendario son fijos (28–31 días) y secuenciales. Al cerrar un mes y abrir el siguiente:
- Se necesita preservar el balance de cierre como saldo de apertura del nuevo mes.
- Se necesita preservar la estructura de presupuesto para consistencia.
- Se debe permitir ajustes a los ítems clonados sin perder la referencia histórica.
- Se requiere soporte para análisis de tendencias multi-mes (mes actual + carryover del anterior).

## Goals / Non-Goals

**Goals:**
- Calcular automáticamente el balance neto al abrir un nuevo mes.
- Crear transacción especial `CARRYOVER` con categoría "Saldo Anterior".
- Clonar ítems de presupuesto del mes anterior en estado editable.
- Preservar trazabilidad de clonación (`cloned_from_item_id`, `version_source_month`).
- Mostrar carryover diferenciado en UI (transacción especial, ícono en presupuesto).

**Non-Goals:**
- Apertura automática de meses (siempre acción manual del admin).
- Múltiples niveles de carryover encadenado (solo 1 nivel de referencia).
- Migración retroactiva de datos históricos de presupuesto.

## Decisions

**D1 — Transacción CARRYOVER en lugar de campo separado:**
Modelar el carryover como una transacción con `origin = CARRYOVER` lo hace visible en la lista de transacciones con comportamiento estándar (puede filtrarse, excluirse de reportes con `origin != CARRYOVER`). Alternativa descartada: campo separado `opening_balance` en `MonthlyPeriod` que no sería visible directamente.

**D2 — Categoría especial "Saldo Anterior":**
Se requiere una categoría fija del sistema (no editable por usuario) para las transacciones de carryover. Esto permite filtrado por categoría y visualización diferenciada sin lógica especial en el frontend.

**D3 — Clonación editable (no bloqueo de ítems clonados):**
Los ítems clonados en el nuevo mes son completamente editables. El campo `base_cloned` preserva el valor original para comparación y auditoría, pero no bloquea cambios. Esto maximiza flexibilidad operativa.

**D4 — Validar que el mes anterior esté cerrado antes de abrir:**
Para garantizar integridad del carryover, el mes anterior debe estar en estado `CLOSED` antes de calcular el balance. Si no está cerrado, el sistema debe retornar error `PRIOR_MONTH_NOT_CLOSED`.

**D5 — Tabla separada `monthly_balances` para trazabilidad:**
Registrar cada carryover en tabla dedicada permite auditoría, reporte y drill-down independientemente de la transacción creada.

## Risks / Trade-offs

- **Riesgo:** Si el mes anterior tiene transacciones incorrectas, el carryover propagará el error. Mitigación: mostrar resumen del carryover en el diálogo de apertura para revisión antes de confirmar.
- **Trade-off:** Agregar columnas de clonación a `budget_items` incrementa el tamaño de la tabla. Aceptable dado que estas columnas son nullable y solo se populan en clonaciones.
- **Riesgo:** La categoría "Saldo Anterior" debe existir antes del primer uso. Mitigación: seed data o auto-creación al primer deploy.

## Migration Plan

1. Crear migración Alembic: tabla `monthly_balances`, columnas en `budget_items` y `transactions`.
2. Seed: Crear categoría del sistema "Saldo Anterior" si no existe.
3. Deploy backend con `open_month()` orquestando carryover + clonado.
4. Deploy frontend con UI de apertura, transacción carryover y ícono de clonado.
5. Admin puede comenzar a usar el flujo de apertura desde UI.
