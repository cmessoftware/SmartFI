## Context

The backend already stores the original `purchase_date`, the purchase currency, the exchange rate, and the ARS-converted amount for USD purchases. However, standalone purchase assignment still filters periods using `purchase_date`, so USD purchases are billed in the current period even though the intended business rule is to bill them in the following period.

This change is a focused data-model and query update. It touches the SQLAlchemy model, purchase creation flow, and period query logic. Existing data must be backfilled so old purchases keep working without a dual-write transition window.

## Goals / Non-Goals

**Goals:**
- Persist a `billing_date` on `CreditCardPurchase`.
- Set `billing_date` deterministically at creation time based on currency.
- Make standalone 1-installment period calculations use `billing_date`.
- Backfill historical purchases with deterministic values so current summaries keep working.

**Non-Goals:**
- Change installment-plan logic or due-date generation for financed purchases.
- Rework frontend purchase forms unless backend serialization requires a small follow-up.
- Introduce card-specific or issuer-specific FX billing rules beyond the current one-month rule.

## Decisions

### Decision: Make `billing_date` a persisted column on `credit_card_purchases`
`billing_date` will be stored in the same table as the purchase so period queries remain simple and deterministic.

Rationale:
- The billed period becomes part of the purchase record and does not need to be recalculated on every read.
- Historical rows can be backfilled once and then queried uniformly.

Alternatives considered:
- Compute the billed date dynamically in queries from `purchase_date` and `currency`. Rejected because it makes query logic harder to reason about and complicates future overrides.

### Decision: Keep backward-compatible query fallback during rollout
Period queries will use `billing_date` when present and fall back to `purchase_date` only if needed during the migration boundary.

Rationale:
- It reduces risk while the migration is applied across existing data.
- It keeps the service resilient if any historical row is temporarily incomplete.

Alternatives considered:
- Require `billing_date` to be non-null immediately everywhere. Rejected for the initial rollout because it increases migration risk.

### Decision: Backfill existing rows in Alembic using the same currency rule as runtime writes
Historical ARS purchases will receive `billing_date = purchase_date`; historical USD purchases will receive `billing_date = purchase_date + 1 month`.

Rationale:
- The migration result matches the new write path.
- Existing period totals become consistent without manual data repair.

Alternatives considered:
- Leave historical rows null and only apply the rule to new purchases. Rejected because mixed semantics would keep summaries inconsistent.

## Risks / Trade-offs

- [Risk] Existing summaries may shift for historical USD purchases after backfill. → Mitigation: validate one known card/period before and after the migration with a targeted summary check.
- [Risk] Some code paths may still serialize or sort only by `purchase_date`. → Mitigation: keep purchase history unchanged and restrict the change to billed-period calculations for standalone purchases.
- [Risk] Null `billing_date` rows could survive if the migration fails mid-way. → Mitigation: use a backfill update inside Alembic and keep service fallback to `purchase_date` temporarily.

## Migration Plan

1. Add nullable `billing_date` to `credit_card_purchases` through Alembic.
2. Backfill all existing rows based on currency and purchase date.
3. Update runtime writes in `create_purchase()` to persist `billing_date` for new rows.
4. Update standalone period queries to use `billing_date` with fallback to `purchase_date`.
5. Validate one known USD purchase/card summary after migration.
6. Optionally tighten nullability in a later cleanup migration once all environments are migrated.

## Open Questions

- Does any API consumer need `billing_date` immediately in the purchase payload, or can it remain backend-only for now?
- Should manual purchase editing also recalculate `billing_date` when currency or purchase date changes, or is that better handled in a dedicated follow-up change?