# Proposal: Arrastre de Balance Neto entre meses

## Why

Al abrir un nuevo mes, el balance neto del mes anterior (ingresos − gastos) debería poder propagarse como información visible para el usuario. Esto permite:

1. Saber si se empezó el mes con superávit o déficit del período anterior.
2. Tener un indicador de "saldo inicial efectivo" que complemente el presupuesto clonado.
3. Base para futuras proyecciones de flujo de caja entre períodos.

> **Nota de diseño**: El carryover como *transacción automática* (INGRESO/GASTO de tipo CARRYOVER) fue descartado (EXP-FEAT-013 correction) porque distorsionaba los reportes del mes nuevo. Esta feature propone en cambio mostrar el balance neto como **dato informativo**, sin crear transacciones automáticas. La decisión de registrar una transacción queda en manos del usuario.

## What Changes

- Exponer el balance neto del mes anterior en el header del mes en la UI (badge o tooltip).
- Agregar campo `prior_balance` en la respuesta de `GET /api/months/{year_month}/status`.
- Opcionalmente, al abrir un mes, permitir que el usuario cree manualmente una transacción "Saldo anterior" con el monto calculado (acción explícita, no automática).

## Capabilities

### Nueva: `month-balance-display`
- `GET /api/months/{year_month}/balance` devuelve `{ prior_month, net_balance, total_income, total_expenses }` del mes anterior cerrado.
- Frontend muestra el balance en el header del mes con formato `Saldo anterior: $X.XX` (verde si positivo, rojo si negativo).
- Badge o sección en `OpenMonthModal` con el dato informativo del saldo anterior.

### Opcional interactiva: `manual-carryover-transaction`
- Botón "Registrar saldo anterior" en el modal o en la vista de mes que crea una transacción INGRESO/GASTO con categoría "Saldo Anterior" — acción 100% manual y opcional.

## Impact

- **Backend**: endpoint `GET /api/months/{year_month}/balance` (ya existe parcialmente en `calculate_month_balance()`).
- **Frontend**: header del mes, `OpenMonthModal`, posible botón de acción manual.
- **No requiere migración**: usa snapshots existentes de `monthly_period_snapshots`.
- **Independiente de**: EXP-FEAT-016 y EXP-FEAT-017.
