## 1. Publish the credit-card OpenSpec baseline

- [ ] 1.1 Review the four new capability specs with the existing credit card document and confirm the baseline covers the validated business rules.
- [ ] 1.2 Decide how backlog IDs from `SmartFI_CREDIT_CARD_MODULE.backlog.json` map to future OpenSpec changes or follow-up deltas.
- [ ] 1.3 Update team workflow notes so new credit-card work starts from these OpenSpec capabilities instead of adding normative rules only to the narrative document.

## 2. Align code and documentation to the baseline

- [ ] 2.1 Audit `backend/services/credit_card_service.py` and related endpoints against the new specs to identify mismatches between current behavior and the baseline.
- [ ] 2.2 Tag or annotate the legacy credit-card backlog document so resolved rules point back to the new OpenSpec capability set.
- [ ] 2.3 Create focused follow-up changes for any spec-backed gaps that are already known, starting with period validation and USD billing behavior.

## 3. Prepare the first implementation changes

- [ ] 3.1 Open a dedicated apply change for `credit-card-usd-billing` that adds `billing_date` through SQLAlchemy model updates and an Alembic migration.
- [ ] 3.2 Open a dedicated apply change for `credit-card-period-accounting` validations covering closing-date ambiguity, out-of-period payments, and CSV closing-date imports.
- [ ] 3.3 Open a dedicated apply change for remaining payment-allocation and installment-lifecycle gaps that still require runtime fixes or regression tests.