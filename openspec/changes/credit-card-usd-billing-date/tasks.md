## 1. Data model and migration

- [x] 1.1 Add `billing_date` to `CreditCardPurchase` in the SQLAlchemy model.
- [x] 1.2 Create an Alembic migration that adds `billing_date` and backfills historical ARS/USD purchases.

## 2. Runtime billing-date behavior

- [x] 2.1 Update credit card purchase creation to persist `billing_date` from currency and purchase date.
- [x] 2.2 Update standalone purchase period queries to use `billing_date` with safe fallback to `purchase_date`.

## 3. Validation

- [x] 3.1 Run a focused backend validation for syntax/errors after the model and service changes.
- [x] 3.2 Validate one known credit card period calculation to confirm USD standalone purchases bill in the following period.