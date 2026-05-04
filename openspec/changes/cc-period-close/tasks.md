## Backend

- [ ] 1.1 Crear migración Alembic: columnas en `credit_card_period_configs` (status VARCHAR(20) DEFAULT 'OPEN', closed_at, reopened_at, reopened_by UUID FK, reopen_reason TEXT)
- [ ] 1.2 Crear migración Alembic: tabla `credit_card_period_snapshots` (id, period_config_id FK, snapshot_at, total_purchases, total_payments, pending_balance, purchase_count, installment_count, created_by FK)
- [ ] 1.3 Actualizar modelo SQLAlchemy `CreditCardPeriodConfig` con nuevos campos; crear modelo `CreditCardPeriodSnapshot`
- [ ] 1.4 Actualizar `CreditCardService.get_period()` para incluir campo `status` en respuesta
- [ ] 1.5 Implementar `CreditCardService.close_period(period_id, admin_user_id)` con validación y creación de snapshot
- [ ] 1.6 Implementar `CreditCardService.reopen_period(period_id, admin_user_id, reason)` con validación de motivo (mín. 10 chars)
- [ ] 1.7 Agregar validación de estado del período en `create_purchase()`, `update_purchase()`, `delete_purchase()`
- [ ] 1.8 Implementar exención de ajustes bancarios en lógica de permisos (purchase_type ∈ INTEREST/TAX/PENALTY/FEE)
- [ ] 1.9 Crear endpoints: `POST /credit-cards/{card_id}/periods/{period_id}/close`, `POST /periods/{period_id}/reopen`, `GET /periods/{period_id}/status`
- [ ] 1.10 Agregar parámetro `include_status=true` a `GET /credit-cards/{card_id}/periods`
- [ ] 1.11 Actualizar `audit_service` para loguear `PERIOD_CLOSED`, `PERIOD_REOPENED`, `BANK_ADJUSTMENT_IN_CLOSED_PERIOD`

## Frontend

- [ ] 2.1 Crear componente `PeriodStatusBadge` (OPEN → verde, CLOSED → rojo, REOPENED → amarillo)
- [ ] 2.2 Integrar `PeriodStatusBadge` en selector de período y header de resumen del período
- [ ] 2.3 Crear `ClosePeriodModal` (confirmación admin-only, solo si OPEN, muestra resumen snapshot post-cierre)
- [ ] 2.4 Crear `ReopenPeriodModal` (motivo obligatorio mín. 10 chars, contador de caracteres)
- [ ] 2.5 Implementar bloqueo de C/E/D en formulario de compras para períodos cerrados (no-admin)
- [ ] 2.6 Agregar botón "Agregar Ajuste Bancario" en períodos cerrados (admin only) con form específico (INTEREST/TAX/PENALTY/FEE)
- [ ] 2.7 Mostrar banner "Período reabierto por: {reason}" en períodos con status REOPENED
- [ ] 2.8 Mostrar resumen post-cierre (total compras, pagos, balance pendiente)

## Testing

- [ ] 3.1 Tests unitarios para `close_period()`, `reopen_period()`, validaciones de permisos
- [ ] 3.2 Tests de integración para endpoints close, reopen, status, list con status
- [ ] 3.3 Tests de UI para badge de estado, modals de cierre/reapertura, bloqueo de C/E/D
- [ ] 3.4 Validar todos los escenarios de error (tabla de 8 errores del spec)
- [ ] 3.5 Test end-to-end: Cerrar período → Intentar editar (bloqueado) → Reabrir → Editar exitoso → Cerrar nuevamente
- [ ] 3.6 Documentar flujo de cierre de período en README (guía de usuario)
