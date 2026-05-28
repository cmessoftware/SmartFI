## Why

El flujo de extraccion de efectivo en tarjeta (CC-FEAT-024) estaba tomando `cash_advance_fee` como valor absoluto. Esto genero dos problemas reportados en CC-BUG-030:

1. La comision no estaba modelada como porcentaje sobre el monto de extraccion.
2. El gasto reflejado en el modulo Gastos no incluia la comision calculada.

## What Changes

- Definir `cash_advance_fee` como porcentaje en frontend y backend.
- Calcular la comision monetaria en ARS como `monto_extraccion * porcentaje / 100`.
- Registrar el gasto espejo de extraccion con monto total `extraccion + comision`.
- Mantener la deuda derivada del proximo periodo con el monto de comision calculado.
- Actualizar mensajes y etiquetas de UI para evitar ambiguedad (valor absoluto vs porcentaje).

## Capabilities

### Modified Capabilities
- `cash-advance-fee-calculation`: comision en porcentaje con calculo monetario consistente.
- `cash-advance-expense-mirroring`: gasto en modulo Gastos refleja el impacto total de la extraccion.

## Impact

- Backend: `backend/services/credit_card_service.py`, `backend/main.py`.
- Frontend: `frontend/src/components/PurchaseModal.jsx`.
- Documentacion funcional: `docs/SmartFI-V1/SmartFI_CREDIT_CARD_MODULE.md`.
