## Context

Los periodos de tarjeta de crédito tienen fechas de cierre y vencimiento configuradas en `CreditCardPeriodConfig`. Actualmente el sistema no valida que los pagos ni las importaciones CSV respeten esas fechas. Tampoco valida la ventana de carga válida (entre el cierre del periodo anterior y el vencimiento del actual).

El modelo `CreditCardPeriodConfig` contiene campos `billing_date` (cierre) y `due_date` (vencimiento). La ventana de carga válida es: desde el `billing_date` del periodo anterior hasta el `due_date` del periodo actual.

## Goals / Non-Goals

**Goals:**
- Validar que los pagos se registren en el periodo correcto, con sugerencia al usuario.
- Imputar ítems CSV al periodo cuyo cierre coincide con la fecha de cierre del ítem.
- Bloquear cargas fuera de ventana con override por rol.
- Rechazar lotes CSV con cualquier ítem fuera de política.

**Non-Goals:**
- No modificar periodos ya cerrados ni pagos históricos.
- No cambiar el modelo de datos de compras o cuotas.

## Decisions

### D1: Validación de pagos como advertencia, no bloqueo

Los pagos fuera de periodo mostrarán una advertencia con sugerencia del periodo correcto, pero no bloquearán el guardado. El usuario puede confirmar o corregir.

**Alternativa descartada:** Bloquear pagos fuera de periodo. Puede generar fricciones innecesarias en casos borde (e.g., pago anticipado).

### D2: CSV: coincidencia exacta de fecha de cierre

Para imputar un ítem CSV al periodo correcto, se comparará la fecha de cierre del ítem (`billing_date` en el CSV) con el campo `billing_date` de cada `CreditCardPeriodConfig`. Si no hay coincidencia exacta, el ítem se marcará como error.

### D3: Override de ventana por rol

El bloqueo de carga fuera de ventana solo aplicará a usuarios con rol `user`. Usuarios con rol `admin` o `manager` podrán hacer override con confirmación explícita.

### D4: Rechazo all-or-nothing para CSV

Si cualquier ítem del CSV viola la política (fuera de ventana o sin periodo coincidente), el lote completo se rechaza. No se importan ítems parciales.

## Risks / Trade-offs

- [Risk: Reglas de ventana demasiado estrictas para casos borde] → Mitigación: el override por rol permite flexibilidad para admin.
- [Risk: CSV con fechas de cierre que no coinciden exactamente con ningún periodo] → Mitigación: el reporte de errores detalla qué ítems fallaron y por qué.

## Migration Plan

- Si se agregan columnas a `CreditCardPeriodConfig`: crear migración Alembic.
- Deploy: rebuild backend, sin downtime. La validación es aditiva (no breaking para clientes existentes).
