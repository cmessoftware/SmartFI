## Why

USD credit card purchases are already converted to ARS, but they are still assigned to billing periods using `purchase_date`. That makes USD purchases appear in the current period instead of the following billed period, which breaks the intended card statement model.

## What Changes

- Add a dedicated `billing_date` to credit card purchases so billed-period assignment can differ from the original purchase date.
- Update purchase creation so ARS purchases keep the same billing date while USD purchases default to one month after the purchase date.
- Update standalone purchase queries and period totals to use `billing_date` instead of `purchase_date`.
- Backfill existing purchase rows so current data remains queryable after the schema change.

## Capabilities

### New Capabilities
- `credit-card-usd-billing-date`: Implements persisted `billing_date` behavior for USD and ARS purchases, including data migration and period-total calculations.

### Modified Capabilities

None.

## Impact

- Affects the `CreditCardPurchase` model in `backend/database/database.py`.
- Affects purchase creation and standalone period calculations in `backend/services/credit_card_service.py`.
- Requires a new Alembic migration under `backend/alembic/versions/`.
- May affect API responses that expose purchase dates if `billing_date` needs to be serialized for debugging or future UI use.