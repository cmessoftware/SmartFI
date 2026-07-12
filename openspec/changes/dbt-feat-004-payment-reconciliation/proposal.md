## Why

DBT-FEAT-004 requiere que los pagos parciales/totales impacten de forma consistente el saldo canonico de `debt-records` y el avance de cuotas, evitando desalineaciones con la vista de Deudas.
Actualmente existen endpoints de pagos, pero falta reconciliacion funcional completa de cuotas pendientes y un flujo frontend dedicado para registrar pagos desde el modulo de deudas.

## What Changes

- Implementar reconciliacion de pagos en backend para actualizar `outstanding_amount`, `current_installment` y `pending_installments` en cada pago.
- Exponer en frontend un flujo explicito para registrar pagos de deuda no tarjeta y refrescar estado sin recarga manual.
- Agregar validaciones y pruebas para pagos parciales/totales, incluyendo casos fraccionarios.

## Capabilities

### New Capabilities

- debt-payment-reconciliation: registrar pagos en deudas no tarjeta con recalculo inmediato de saldo y avance de cuotas.
- debt-payment-ui-flow: registrar pagos desde la tabla de Deudas con feedback y refresco de estado.

### Modified Capabilities

- debt-record-projection-sync: las proyecciones mensuales se sincronizan con los nuevos valores reconciliados tras cada pago.

## Impact

- Módulos backend afectados: `backend/services/debt_record_service.py`, `backend/main.py`, `backend/tests/test_debt_record_projection_service.py`.
- Módulos frontend afectados: `frontend/src/services/api.js`, `frontend/src/components/DebtManager.jsx`.
- Datos/DB afectados: no requiere cambios de esquema (sin migración Alembic para este FEAT).
- Riesgo principal: desalineacion entre monto pagado, cuotas calculadas y proyeccion mensual si no se aplica una regla unica de reconciliacion.