## ADDED Requirements

### Requirement: USD purchases SHALL preserve purchase history separately from billed-period assignment
The system SHALL store the real purchase date and a separate `billing_date` for credit card purchases so that transaction history and billed-period assignment can differ.

#### Scenario: USD purchase keeps its original purchase date
- **WHEN** a user registers a purchase in USD
- **THEN** the system preserves the original purchase date as historical data and also stores a billing date for period calculations

### Requirement: Billing date SHALL depend on purchase currency
The system SHALL assign `billing_date = purchase_date` for ARS purchases and `billing_date = purchase_date + 1 month` for USD purchases unless a future card-specific rule overrides it.

#### Scenario: ARS purchase bills in the same period
- **WHEN** a user registers a purchase in ARS
- **THEN** the system uses the purchase date as the billing date for period assignment

#### Scenario: USD purchase bills in the following period
- **WHEN** a user registers a purchase in USD
- **THEN** the system uses one month after the purchase date as the billing date for period assignment

### Requirement: USD conversion SHALL preserve the billed ARS amount for later calculations
The system SHALL convert USD purchases to ARS using the configured exchange rate and SHALL persist the converted ARS amount so later period totals and summaries use a stable billed amount.

#### Scenario: Persisted ARS value is reused in summaries
- **WHEN** a USD purchase is billed into a card period
- **THEN** the system uses the persisted ARS amount for summary calculations instead of recalculating the conversion dynamically on each read