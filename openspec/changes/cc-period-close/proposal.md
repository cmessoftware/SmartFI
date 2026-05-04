## Why

Los períodos de tarjeta de crédito pueden modificarse indefinidamente después de que la `closing_date` ha pasado. Esto genera riesgos de cambios accidentales en registros finalizados, ausencia de auditoría de cierre, estado operacional poco claro y reportes inconsistentes.

## What Changes

- Introducir estado `CLOSED` para períodos de tarjeta de crédito (además del `OPEN` existente), con transición adicional a `REOPENED`.
- Al cerrar un período, los usuarios no-admin quedan bloqueados para crear/editar/borrar compras.
- Los admins pueden reabrir con motivo obligatorio y auditoría automática.
- El sistema captura snapshot de totales del período al momento del cierre.
- Solo ajustes bancarios (intereses, cargos, impuestos, penalidades) pueden agregarse a períodos cerrados por admin.
- El estado del período es visible en el selector de período y headers de resumen.

## Capabilities

### New Capabilities

- `period-close-status`: Ciclo de vida de estado de período de tarjeta de crédito (OPEN → CLOSED → REOPENED), incluyendo validaciones de transición, bloqueo de C/E/D para no-admin, y visualización del estado en UI.
- `period-close-snapshot`: Captura automática del snapshot de totales del período (compras, pagos, balance pendiente, cantidad de compras e installments) al momento del cierre.
- `period-admin-reopen`: Flujo de reapertura de período cerrado por admin con motivo obligatorio, auditoría y banner de confirmación en UI.

### Modified Capabilities

- Credit Card Purchases C/E/D: Agregar validación de estado del período antes de crear/editar/borrar compras.

## Impact

- **Backend** (`backend/database/database.py`): Nuevos campos en `CreditCardPeriodConfig` (status, closed_at, reopened_at, reopened_by, reopen_reason); nuevo modelo `CreditCardPeriodSnapshot`.
- **Backend** (`backend/main.py`): Nuevos endpoints `/credit-cards/{card_id}/periods/{period_id}/close`, `/reopen`, `/status`.
- **Backend** (`backend/services/credit_card_service.py`): Métodos `close_period()`, `reopen_period()`, validaciones en `create_purchase()`, `update_purchase()`, `delete_purchase()`.
- **Database**: Columnas en `credit_card_period_configs`, nueva tabla `credit_card_period_snapshots`.
- **Frontend**: Componentes `PeriodStatusBadge`, `ClosePeriodModal`, `ReopenPeriodModal`; lógica de bloqueo en formularios de compras.
