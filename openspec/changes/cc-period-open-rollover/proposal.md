## Why

Al crear un nuevo período de tarjeta de crédito, no existe mecanismo para trasladar automáticamente el saldo pendiente de períodos anteriores cerrados. Los usuarios no pueden ver claramente qué deuda viene de períodos previos, el cálculo del pago mínimo no refleja la deuda acumulada, y se producen confusiones contables al mezclar compras nuevas con saldo arrastrado.

## What Changes

- Al crear un nuevo período, el sistema calcula automáticamente el saldo pendiente total de todos los períodos cerrados anteriores.
- Se crea una línea especial `SALDO ANTERIOR` (carryover) con `origin = CARRYOVER` en la lista de compras del nuevo período.
- El pago mínimo del período se recalcula incluyendo el saldo arrastrado.
- El usuario puede hacer drill-down en "SALDO ANTERIOR" para ver el desglose por período origen.

## Capabilities

### New Capabilities

- `period-balance-carryover`: Al crear un nuevo período de tarjeta de crédito, calcular el saldo impago de períodos anteriores cerrados y crear automáticamente una línea especial `SALDO ANTERIOR` con origen `CARRYOVER`, incluyendo trazabilidad a períodos origen y recálculo del pago mínimo.

### Modified Capabilities

- `POST /credit-cards/{card_id}/periods`: El endpoint de creación de período debe orquestar el cálculo y creación del carryover automáticamente.

## Impact

- **Backend** (`backend/database/database.py`): Nuevo modelo `CreditCardPeriodCarryover`; columnas `origin` y `source_period_id` en `CreditCardPurchase`.
- **Backend** (`backend/services/credit_card_service.py`): Métodos `calculate_carryover()`, `create_period_with_carryover()`, `create_carryover_line_item()`, `get_carryover_detail()`.
- **Backend** (`backend/main.py`): Endpoint `POST /periods` actualizado; nuevo endpoint `GET /periods/{period_id}/carryover/{carryover_id}`.
- **Database**: Nueva tabla `credit_card_period_carryovers`, columnas en `credit_card_purchases`.
- **Frontend**: Componentes `CarryoverBadge`, `CarryoverLineItem`, `CarryoverDrillDownModal`, `PeriodSummaryWidget`; actualización del cálculo de pago mínimo.
