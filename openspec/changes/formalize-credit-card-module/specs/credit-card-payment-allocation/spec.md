## ADDED Requirements

### Requirement: Registered card payments SHALL be linked to the billed period budget item
The system SHALL register a card payment as an expense transaction linked to the budget item that represents the billed card period.

#### Scenario: Payment is recorded against the selected period item
- **WHEN** a user registers a card payment from the credit card summary for a period that already has a corresponding budget item
- **THEN** the system creates or updates the payment transaction with a link to that period budget item

### Requirement: Card debt summaries SHALL subtract registered payments
The system SHALL reduce a card's pending debt summary by the amount of registered payment transactions linked to the card's billed period budget items.

#### Scenario: Registered payment reduces pending debt
- **WHEN** a payment transaction is saved and linked to a budget item for the card period
- **THEN** the card summary recalculates pending debt using the billed charges minus the linked registered payments

### Requirement: Payment edits and deletions SHALL keep the summary consistent
The system SHALL recompute card payment totals and pending debt after a linked card payment is edited or deleted.

#### Scenario: Edited payment updates the summary
- **WHEN** a user edits the amount or date of a linked card payment
- **THEN** the card period summary reflects the updated payment values after the change is saved

#### Scenario: Deleted payment restores pending debt
- **WHEN** a user deletes a linked card payment
- **THEN** the card period summary removes that payment from totals and restores the corresponding pending debt amount