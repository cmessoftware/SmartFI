## Backend

- [ ] 1.1 Crear migración Alembic para tabla `monthly_periods` (id, year_month, status, closed_at, closed_by, reopened_at, reopened_by, reopen_reason, created_at, updated_at)
- [ ] 1.2 Crear migración Alembic para tabla `monthly_period_snapshots` (id, monthly_period_id, snapshot_at, total_expenses, total_income, net_balance, transaction_count, created_by)
- [ ] 1.3 Agregar columna `monthly_period_id` (nullable FK) a tabla `transactions`
- [ ] 1.4 Crear modelos SQLAlchemy `MonthlyPeriod` y `MonthlyPeriodSnapshot` en `database/database.py`
- [ ] 1.5 Implementar `get_month_status(year_month)` en `database_service`
- [ ] 1.6 Implementar `close_month(year_month, admin_user_id)` con validación y creación de snapshot
- [ ] 1.7 Implementar `reopen_month(year_month, admin_user_id, reason)` con validación de motivo (mín. 10 chars)
- [ ] 1.8 Agregar validación de estado de período en `create_transaction()`, `update_transaction()`, `delete_transaction()`
- [ ] 1.9 Implementar exención de ajustes bancarios en lógica de permisos
- [ ] 1.10 Crear endpoints `POST /months/{year_month}/close`, `POST /months/{year_month}/reopen`, `GET /months/{year_month}/status` en `main.py`
- [ ] 1.11 Agregar parámetro `include_status=true` a `GET /months`
- [ ] 1.12 Actualizar `audit_service` para loguear `MONTH_CLOSED`, `MONTH_REOPENED`, `BANK_ADJUSTMENT_IN_CLOSED_MONTH`

## Frontend

- [ ] 2.1 Crear componente `MonthStatusBadge` (OPEN → verde, CLOSED → rojo, REOPENED → amarillo)
- [ ] 2.2 Integrar `MonthStatusBadge` en selector de mes y header de transacciones
- [ ] 2.3 Crear modal de cierre de mes con confirmación (solo admin, solo si OPEN)
- [ ] 2.4 Crear modal de reapertura con campo de motivo obligatorio (mín. 10 chars, contador de caracteres)
- [ ] 2.5 Implementar bloqueo de C/E/D en formulario de transacciones para meses cerrados (no-admin)
- [ ] 2.6 Agregar botón "Agregar Ajuste Bancario" en meses cerrados (admin only) con form específico
- [ ] 2.7 Mostrar banner "Mes reabierto por: {reason}" en meses con status REOPENED
- [ ] 2.8 Mostrar resumen post-cierre (total ingresos, egresos, balance neto)

## Testing

- [ ] 3.1 Tests unitarios para `close_month()`, `reopen_month()`, validaciones de permisos
- [ ] 3.2 Tests de integración para endpoints close, reopen, status, list con status
- [ ] 3.3 Tests de UI para badge de estado, modals de cierre/reapertura, bloqueo de C/E/D
- [ ] 3.4 Validar todos los escenarios de error (tabla de 6 errores del spec)
- [ ] 3.5 Test end-to-end: Cerrar mes → Intentar editar (bloqueado) → Reabrir → Editar exitoso → Cerrar nuevamente
- [x] 3.6 Validar regresión: al cambiar de mes (ej. abril → mayo) no debe producirse cierre automático; el cierre solo ocurre por acción manual de admin (EXP-BUG-010)
- [x] 3.7 Investigar y corregir inconsistencia en totales de ingresos de abril 2026: panel muestra $9.791.646,24 pero suma de ingresos en tabla/CSV es $8.478.079,00 — corregido unificando fuente mensual panel/tabla y exportación CSV en el conjunto visible (EXP-BUG-011)
- [x] 3.8 Corregir error intermitente al borrar gasto (`DELETE /api/transactions/{id}`) y validar eliminación sin 500 (EXP-BUG-007)
- [x] 3.9 Corregir error al importar desde CSV y validar importación funcional completa (EXP-BUG-008)
- [x] 3.10 Corregir error en alta masiva desde CSV (incluyendo respuestas 401 intermitentes) y validar flujo de carga (EXP-BUG-009)
