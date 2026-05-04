## ADDED Requirements

### Requirement: Credit card purchases SHALL persist a billed-period date
The system SHALL store a `billing_date` for each credit card purchase so billed-period calculations can differ from the original purchase date.

#### Scenario: New purchase stores a billing date
- **WHEN** the system creates a credit card purchase
- **THEN** the purchase row includes a persisted `billing_date`

### Requirement: Billing date SHALL be derived from currency at creation time
The system SHALL set `billing_date = purchase_date` for ARS purchases and `billing_date = purchase_date + 1 month` for USD purchases.

#### Scenario: ARS purchase keeps same billing date
- **WHEN** a purchase is created in ARS
- **THEN** the persisted `billing_date` equals the purchase date

#### Scenario: USD purchase moves to the next billed period
- **WHEN** a purchase is created in USD
- **THEN** the persisted `billing_date` is one calendar month after the purchase date

### Requirement: Standalone period totals SHALL use billing date
The system SHALL assign standalone 1-installment purchases to card periods using `billing_date` instead of `purchase_date`.

#### Scenario: USD standalone purchase is counted in the next period
- **WHEN** a standalone USD purchase is included in card period totals
- **THEN** the purchase contributes only to the period that contains its `billing_date`

### Requirement: Existing purchases SHALL be backfilled deterministically
The system SHALL backfill `billing_date` for historical credit card purchases during migration using the same currency rule as new writes.

#### Scenario: Historical USD purchase receives next-month billing date
- **WHEN** the migration runs over an existing USD purchase
- **THEN** the row receives `billing_date = purchase_date + 1 month`