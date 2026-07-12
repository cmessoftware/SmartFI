## Context

El modulo DBT ya dispone de CRUD de deuda y endpoints de pagos, pero la logica actual de pago reduce solo `outstanding_amount` y no reconcilia de forma robusta el avance de cuotas en escenarios parciales.
En frontend, la vista de Deudas consume `debt-records/projected`, pero no tiene una accion directa para registrar pagos desde la misma pantalla.

## Goals / Non-Goals

### Goals

- Definir una regla unica de reconciliacion de pagos para actualizar saldo y cuotas en `debt-records`.
- Incorporar flujo frontend para registrar pagos parciales/totales desde la vista de Deudas.
- Mantener sincronizacion de proyecciones mensuales despues de cada pago.

### Non-Goals

- Implementar la regla final de redondeo funcional de 2 decimales como alcance integral de DBT-FEAT-005.
- Cambiar el modelo de datos o mezclar deuda de tarjeta (CC) dentro de DBT.

## Affected Modules

- Backend:
  - `backend/services/debt_record_service.py`
  - `backend/main.py`
  - `backend/tests/test_debt_record_projection_service.py`
- Frontend:
  - `frontend/src/services/api.js`
  - `frontend/src/components/DebtManager.jsx`

## Data Model Changes

- ¿Hay cambios de modelo? no.
- Si sí: N/A.
- Migración: no aplica en este FEAT.

## API Contract

- Endpoint(s) nuevos/modificados:
  - `POST /api/debt-records/{record_id}/payments` (mismo endpoint, con validaciones y reconciliacion de cuotas).
  - `GET /api/debt-records/{record_id}/payments` (usado por flujo frontend para historial basico).
- Request:
  - `payment_date`, `amount`, `notes`, opcional `transaction_id`.
- Response:
  - pago creado + estado de deuda refrescado via `GET /api/debt-records/projected`.
- Compatibilidad hacia atrás:
  - se mantiene contrato existente; solo se mejora semantica de reconciliacion.

## Security Considerations

- Autenticación/autorización afectada: se mantienen permisos `debt_records.write` y `debt_records.read`.
- Validaciones de entrada: monto > 0, deuda activa, pago no superior al saldo pendiente (salvo tolerancia minima flotante).
- Riesgos de datos sensibles: no se agregan nuevos datos sensibles.

## Decisions

### Decision 1

- Decisión: calcular cuotas pagadas del pago como `amount / installment_amount` y actualizar `current_installment`/`pending_installments` en forma incremental.
- Rationale: permite soportar pagos parciales y fraccionarios en un unico modelo.
- Alternatives considered: recalcular cuotas solo por diferencia de saldo sin referencia de cuota (menos interpretable para UI).

### Decision 2

- Decisión: mantener frontend simple con modal de pago en `DebtManager` y refresco post-operacion via `loadDebts()`.
- Rationale: minimiza cambios y reduce riesgo de regresion.
- Alternatives considered: nueva pantalla de pagos dedicada (mayor costo y fuera de alcance inmediato).

## Risks / Trade-offs

- [Risk] Diferencias por precision flotante en cuotas pagadas -> Mitigation: normalizar con helper numerico y clamps.
- [Risk] Sobrepago accidental por UI -> Mitigation: validar en backend y frontend contra saldo pendiente.

## Migration Plan

1. Implementar reconciliacion backend y tests.
2. Agregar cliente API frontend para pagos y modal de registro.
3. Validar flujo end-to-end local y actualizar tasks.

## Open Questions

- ¿Se permite sobrepago para cancelar y dejar credito a favor, o se bloquea estrictamente?
- ¿Se requiere exponer historial completo de pagos en la tabla principal en esta iteracion?