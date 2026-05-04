## Context

The credit card module already spans backend period logic, installment scheduling, payment registration, and frontend period workflows. Its current source material is split between implementation code, bug-fix history, and a narrative backlog document, which makes it hard to distinguish settled business rules from pending enhancements.

This change does not implement new runtime behavior by itself. It defines a spec baseline so future credit card work can be applied through smaller OpenSpec changes with a stable contract.

## Goals / Non-Goals

**Goals:**
- Convert the current credit card module knowledge into a small set of capability-oriented specs.
- Align the capabilities with the existing implementation seams in `credit_card_service.py`, API endpoints, and frontend payment flows.
- Preserve important business distinctions already validated in the module, especially period-aware accounting, installment propagation, and the separation between installment status and actual card payments.
- Document the planned USD `billing_date` model as an explicit requirement baseline for later implementation.

**Non-Goals:**
- Implement pending backlog items during this change.
- Rework the frontend or backend architecture.
- Resolve every open bug or encode every UI detail from the backlog into this first baseline.
- Replace historical documentation under `docs/`; that material remains as planning and audit context.

## Decisions

### Decision: Organize the baseline around four functional capabilities
The change defines four capabilities: period accounting, installment lifecycle, payment allocation, and USD billing.

Rationale:
- These match the main business decisions already present in the module.
- They map directly to the main service/API/UI seams without creating overly granular specs.
- They provide a stable base for later change-specific deltas.

Alternatives considered:
- One single module-wide spec. Rejected because it would become too broad and hard to evolve.
- One spec per backlog ticket. Rejected because the backlog still mixes bugs, UX tweaks, and core behavior.

### Decision: Treat OpenSpec as the normative behavior source and keep the existing document as input history
The existing markdown and JSON backlog remain useful as discovery and prioritization inputs, but the normative behavior for future work moves into OpenSpec artifacts.

Rationale:
- The current document mixes resolved items, proposed ideas, and debugging evidence.
- OpenSpec provides a cleaner contract for future implementation and archive workflows.

Alternatives considered:
- Continue using only the narrative document. Rejected because it does not enforce artifact order or requirement-level change tracking.

### Decision: Keep installment status distinct from payment allocation
The installment schedule spec will explicitly preserve the current business rule that marking an installment as paid is a schedule-state update and not the same as registering a payment against the card debt.

Rationale:
- This matches the validated domain rule: card payments can be partial and are not tied to individual installments.
- It prevents future changes from accidentally treating cronograma state as the financial source of truth.

Alternatives considered:
- Make installment payment state reduce card debt automatically. Rejected because it conflicts with current business behavior.

### Decision: Include `billing_date` as a planned data-model requirement in the baseline
The USD billing model is included now even though it is not fully implemented yet.

Rationale:
- It is already documented as the preferred business direction.
- It affects future data model and period assignment work, so it should be part of the contract before implementation starts.

Alternatives considered:
- Leave USD handling out of the baseline until code work begins. Rejected because it would keep a known business rule outside the spec system.

## Risks / Trade-offs

- [Risk] The first baseline may omit some lower-priority UI details from the narrative backlog. → Mitigation: keep those items in the structured backlog and add focused follow-up changes when they alter normative behavior.
- [Risk] Documenting `billing_date` before implementation could create a temporary mismatch between specs and runtime behavior. → Mitigation: keep the tasks explicit about follow-up implementation and migration work.
- [Risk] Future contributors may continue treating the old markdown document as authoritative. → Mitigation: point future work to the OpenSpec capability set and keep proposal/design/tasks linked to it.

## Migration Plan

1. Create the baseline OpenSpec artifacts for the credit card module.
2. Use these artifacts as the starting point for future `/opsx:apply` changes in the module.
3. When implementing USD billing, introduce the `billing_date` data model change through Alembic and update affected backend queries and frontend displays under a dedicated follow-up apply change.
4. Archive legacy backlog entries progressively by linking them to the OpenSpec changes that implement them.

## Open Questions

- Should period-window restrictions for manual entry and CSV import become a fifth dedicated capability, or remain inside period accounting until their implementation begins?
- Should the baseline eventually include explicit requirements for generated budget-item descriptions and minimum payment text, or keep those in narrower follow-up changes?
- Does the team want a one-to-one mapping between backlog IDs and future OpenSpec changes, or a capability-first grouping with multiple backlog IDs per change?