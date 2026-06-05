## Why

DBT-FEAT-003 sigue en estado Todo porque la proyeccion de cuotas de deudas no tarjeta no se materializa de forma consistente en meses futuros.

Impacto funcional actual:
- Al crear una deuda con 12 cuotas, en varios casos solo aparece el mes de originacion.
- La vista de Deudas y Presupuesto queda desalineada respecto al plan de cuotas esperado (X/Y por mes calendario).
- Se bloquea el cierre de bugs relacionados (DBT-BUG-004, DBT-BUG-006).

## What Changes

- Corregir la generacion de proyecciones mensuales para que siempre cree una fila por cuota pendiente en meses calendario futuros.
- Estandarizar la regla de fecha base:
  - `start_date` = fecha de toma de deuda.
  - `due_date` = fecha de primera cuota (si no se informa, default al mes siguiente de `start_date`).
- Asegurar idempotencia y reconciliacion en lectura/actualizacion para registros historicos inconsistentes.
- Alinear visualizacion frontend para consumir y mostrar la cuota vigente y los meses proyectados sin falsos positivos de "no propagado".

## Capabilities

### Modified Capabilities

- `dbt-budget-projection-by-installment`:
  - La proyeccion se genera desde primera cuota y cubre todas las cuotas pendientes.
  - No se admite degradacion a una sola fila mensual salvo deudas de cuota unica.

- `dbt-debt-records-source-of-truth`:
  - `DebtRecord` mantiene la regla canonica de fechas (`start_date` vs `due_date`) y reconciliacion de proyecciones.

## Impact

- Backend:
  - `backend/services/debt_record_service.py`
  - `backend/main.py` (solo si hay ajuste de contrato/validacion)
- Frontend:
  - `frontend/src/services/api.js`
  - `frontend/src/components/DebtManager.jsx`
  - `frontend/src/components/NewDebtModal.jsx`
  - `frontend/src/components/EditDebtModal.jsx`
- Data:
  - No se requiere cambio de esquema si la correccion queda en logica.
  - Puede requerir rutina de reconciliacion para registros ya creados incorrectamente.
