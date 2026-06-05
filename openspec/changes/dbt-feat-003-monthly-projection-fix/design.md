## Context

El servicio de deudas no tarjeta ya implementa funciones de proyeccion mensual, pero se observaron casos reales donde la deuda queda con una sola proyeccion en el mes de inicio.

Esto indica inconsistencia entre:
- reglas de negocio deseadas,
- datos persistidos historicamente,
- y flujo real API/UI al momento de alta.

## Goals / Non-Goals

### Goals

- Garantizar que una deuda con N cuotas pendientes genere N proyecciones mensuales (desde primera cuota).
- Consolidar la semantica de fechas para evitar interpretaciones ambiguas.
- Proveer reconciliacion deterministica para corregir datos inconsistentes existentes.

### Non-Goals

- No implementar dashboards FEAT-006/007/008 en este cambio.
- No redefinir el modelo de pagos parciales de FEAT-004/005.

## Affected Modules

- Backend:
  - `backend/services/debt_record_service.py`
  - `backend/main.py` (validaciones Pydantic solo si aplica)
- Frontend:
  - `frontend/src/services/api.js`
  - `frontend/src/components/NewDebtModal.jsx`
  - `frontend/src/components/EditDebtModal.jsx`
  - `frontend/src/components/DebtManager.jsx`

## Data Model Changes

- Cambio de esquema: No.
- Cambio de comportamiento: Si, sobre generacion/reconciliacion de `BudgetItem` asociados a `DebtRecord`.
- Migracion Alembic: No requerida para este alcance.

## API Contract

- Se mantiene contrato de `POST /api/debt-records` y `PUT /api/debt-records/{id}`.
- Regla funcional explícita:
  - si `due_date` es null y existe `start_date`, backend calcula `due_date = start_date + 1 mes`.
- `GET /api/debt-records/projected` debe reflejar `projection_count` consistente con cuotas pendientes.

## Security Considerations

- Sin cambios de autenticacion/autorizacion.
- Mantener validaciones de ownership por `user_id` en reconciliacion y update.
- Evitar reconciliar registros fuera del usuario autenticado.

## Decisions

### Decision 1

- Decision: usar `due_date` como fecha base de primera cuota para proyeccion.
- Rationale: representa regla funcional de negocio acordada (inicio de deuda != primera cuota).
- Alternatives considered: usar `start_date` directo; rechazado por romper semantica funcional.

### Decision 2

- Decision: mantener reconciliacion defensiva en lectura proyectada para corregir historicos inconsistentes.
- Rationale: evita dejar datos rotos cuando ya existen deudas creadas con logica previa.
- Alternatives considered: script one-shot solamente; rechazado porque no cubre nuevos casos borde.

## Risks / Trade-offs

- [Risk] Reconciliacion en lectura incrementa costo de consulta. -> Mitigation: ejecutar solo cuando expected_months != existing_months.
- [Risk] Usuario percibe cambio de meses en deudas viejas. -> Mitigation: documentar en release note y mantener idempotencia.

## Migration Plan

1. Ajustar/confirmar logica de proyeccion y default de `due_date` en backend.
2. Ejecutar reconciliacion controlada para registros inconsistentes de usuarios afectados.
3. Verificar con casos reales (Personal 9/10 y nuevos casos de alta).
4. Validar UI en navegacion de meses para confirmar visualizacion futura.

## Open Questions

- ¿La reconciliacion debe ejecutarse solo on-demand o tambien en un comando administrativo batch?
- ¿Se agrega endpoint de diagnostico para conteo de proyecciones por deuda?
