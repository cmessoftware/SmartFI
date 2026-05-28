## Context

La implementacion anterior de extracciones uso `cash_advance_fee` como importe fijo. El requerimiento corregido establece que el campo representa porcentaje, y que el gasto visible en modulo Gastos debe incluir la comision calculada.

## Decision

1. Mantener el contrato de payload (`movement_type`, `cash_advance_fee`) para compatibilidad, pero reinterpretar `cash_advance_fee` como porcentaje.
2. En backend:
   - Validar `cash_advance_fee > 0` y `<= 100` para extracciones.
   - Calcular `fee_amount` en ARS segun moneda/monto de la compra.
   - Generar/actualizar transaccion espejo con `amount = monto_extraccion + fee_amount`.
   - Generar/actualizar deuda derivada con `monto_total = fee_amount`.
3. En frontend:
   - Etiquetar campo como porcentaje.
   - Validar rango de porcentaje.
   - Mostrar vista previa de comision calculada y gasto total.

## Consequences

- El usuario carga la comision en terminos de negocio correctos (porcentaje).
- El modulo Gastos refleja el impacto total real de la extraccion.
- Se evita drift entre UI y backend al centralizar calculo monetario en backend.
- No requiere migracion de esquema adicional.
