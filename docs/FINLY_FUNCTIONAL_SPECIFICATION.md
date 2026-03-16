# Finly — Budget Module Functional Specification

> **⚠️ ESTADO DEL DOCUMENTO:** Este documento describe funcionalidades **PLANIFICADAS (ROADMAP)** para el módulo de Presupuesto.
> 
> **📄 Para ver la implementación ACTUAL del sistema:** Consulte [SISTEMA_ACTUAL.md](SISTEMA_ACTUAL.md)
> 
> **✅ Implementación Actual (Sprint 3):** Módulo de seguimiento de compromisos financieros (préstamos, tarjetas, servicios)  
> **📋 Este Documento (Sprint 4+):** Planificación de flujos de caja proyectados y forecast financiero

---

## Objetivo de Este Documento

Esta especificación define el diseño funcional y conceptual del **módulo de Presupuesto avanzado** para el sistema Finly.  
Está destinado a servir como **contexto de entrada para Copilot** al generar código y componentes relacionados.

**Diferencia con implementación actual:**
- **Actual:** Rastrea compromisos financieros y pagos realizados
- **Roadmap (este doc):** Planificación de flujos de caja futuros con proyección de balances

---

# 1. Conceptual Model

A **BudgetItem** represents an **expected future cash flow**.

It can represent either:

- money that **will be paid** (expense)
- money that **will be received** (income)

Examples:

| Description | Amount | Flow Type |
|---|---|---|
Salary | 2500 | Income |
Rent | 500 | Expense |
Internet | 40 | Expense |
Freelance payment | 200 | Income |

The Budget module therefore supports **financial forecasting** and feeds data to the system dashboards.

---

# 2. BudgetItem Data Model

All budget items are stored in **a single table**.

