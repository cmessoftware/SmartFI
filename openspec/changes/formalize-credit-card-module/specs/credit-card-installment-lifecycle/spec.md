## ADDED Requirements

### Requirement: Installment purchases SHALL create a complete installment schedule
The system SHALL treat a purchase with more than one installment as a financed purchase and SHALL generate exactly one installment plan with exactly the configured number of scheduled installments.

#### Scenario: Three-installment purchase creates three schedule items
- **WHEN** a user registers a purchase with `installments = 3`
- **THEN** the system creates one installment plan and exactly three installment schedule items for that purchase

### Requirement: Each installment SHALL impact only its billed period
The system SHALL include each scheduled installment only in the billed period that corresponds to that installment's due date, and SHALL not propagate the same installment amount into additional future periods.

#### Scenario: Future periods show only the matching installment
- **WHEN** a financed purchase spans multiple months
- **THEN** each future period shows only the installment scheduled for that period and excludes installments from earlier or later periods

### Requirement: Installment schedule status SHALL remain separate from card payment accounting
The system SHALL allow users to mark an installment schedule item as paid or unpaid for tracking purposes, but that status change SHALL NOT by itself register or allocate a card payment against the card debt summary.

#### Scenario: Marking a schedule item as paid does not register a card payment
- **WHEN** a user marks an installment schedule item as paid in the cronograma
- **THEN** the system updates the schedule status without creating a card payment transaction or reducing pending debt unless a separate card payment is registered