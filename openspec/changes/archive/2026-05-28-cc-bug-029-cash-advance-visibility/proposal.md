## Why

En la carga manual de gastos de tarjeta, usuarios reportan que no identifican facilmente la opcion para marcar una compra como extraccion de efectivo (CC-BUG-029). Esto bloquea el flujo de CC-FEAT-024 porque la regla de doble impacto (gasto actual + deuda derivada) depende de que el movimiento se marque correctamente.

## What Changes

- Hacer explicita y visible la activacion de "Extraccion de efectivo" en el modal de Nueva Compra.
- Mostrar el campo de comision unicamente cuando la extraccion esta activada.
- Forzar una sola cuota para extracciones desde la UI para evitar errores de validacion.
- Mantener compatibilidad con el payload existente (`movement_type` y `cash_advance_fee`).

## Capabilities

### Modified Capabilities
- `credit-card-manual-purchase-flow`: mejora UX para visibilidad y activacion del tipo de movimiento `cash_advance`.
- `cash-advance-fee-validation`: refuerzo de validacion en frontend para comision obligatoria.

## Impact

- Frontend: `frontend/src/components/PurchaseModal.jsx`.
- UX: disminuye errores de carga manual para extracciones.