```text
BudgetItem
-----------
id
description
amount
flow_type
category_id
due_date
estimated
status
linked_expense_id
linked_income_id
source_budget_id
created_at
updated_at

Field description
Field	Description
id	Unique identifier
description	Text description
amount	Monetary value
flow_type	Direction of money flow (Income or Expense)
category_id	Category reference
due_date	Optional expected payment/receipt date
estimated	Boolean indicating forecast estimate
status	Budget status
linked_expense_id	Expense created from this budget item
linked_income_id	Income created from this budget item
source_budget_id	Reference when cloned from another item
created_at	Creation timestamp
updated_at	Update timestamp
3. Cash Flow Type

The direction of the money flow is modeled using an enum.

enum CashFlowType
{
    Income,
    Expense
}

Meaning:

Value	Meaning
Income	Money expected to be received
Expense	Money expected to be paid
4. Budget Status

Budget items can move through several lifecycle states.

enum BudgetStatus
{
    Pending,
    Completed,
    Expired,
    Cancelled
}

Meaning:

Status	Description
Pending	Planned but not yet executed
Completed	Converted into real expense or income
Expired	Past due date and not executed
Cancelled	Manually cancelled

5. Budget Forecast Balance

The system must compute a financial forecast balance.

Definition:

BalanceForecast =
    RealIncomes
    + PendingIncomeBudgets
    - RealExpenses
    - PendingExpenseBudgets

This value represents:

The expected financial balance if all planned budgets occur.

A dashboard widget called Budget Forecast Balance must display this value.

Example:

Concept	Amount
Real incomes	2500
Real expenses	900
Pending income budgets	200
Pending expense budgets	800

Forecast balance:

2500 + 200 - 900 - 800 = 1000

6. Budget Visual Status Indicators

The UI should highlight budget items based on their status.

Condition	Color
Pending and not expired	Gray
Expired and not completed	Red
Completed	Green

Expiration rule:

if due_date < today AND status == Pending
    status = Expired
7. Monthly Budget Cloning

- The Budget module must support cloning budgets to the next month.
- Two operations are required.

7.1 Clone entire monthly budget

The user may clone all budget items to the next month.

Rules:

- new items are created
- due_date moves to next month
- source_budget_id references original item
- status resets to Pending

Date rule:

new_day = min(original_day, last_day_of_next_month)

Example:

31 Jan → 28 Feb
7.2 Move individual items to next month

Users may postpone specific budget items to the next month.

Use cases:

- delayed payment
- postponed purchase
- invoice paid later

Rules:

- selected items are copied to next month
- original item may be marked Cancelled or remain as historical record
- due_date adjusted to next month

8. Budget Import via CSV

The Budget module must reuse the existing bulk CSV import component used for Expenses.

Implementation requirements:

- reuse the same UI component
- create a mapping layer to transform CSV rows into BudgetItem records

Example CSV:

description,amount,flow_type,category,due_date
Rent,500,Expense,Housing,2026-04-05
Salary,2500,Income,Work,2026-04-01

9. Advanced Financial Planning Features

The Budget module must support future financial planning capabilities.

9.1 Automatic monthly planning

Users should be able to generate monthly budgets automatically based on:

- previous months
- recurring patterns
- cloned budgets

9.2 Daily balance projection

The system should be able to compute expected daily balance evolution.

Concept:

daily_balance = current_balance
              + incomes_until_date
              - expenses_until_date
              - pending_budget_until_date

Example output:

Date	Forecast Balance
1	1200
10	900
15	1500
30	800
9.3 Financial alerts

The system should support alerts such as:

- budget expiring soon
- overdue budgets
- forecast balance turning negative

Example rule:

if due_date - today <= 3 days
    trigger alert
9.4 Budget deviation analysis

The system must allow comparison between planned vs real spending.

Formula:

variance = real_amount - budget_amount

Example:

Budget	Actual	Variance
100	120	+20

Positive values indicate overspending.

Summary

The Budget module provides:

- planning of future expenses and incomes
- forecast financial balance
- cloning and postponing budget items

CSV import

- financial alerts
- deviation analysis
- daily balance projections
- monthly financial planning

This design enables Finly to function as a financial planning system, not only a transaction tracker.

---

# ROADMAP DE IMPLEMENTACIÓN

## Fase 1: Migración del Modelo de Datos (Sprint 4.1)

### Tareas Backend:
- [ ] Crear tabla `budget_items` con campos especificados
- [ ] Migrar datos existentes de tabla `debts` a `budget_items`
- [ ] Agregar campos: `flow_type`, `estimated`, `linked_expense_id`, `linked_income_id`, `source_budget_id`
- [ ] Crear enums: `CashFlowType` (Income/Expense), `BudgetStatus` (Pending/Completed/Expired/Cancelled)
- [ ] Actualizar endpoints API para usar nuevo modelo
- [ ] Mantener compatibilidad con endpoints existentes `/api/debts`

### Tareas Frontend:
- [ ] Actualizar DTOs/interfaces TypeScript
- [ ] Modificar componente `DebtManager` → `BudgetPlanner`
- [ ] Agregar selector de tipo de flujo (Ingreso/Gasto)
- [ ] Nueva UI para items estimados vs confirmados

**Estimación:** 3-5 días  
**Criterio de éxito:** Migración sin pérdida de datos, endpoints actuales siguen funcionando

---

## Fase 2: Forecast Balance Dashboard (Sprint 4.2)

### Funcionalidad:
Mostrar balance actual + proyección basada en presupuestos pendientes.

### Implementación:
- [ ] Backend: Endpoint `GET /api/budget/forecast`
  - Calcular: `balance_actual + ingresos_pendientes - gastos_pendientes`
  - Filtrar por fecha (proyección a 30/60/90 días)
- [ ] Frontend: Widget de forecast en Dashboard
  - Card con balance proyectado
  - Gráfico de línea temporal
  - Indicadores de riesgo (rojo si proyección < 0)

### Cálculo:
```python
real_balance = sum(incomes) - sum(expenses)  # Transacciones reales
pending_income_budgets = sum(budget_items where flow_type=Income AND status=Pending)
pending_expense_budgets = sum(budget_items where flow_type=Expense AND status=Pending)

