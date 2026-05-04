## Context

Los períodos de tarjeta de crédito son definidos por límites personalizados (`period_start`, `period_end`, `closing_date`, `due_date`), típicamente de 25–50 días y que pueden cruzar límites de mes calendario. A diferencia del flujo de gastos mensuales, el cierre de período debe acomodar:
- Longitudes y timings irregulares de período
- Cierre retroactivo potencial (cerrar un período de meses atrás)
- Coexistencia de períodos abiertos y cerrados (período actual abierto, anteriores cerrados)
- Reapertura de períodos para correcciones sin pérdida de datos

## Goals / Non-Goals

**Goals:**
- Introducir ciclo de vida de estado de período (OPEN/CLOSED/REOPENED)
- Bloquear C/E/D de compras en períodos cerrados para no-admin
- Capturar snapshot inmutable de totales al cierre
- Permitir reapertura con motivo obligatorio + auditoría
- Eximir ajustes bancarios (INTEREST, TAX, PENALTY, FEE) del bloqueo (admin only)

**Non-Goals:**
- Cierre automático al llegar a la `closing_date` (siempre manual por admin)
- Sincronización de cierre con módulo de gastos
- Bloqueo de pagos en períodos cerrados (los pagos son registros separados)

## Decisions

**D1 — Campos de estado en `CreditCardPeriodConfig` (no modelo separado):**
El período ya existe como modelo dedicado. Agregar campos de estado directamente evita un join adicional en cada consulta de período. Esto es más eficiente que un modelo separado dado que la relación es 1:1.

**D2 — Solo admins pueden cerrar/reabrir:**
Consistente con el módulo de gastos. El cierre de período es una operación de control contable.

**D3 — Snapshot inmutable al cierre:**
Se crea al momento del cierre; al reabrir y volver a cerrar, se crea uno nuevo. Los snapshots anteriores no se modifican. Esto permite auditar cada cierre individualmente.

**D4 — Exención de ajustes bancarios:**
Intereses, cargos, impuestos y penalidades (`purchase_type ∈ [INTEREST, TAX, PENALTY, FEE, BANK_ADJUSTMENT]`) pueden ocurrir después del cierre. Permisos especiales para admin con evento de auditoría dedicado.

**D5 — Status `REOPENED` distinto de `OPEN`:**
Permite UI diferenciada (badge amarillo vs verde) y auditoría más granular de períodos que fueron reabiertos.

## Risks / Trade-offs

- **Riesgo:** Si un admin cierra un período con compras aún pendientes de reconciliar, el snapshot no reflejará el estado final. Mitigación: advertencia en el diálogo de cierre si hay compras sin categoría o sin asignar.
- **Trade-off:** Agregar columnas a `credit_card_period_configs` implica migración Alembic. Aceptable dado que las nuevas columnas son todas nullable (excepto `status` con default).
- **Riesgo:** La exención de ajustes bancarios puede usarse incorrectamente para ingresar compras regulares en períodos cerrados. Mitigación: validar `purchase_type` al aplicar la exención.

## Migration Plan

1. Crear migración Alembic: columnas en `credit_card_period_configs` (status, closed_at, reopened_at, reopened_by, reopen_reason), tabla `credit_card_period_snapshots`.
2. Backfill: todos los períodos existentes pasan a `status = OPEN`.
3. Deploy backend con nuevos endpoints y validaciones.
4. Deploy frontend con nuevos badges y modals.
5. Admin puede comenzar a cerrar períodos desde UI.
