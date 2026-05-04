## ADDED Requirements

### Requirement: Card periods SHALL use billing-cycle dates instead of calendar months
The system SHALL assign credit card purchases and period summaries using the configured card billing cycle, including period start, period end, closing date, and due date, rather than relying on calendar-month boundaries.

#### Scenario: Purchase is assigned to the active card cycle
- **WHEN** a user registers a purchase with a date that falls inside a card period's billing-cycle range
- **THEN** the system assigns the purchase to that card period even if the purchase month differs from the period label month

### Requirement: Closing-date ambiguity SHALL be explicit in period assignment workflows
The system SHALL treat the closing date as a shared boundary between the ending period and the next period, and SHALL require an explicit decision whenever a manual workflow cannot infer the intended billed period unambiguously.

#### Scenario: Manual entry on the closing date needs confirmation
- **WHEN** a user manually registers a purchase or payment whose date equals the configured closing date
- **THEN** the system informs the user of the two candidate periods and requires the user to confirm which period should receive the entry before saving

### Requirement: Period-aware validation SHALL protect cross-period payment registration
The system SHALL validate whether a registered card payment belongs to the selected period and SHALL offer reassignment to the correct period when the entered date falls outside the selected billing cycle.

#### Scenario: Payment date belongs to another period
- **WHEN** a user tries to save a card payment in a selected period but the payment date belongs to a different card period
- **THEN** the system identifies the correct period and requires the user to confirm reassignment or return to editing without saving

### Requirement: CSV imports SHALL resolve closing-date entries deterministically
The system SHALL assign imported entries dated exactly on a closing date to the period whose closing date matches that date according to the import policy.

#### Scenario: CSV row lands on the matching closing date
- **WHEN** a CSV import contains a purchase dated on a card closing date
- **THEN** the system assigns that purchase to the period whose closing date equals the imported date