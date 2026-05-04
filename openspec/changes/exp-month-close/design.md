## Context

El módulo de gastos organiza transacciones por mes calendario (YYYY-MM). A diferencia de los períodos de tarjeta de crédito (longitud variable), los meses son de 28–31 días fijos. El cierre de mes necesita:
- Soportar acción manual del admin para cerrar un mes
- Permitir reapertura para correcciones sin pérdida de datos
- Coexistir con meses abiertos (mes actual abierto, meses anteriores cerrados)
- Preservar snapshots del estado histórico para auditoría y reportes

## Goals / Non-Goals

**Goals:**
- Introducir ciclo de vida de estado mensual (OPEN/CLOSED/REOPENED)
- Bloquear C/E/D de transacciones en meses cerrados para no-admin
- Capturar snapshot inmutable de totales al cierre
- Permitir reapertura con motivo obligatorio + auditoría
- Eximir ajustes bancarios del bloqueo (admin only)

**Non-Goals:**
- Cierre automático por cambio de mes calendario, fecha, o fin de mes
- Sincronización de cierre con módulo de presupuesto (fuera de scope)
- Eliminación de transacciones de meses cerrados (no permitido nunca)

## Decisions

**D1 — Modelo `MonthlyPeriod` separado (no campo en Transaction):**
La relación mes → transacciones es 1:N. Centralizar el estado en un modelo dedicado evita redundancia y facilita las queries. Las transacciones se vinculan por `year_month` inferido de `transaction.date`.

**D2 — Solo admins pueden cerrar/reabrir:**
Cierre y reapertura son operaciones de control contable que requieren autorización explícita. Los usuarios regulares no tienen visibilidad del botón.

**D3 — Snapshot inmutable al cierre:**
El snapshot se crea en el momento del cierre y no se actualiza si se reabre (crea uno nuevo al volver a cerrar). Esto preserva la trazabilidad histórica de cada cierre.

**D4 — Exención de ajustes bancarios:**
Los ajustes bancarios (`origin = bank_adjustment`) representan reconciliaciones contables que pueden ocurrir después del cierre. Se permiten en meses cerrados solo para admin, con auditoría especial.

**D5 — Status `REOPENED` vs `OPEN`:**
Distinguir REOPENED de OPEN permite auditoría más granular y UI diferenciada (badge amarillo vs verde). Un mes reopened vuelve a ser writable pero su historial de reaperturas queda registrado.

## Risks / Trade-offs

- **Riesgo:** Usuarios no-admin se quedan sin poder editar si el admin cierra el mes prematuramente. Mitigación: confirmación explícita antes de cerrar + banner visible en UI.
- **Trade-off:** Agregar FK `monthly_period_id` a `transactions` mejora performance pero requiere backfill de registros existentes. Inicialmente puede ser nullable.
- **Riesgo:** Si hay transacciones con fechas en distintos meses (edge case), la inferencia `year_month from date` puede asignar mal. Mitigación: validar al crear transacción.

## Migration Plan

1. Crear migración Alembic: tablas `monthly_periods`, `monthly_period_snapshots`, columna `monthly_period_id` en `transactions` (nullable).
2. Backfill: inferir `year_month` de transacciones existentes y crear registros `MonthlyPeriod` con `status = OPEN`.
3. Deploy backend con nuevos endpoints y validaciones.
4. Deploy frontend con nuevos badges y modals.
5. Admin puede comenzar a cerrar meses desde UI.
