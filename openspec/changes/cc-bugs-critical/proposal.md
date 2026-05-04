## Why

Dos bugs de alta prioridad afectan la correctitud y usabilidad del módulo de tarjetas de crédito: al editar la fecha de una compra esta no se mueve de periodo (los montos quedan imputados en el periodo incorrecto), y al cambiar la moneda de ARS a USD el header de Total Pendiente no se actualiza sin recargar la página.

## What Changes

- Al guardar una edición de fecha de compra, el backend debe re-evaluar a qué periodo corresponde la compra (basado en el nuevo `billing_date` calculado) y moverla si es necesario, previa confirmación del usuario en el frontend.
- Al guardar la edición de moneda de una compra (ARS→USD o USD→ARS), el frontend debe refrescar el resumen de la tarjeta (`card summary`) para que el header de Total Pendiente refleje el cambio inmediatamente.

## Capabilities

### New Capabilities

- `purchase-period-reassignment`: Al editar la fecha de una compra, evaluar si el nuevo `billing_date` cae en un periodo diferente al actual; si es así, mover la compra con confirmación del usuario.
- `purchase-currency-header-refresh`: Al editar la moneda de una compra y guardar exitosamente, disparar un refresco del resumen de la tarjeta en el header.

### Modified Capabilities

<!-- No hay specs existentes que modificar -->

## Impact

- **Backend** (`backend/services/credit_card_service.py`): `update_purchase()` debe detectar cambio de periodo y reasignar.
- **Backend** (`backend/main.py`): endpoint `PUT /api/credit-cards/{card_id}/purchases/{purchase_id}` debe retornar indicador de si hubo cambio de periodo.
- **Frontend** (`frontend/src/`): componente de edición de compra debe mostrar confirmación si hay cambio de periodo, y refrescar el resumen al guardar cambio de moneda.
- **No hay cambios de schema de BD** (el campo `billing_date` ya existe).
