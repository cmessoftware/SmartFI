## Overview

Este cambio separa explicitamente el dominio de deudas no tarjeta (DBT) del dominio de tarjeta de credito (CC).

- Canonico: `DebtRecord` + `DebtPayment`.
- Proyeccion operativa: `BudgetItem` mensual (cuota vigente).
- Integracion: alta de deuda crea/actualiza proyecciones; pagos en presupuesto reconcilian deuda real.

## Domain Model

### Canonical

- DebtRecord
  - debt_name
  - debt_type
  - creditor/fuente
  - principal_amount
  - outstanding_amount
  - annual_interest_rate
  - start_date, due_date
  - status

- DebtPayment
  - debt_record_id
  - payment_date
  - amount
  - transaction_id (opcional)

### Projection

- BudgetItem mensual por cuota
  - detalle: "{deuda} (cuota X/Y)"
  - monto_total: monto cuota del mes
  - tipo_flujo: Ingreso (segun definicion funcional vigente en documento)
  - campos de trazabilidad a DebtRecord (ID de deuda, cuota actual, total cuotas)

## Reconciliation Rules

1. Pago en presupuesto asociado a DBT actualiza `outstanding_amount`.
2. Cuotas pendientes permiten fraccion con precision de 2 decimales.
3. Formula base:
   - cuotas_pendientes = outstanding_amount / valor_cuota
   - round(cuotas_pendientes, 2)

## Analytics

- Pie 1: total historico de deuda agrupado por fuente.
- Pie 2: total deuda del mes actual agrupado por fuente.
- Serie 12 meses (barras + linea): variacion de deuda mensual centrada en mes actual.

## Non-Goals

- No incluye deudas de tarjeta de credito (CC).
- No crea sub-issues automaticos por tarea en Gitea.
