## Backend

- [ ] 1.1 Crear migración Alembic para tabla `credit_card_period_carryovers` (id, period_config_id FK, source_period_id FK, carryover_amount, carryover_date, created_at; constraint source ≠ current)
- [ ] 1.2 Agregar columnas a `credit_card_purchases`: `origin` VARCHAR(50) DEFAULT 'PURCHASE', `source_period_id` UUID FK nullable
- [ ] 1.3 Actualizar modelo SQLAlchemy `CreditCardPurchase` con campos `origin` y `source_period_id`; crear modelo `CreditCardPeriodCarryover`
- [ ] 1.4 Implementar `CreditCardService.calculate_carryover(new_period)` — suma saldos impagos de todos los períodos anteriores cerrados
- [ ] 1.5 Implementar `CreditCardService.create_carryover_line_item(period_id, carryover_amount, source_periods)` — crea pseudo-compra con `origin = CARRYOVER`
- [ ] 1.6 Implementar `CreditCardService.create_period_with_carryover(period_data, card_id, admin_user_id)` — orquesta creación de período + carryover
- [ ] 1.7 Implementar `CreditCardService.get_carryover_detail(period_id, carryover_id)` — retorna desglose con compras origen no pagas
- [ ] 1.8 Actualizar cálculo de pago mínimo en `CreditCardService` para incluir `carryover_amount`
- [ ] 1.9 Actualizar `POST /credit-cards/{card_id}/periods` para invocar `create_period_with_carryover()` y retornar carryover en respuesta
- [ ] 1.10 Crear endpoint `GET /credit-cards/{card_id}/periods/{period_id}/carryover/{carryover_id}` para drill-down
- [ ] 1.11 Agregar parámetros `include_carryover=true` y `include_summary=true` a `GET /periods` y `GET /periods/{id}`
- [ ] 1.12 Actualizar `audit_service` para loguear `PERIOD_CREATED`, `CARRYOVER_CREATED`

## Frontend

- [ ] 2.1 Crear componente `CarryoverBadge` (muestra total de carryover, clickable para drill-down)
- [ ] 2.2 Crear componente `CarryoverLineItem` (estilo especial para `SALDO ANTERIOR` en lista de compras: gris/muted, badge, tooltip)
- [ ] 2.3 Crear componente `CarryoverDrillDownModal` (desglose: compras origen, pagos aplicados, intereses, total; lista de transacciones no pagas del período origen)
- [ ] 2.4 Crear componente `PeriodSummaryWidget` (fechas del período, badge de estado, nuevas compras, carryover, total pendiente, pago mínimo con callout)
- [ ] 2.5 Integrar carryover en header del período y selector de período
- [ ] 2.6 Mostrar pago mínimo con callout "incluye saldo anterior" cuando hay carryover

## Testing

- [ ] 3.1 Tests unitarios para `calculate_carryover()`, `create_period_with_carryover()`, cálculo de pago mínimo con carryover
- [ ] 3.2 Tests de integración para `POST /periods` con carryover automático
- [ ] 3.3 Tests de integración para endpoint de drill-down de carryover
- [ ] 3.4 Tests de UI para `CarryoverLineItem`, `CarryoverDrillDownModal`, `PeriodSummaryWidget`
- [ ] 3.5 Validar todos los escenarios de error (tabla de 6 errores del spec)
- [ ] 3.6 Test end-to-end: Cerrar período anterior → Crear nuevo período → Verificar carryover auto-creado → Inspeccionar drill-down → Pagar parcialmente → Crear siguiente período con carryover residual
- [ ] 3.7 Documentar flujo de rollover de período en README (guía de usuario)
