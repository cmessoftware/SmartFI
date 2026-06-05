## Context

CC-FEAT-024 requiere un flujo consistente para extracciones de efectivo realizadas con tarjeta de crédito. El comportamiento objetivo es dual:

1. Impactar en el resumen actual de tarjeta como gasto del período.
2. Crear deuda en DEBTS para el período siguiente por el monto extraído más la comisión.

El sistema ya maneja compras de tarjeta, períodos y registro de deuda/presupuesto. Falta modelar explícitamente este tipo de operación con validaciones y trazabilidad entre módulos.

## Goals / Non-Goals

Goals:
- Permitir registrar extracciones de efectivo manual y por CSV.
- Exigir comisión cuando la compra sea extracción.
- Registrar en una transacción atómica compra + deuda derivada.
- Mantener trazabilidad y evitar deuda duplicada ante reintentos.

Non-Goals:
- No rediseñar el módulo completo de DEBTS.
- No cambiar la lógica existente de compras normales ARS/USD fuera de extracción.
- No cubrir conciliación bancaria avanzada en esta iteración.

## Decisions

### D1: Tipo de movimiento explícito en compra

Se agrega clasificación de compra para distinguir extracción de efectivo de una compra normal. Esta clasificación conduce reglas de validación y post-proceso.

### D2: Comisión obligatoria en extracción

Cuando el tipo sea extracción, la comisión es requerida y no negativa. Para compras normales, la comisión permanece en cero.

### D3: Doble impacto con atomicidad

La creación de extracción y deuda derivada sucede en una misma transacción lógica. Si falla la creación de deuda, la extracción no se confirma.

### D4: Deuda derivada en período siguiente

La deuda se registra en DEBTS del período siguiente de esa tarjeta, con importe total = extracción + comisión y referencia al registro origen.

### D5: Idempotencia

Se usa una clave de relación estable (por ejemplo purchase_id y card_period_target) para evitar duplicar deuda derivada si hay reintentos o importaciones repetidas.

## Data Model Changes

- CreditCardPurchase:
  - movement_type: normal | cash_advance
  - cash_advance_fee: decimal >= 0
  - derived_debt_id: FK nullable
- Debt record derivado:
  - source_type: credit_card_cash_advance
  - source_purchase_id: FK a compra de tarjeta

Toda migración de schema debe realizarse con Alembic.

## API/Flow Changes

- POST/PUT compra tarjeta:
  - acepta movement_type y cash_advance_fee.
  - valida comisión cuando movement_type = cash_advance.
  - retorna datos de deuda derivada cuando aplica.
- Importación CSV:
  - mapea tipo extracción según columna/heurística definida.
  - si alguna extracción no trae comisión válida, se rechaza ítem (o lote según política vigente).

## Risks / Trade-offs

- Riesgo de deuda duplicada por reintento: mitigación con idempotencia y unique constraint lógica.
- Riesgo de inconsistencias entre períodos: mitigación reutilizando método único de cálculo de período siguiente.
- Riesgo UX por mayor complejidad en formulario: mitigación con campo comisión visible solo para extracción.

## Migration Plan

1. Actualizar modelos SQLAlchemy.
2. Crear migración Alembic para nuevas columnas y constraints.
3. Implementar servicio backend transaccional para extracción + deuda.
4. Exponer cambios en endpoints y validaciones.
5. Ajustar frontend (manual + CSV).
6. Ejecutar validación funcional con casos de extracción y compras normales.