forecast_balance = real_balance + pending_income_budgets - pending_expense_budgets
```

**Estimación:** 2-3 días

---

## Fase 3: Clonación Mensual de Presupuestos (Sprint 4.3)

### Funcionalidad:
Copiar presupuestos mensuales recurrentes (salario, alquiler, servicios).

### Implementación:
- [ ] Backend: Endpoint `POST /api/budget/clone-month`
  - Parámetros: `source_month`, `target_month`
  - Copiar items con `estimated=true` del mes anterior
  - Actualizar `due_date` al nuevo mes
  - Establecer `source_budget_id` apuntando al original
- [ ] Frontend: Botón "Clonar presupuesto del mes anterior"
  - Selector de mes origen/destino
  - Confirmación con preview

**Estimación:** 2 días

---

## Fase 4: Vinculación Automática Presupuesto ↔ Transacciones (Sprint 4.4)

### Funcionalidad:
Al completarse una transacción, marcar item de presupuesto correspondiente como "Completed".

### Implementación:
- [ ] Backend: En `POST /api/transactions`
  - Si existe `linked_budget_id`:
    - Actualizar `budget_item.status = Completed`
    - Establecer `budget_item.linked_expense_id` o `linked_income_id`
  - Auto-match por descripción similar (fuzzy matching)
- [ ] Frontend: Selector de "¿Cumplir item de presupuesto?" al crear transacción

**Estimación:** 3 días

---

## Fase 5: Alertas Financieras (Sprint 4.5)

### Funcionalidad:
Notificaciones cuando:
- Presupuesto cercano a vencimiento (3 días antes)
- Balance proyectado negativo
- Gasto real supera presupuesto planificado

### Implementación:
- [ ] Backend: Job scheduler (APScheduler)
  - Ejecutar diariamente check de alertas
  - Crear tabla `alerts` (id, user_id, type, message, created_at)
- [ ] Backend: Endpoint `GET /api/alerts`
- [ ] Frontend: Badge de notificaciones en Navbar
  - Panel de alertas desplegable

**Estimación:** 4 días

---

## Fase 6: Análisis de Desviación (Sprint 4.6)

### Funcionalidad:
Comparar gasto real vs presupuestado por categoría.

### Implementación:
- [ ] Backend: Endpoint `GET /api/budget/deviation-analysis`
  - Agrupar por categoría
  - Calcular: `real_spent - budgeted`
  - Retornar % de desviación
- [ ] Frontend: Página de análisis
  - Tabla comparativa
  - Gráfico de barras (presupuestado vs real)
  - Indicadores rojos para sobre-presupuesto

**Estimación:** 3 días

---

## Fase 7: Importación CSV de Presupuestos (Sprint 4.7)

### Funcionalidad:
Cargar presupuestos masivamente desde CSV.

### Implementación:
- [ ] Backend: Endpoint `POST /api/budget/import-csv`
  - Validar formato
  - Importar en batch
- [ ] Frontend: Extensión de componente `CSVImport`
  - Plantilla de ejemplo para presupuestos

### Formato CSV:
```csv
description,amount,flow_type,category,due_date,estimated
Salary,2500,Income,Trabajo,2024-04-30,false
Rent,500,Expense,Vivienda,2024-04-05,false
```

**Estimación:** 2 días

---

## Fase 8: Proyección Diaria de Balance (Sprint 4.8)

### Funcionalidad:
Gráfico mostrando balance proyectado día a día para próximos 30 días.

### Implementación:
- [ ] Backend: Endpoint `GET /api/budget/daily-projection`
  - Para cada día: sumar ingresos - gastos con `due_date` <= día
- [ ] Frontend: Gráfico de línea en Dashboard
  - Eje X: Fechas
  - Eje Y: Balance
  - Línea roja en balance=0

**Estimación:** 3 días

---

## Resumen de Prioridades

| Fase | Funcionalidad | Prioridad | Estimación |
|------|--------------|-----------|------------|
| 1 | Migración de modelo de datos | 🔴 Alta | 5 días |
| 2 | Forecast balance dashboard | 🔴 Alta | 3 días |
| 3 | Clonación mensual | 🟡 Media | 2 días |
| 4 | Vinculación auto | 🟡 Media | 3 días |
| 5 | Alertas financieras | 🟢 Baja | 4 días |
| 6 | Análisis de desviación | 🟢 Baja | 3 días |
| 7 | Importación CSV | 🟢 Baja | 2 días |
| 8 | Proyección diaria | 🟡 Media | 3 días |

**Total estimado:** 25 días de desarrollo (~5 semanas)

---

## Notas de Implementación

### Compatibilidad:
- Mantener endpoints actuales `/api/debts` funcionando
- Migración debe ser transparente para usuarios existentes

### Testing:
- Crear datos de prueba para cada fase
- Validar cálculos de forecast en diferentes escenarios

### Documentación:
- Actualizar `SISTEMA_ACTUAL.md` después de cada sprint
- Agregar ejemplos de uso a README.md

---

**Última actualización:** 14 de Marzo de 2026  
**Estado:** 📋 Roadmap - Pendiente de implementación