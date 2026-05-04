## Context

Los períodos de tarjeta de crédito son a menudo de 25–50 días y no se alinean con meses calendario. Cuando un período cierra, los usuarios pueden no haber pagado el balance completo, resultando en deuda que debe trasladarse al siguiente período. El carryover necesita:
- Preservar la identidad del período original (para que el usuario vea "deuda del período de abril")
- Soportar múltiples niveles de carryover (deuda de abril → mayo → junio)
- Calcular el pago mínimo correctamente (nuevas compras + todo el carryover)
- Permitir drill-down para inspeccionar la composición del carryover

## Goals / Non-Goals

**Goals:**
- Calcular automáticamente saldo impago de períodos anteriores al crear nuevo período
- Crear línea `SALDO ANTERIOR` visible en lista de compras con estilo diferenciado
- Recalcular pago mínimo incluyendo carryover
- Proveer drill-down con desglose detallado del carryover (origen, compras no pagadas, intereses)
- Mantener trazabilidad de carryover (tabla `credit_card_period_carryovers`)

**Non-Goals:**
- Carryover automático de presupuesto (no aplica a tarjetas de crédito)
- Carryover entre diferentes tarjetas de crédito
- Cierre automático de períodos por `closing_date` (siempre manual)

## Decisions

**D1 — Compra pseudo-transacción `SALDO ANTERIOR` (no campo separado en período):**
Modelar el carryover como una compra con `origin = CARRYOVER` lo hace visible en la lista de compras con comportamiento estándar (filtrable, excluible de reportes). Alternativa descartada: campo `carryover_amount` en `CreditCardPeriodConfig`, que no sería visible directamente en la lista.

**D2 — Tabla dedicada `credit_card_period_carryovers`:**
Permite trazabilidad independiente, reportes de aging, y drill-down sin depender de la pseudo-transacción. La pseudo-transacción puede eliminarse (si el período se reabre), pero la tabla de trazabilidad persiste.

**D3 — Calcular carryover de TODOS los períodos anteriores cerrados:**
En lugar de solo el período inmediatamente anterior, calcular la suma de todos los períodos con saldo impago. Esto cubre el caso de múltiples períodos con deuda acumulada.

**D4 — Pago mínimo recalculado en el backend:**
El backend incluye el `carryover_amount` en el cálculo del pago mínimo. El frontend solo muestra el resultado con un callout indicando "incluye saldo anterior".

**D5 — Carryover solo si hay saldo positivo impago:**
Si `unpaid_balance <= 0`, no se crea carryover ni pseudo-transacción. El nuevo período comienza limpio.

## Risks / Trade-offs

- **Riesgo:** Si un período origen es reabierto después de que su carryover ya fue trasladado, el monto del carryover puede ser incorrecto. Mitigación: recalcular el carryover al reabrir un período con carryover transferido (o marcar el carryover como "pendiente de recálculo").
- **Trade-off:** Agregar `origin` y `source_period_id` a `credit_card_purchases` incrementa la tabla, pero son columnas nullable y solo se populan para líneas de carryover.
- **Riesgo:** La lógica de cálculo de pago mínimo puede ser compleja con múltiples períodos fuente. Mitigación: implementar con fórmula clara y documentada, con tests unitarios exhaustivos.

## Migration Plan

1. Crear migración Alembic: tabla `credit_card_period_carryovers`, columnas `origin` y `source_period_id` en `credit_card_purchases`.
2. Backfill: todos los registros existentes en `credit_card_purchases` toman `origin = 'PURCHASE'` por default.
3. Deploy backend con nuevos endpoints y lógica de carryover.
4. Deploy frontend con componentes de carryover y widget de resumen de período.
