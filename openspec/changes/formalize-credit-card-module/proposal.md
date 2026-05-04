## Why

The credit card module already has a large functional backlog, but its rules are still captured in a mixed narrative document with resolved fixes, pending bugs, and implementation notes. That makes it difficult to validate behavior consistently, prioritize new work, and use OpenSpec as the contract for future changes.

## What Changes

- Formalize the current credit card module into OpenSpec artifacts that separate stable requirements from implementation details and historical notes.
- Define canonical functional requirements for card-period assignment, payment registration, installment propagation, and USD billing behavior.
- Establish a spec baseline that future credit card bug fixes and improvements can extend through focused OpenSpec changes.
- Preserve the existing structured backlog as planning input, while moving normative behavior into specs and implementation sequencing into tasks.

## Capabilities

### New Capabilities
- `credit-card-period-accounting`: Defines how purchases and payments are assigned to card periods, including closing-date boundaries and period-aware validation.
- `credit-card-installment-lifecycle`: Defines how installment purchases create schedules, propagate into future periods, and expose paid versus pending status.
- `credit-card-payment-allocation`: Defines how registered card payments are linked to period budget items and how they affect pending debt summaries.
- `credit-card-usd-billing`: Defines how USD purchases preserve purchase history while impacting the billed period through `billing_date` and ARS conversion rules.

### Modified Capabilities

None.

## Impact

- Affects OpenSpec artifacts under `openspec/changes/` and new baseline specs under `openspec/specs/`.
- Establishes the requirement contract for backend logic in `backend/services/credit_card_service.py` and API behavior in `backend/main.py`.
- Establishes the requirement contract for frontend payment and period workflows in `frontend/src/components/CreditCardManager.jsx` and `frontend/src/components/CreditCardPaymentModal.jsx`.
- Uses `docs/SmartFI-V1/SmartFI_CREDIT_CARD_MODULE.md` and `docs/SmartFI-V1/SmartFI_CREDIT_CARD_MODULE.backlog.json` as source material, but moves the authoritative behavior definition into OpenSpec.