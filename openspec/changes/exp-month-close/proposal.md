## Why

El módulo de gastos permite modificar transacciones indefinidamente, sin distinción entre meses activos y meses ya finalizados. Esto genera riesgos de cambios accidentales en registros históricos, ausencia de auditoría sobre el estado de cierre de cada mes, y reportes inconsistentes por modificaciones fuera de período.

## What Changes

- Introducir un campo `status` en períodos mensuales (`OPEN`, `CLOSED`, `REOPENED`).
- Al cerrar un mes, los usuarios no-admin quedan bloqueados para crear/editar/borrar transacciones.
- Los admins pueden reabrir con motivo obligatorio y auditoría automática.
- El sistema captura un snapshot de totales al momento del cierre.
- Solo ajustes bancarios (`origin = bank_adjustment`) pueden agregarse a meses cerrados por admin.
- El estado del mes es visible en el selector de mes y en el header de transacciones.
- El cierre de mes es exclusivamente manual por admin; no se permite cierre automático por cambio de fecha o fin de mes.

## Capabilities

### New Capabilities

- `month-close-status`: Ciclo de vida de estado mensual (OPEN → CLOSED → REOPENED), incluyendo validaciones de transición, bloqueo de C/E/D para no-admin, y visualización del estado en UI.
- `month-close-snapshot`: Captura automática del snapshot de totales del mes (ingresos, egresos, balance neto, cantidad de transacciones) al momento del cierre.
- `month-admin-reopen`: Flujo de reapertura de mes cerrado por admin con motivo obligatorio, auditoría y banner de confirmación en UI.

### Modified Capabilities

- Transactions C/E/D: Agregar validación de estado del período mensual antes de crear/editar/borrar transacciones.

## Impact

- **Backend** (`backend/database/database.py`): Nuevos modelos `MonthlyPeriod` y `MonthlyPeriodSnapshot`.
- **Backend** (`backend/main.py`): Nuevos endpoints `/months/{year_month}/close`, `/months/{year_month}/reopen`, `/months/{year_month}/status`.
- **Backend** (transaction endpoints): Validación de estado de período en create/update/delete.
- **Database**: Nueva tabla `monthly_periods`, nueva tabla `monthly_period_snapshots`, columna `monthly_period_id` en `transactions`.
- **Frontend**: Componentes `MonthStatusBadge`, `ClosePeriodModal`, `ReopenPeriodModal`; lógica de bloqueo en formularios de transacciones.
