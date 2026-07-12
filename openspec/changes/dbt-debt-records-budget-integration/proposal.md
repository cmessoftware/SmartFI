## Why

El modulo de deudas no tarjeta necesita quedar separado del dominio de tarjeta de credito y operar con una fuente de verdad unica. Hoy existe una mezcla entre presupuesto y deudas que dificulta consistencia funcional.

Se requiere formalizar que `debt-records` es la entidad canonica de deuda no tarjeta, y que `Presupuesto` sea la proyeccion mensual para ejecucion y seguimiento.

Adicionalmente, el negocio requiere manejar cuotas fraccionarias con precision de 2 decimales y habilitar visualizaciones de deuda por fuente y tendencia mensual.

## What Changes

- Definir y estandarizar `debt-records` como fuente de verdad para deudas no tarjeta.
- Integrar proyeccion automatica de cuotas a `BudgetItem` por mes calendario.
- Integrar pagos registrados en presupuesto con reconciliacion de saldo y cuotas pendientes en `debt-records`.
- Aplicar regla funcional de cuotas fraccionarias con 2 decimales.
- Exponer analitica de deuda por fuente (total historico y mes actual) y variacion mensual de 12 meses.

## Capabilities

### Added Capabilities

- `dbt-debt-records-source-of-truth`: fuente unica de deuda no tarjeta.
- `dbt-budget-projection-by-installment`: proyeccion mensual de cuotas a presupuesto.
- `dbt-payment-reconciliation`: pagos de presupuesto sincronizan saldo y cuotas en debt-records.
- `dbt-fractional-installments-2-decimals`: precision de 2 decimales en cuotas pendientes.
- `dbt-debt-analytics-by-source`: graficos de fuente y variacion mensual.

## Impact

- Backend: `backend/main.py`, `backend/services/debt_record_service.py`, `backend/services/debt_service.py`, `backend/services/database_service.py`.
- Data: `backend/database/database.py`, migraciones Alembic en `backend/alembic/versions/`.
- Frontend: `frontend/src/components/DebtManager.jsx`, `frontend/src/components/NewDebtModal.jsx`, `frontend/src/components/EditDebtModal.jsx`, `frontend/src/services/api.js`.
- Documentacion funcional: `docs/SmartFI-V1/SmartFI_DEBTS_MODULE.md`.