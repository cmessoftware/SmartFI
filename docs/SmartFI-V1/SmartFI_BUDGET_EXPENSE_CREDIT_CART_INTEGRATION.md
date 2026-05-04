# Spec: Finanzas familiares — Budget + Credit Card + Expense Integration (SmartFi)

## 1. Objetivo

Evolucionar el sistema actual para:

* Separar **presupuesto**, **gasto** y **deuda**.
* Convertir el módulo de tarjeta en un **motor financiero en tiempo real**.
* Incorporar **proyecciones de cierre** y **control de límite de crédito**.
* Exponer métricas operativas en un **dashboard unificado**.

---

## 2. Principios de diseño

1. Un gasto no es deuda.
2. Un gasto con crédito genera deuda.
3. El presupuesto es intención, no ejecución.
4. La tarjeta es un sistema de diferimiento, no un gasto directo.
5. Toda proyección debe ser reproducible y auditable.

---

## 3. Modelo de datos (extensión)

### 3.1 Budget (sin cambios estructurales, pero uso corregido)

```csharp
class BudgetItem
{
    Guid Id;
    decimal AmountPlanned;
    string Category;
    bool IsFixed;
}
```

Restricción:

* NO incluir deuda dentro de Budget.

---

### 3.2 Transaction (agregar semántica)

```csharp
enum TransactionType
{
    Expense,
    Income,
    Transfer
}

enum PaymentMethodType
{
    Cash,
    Debit,
    Credit
}

class Transaction
{
    Guid Id;
    decimal Amount;
    DateTime Date;
    string Category;

    TransactionType Type;
    PaymentMethodType PaymentMethod;

    Guid? BudgetItemId;
    Guid? CreditCardId;
}
```

Regla:

* Si PaymentMethod = Credit → generar registro en CreditCardTransaction.

---

### 3.3 Credit Card

```csharp
class CreditCard
{
    Guid Id;
    string Name;
    decimal CreditLimit;
    decimal AlertThreshold; // ej: 0.8 (80%)
    DateTime ClosingDate;
    DateTime DueDate;
}
```

---

### 3.4 Consumo en curso (clave)

```csharp
class CreditCardTransaction
{
    Guid Id;
    Guid CreditCardId;

    decimal Amount;
    string Currency; // ARS / USD

    DateTime Date;
    bool IsPostedToStatement;

    Guid? InstallmentPlanId;
}
```

---

### 3.5 Resumen (snapshot)

```csharp
class CreditCardStatement
{
    Guid Id;
    Guid CreditCardId;

    DateTime PeriodStart;
    DateTime PeriodEnd;

    decimal TotalAmount;
    decimal MinimumPayment;

    bool IsPaid;
}
```

---

### 3.6 Cuotas

```csharp
class InstallmentPlan
{
    Guid Id;
    decimal TotalAmount;
    int Installments;
    decimal InstallmentAmount;

    List<DateTime> DueDates;
}
```

---

### 3.7 Cargos e intereses

```csharp
class CreditCardChargeRule
{
    Guid Id;
    string Type; // insurance, fee, tax
    decimal? FixedAmount;
    decimal? Percentage;
}
```

---

## 4. Motor de cálculo

### 4.1 Consumo período abierto

```csharp
currentSpent =
  Sum(CreditCardTransactions where IsPostedToStatement == false)
```

---

### 4.2 Cuotas del período

```csharp
installmentsImpact =
  Sum(InstallmentPlans where DueDate in current_period)
```

---

### 4.3 Intereses estimados

SUPOSICION - INFERENCIA NO VERIFICADA

```csharp
interest =
  outstanding_balance * monthly_rate * (days / 30)
```

---

### 4.4 Cargos

```csharp
charges =
  Sum(FixedAmount + Percentage * base_amount)
```

---

### 4.5 Proyección de cierre

```csharp
projectedStatement =
  currentSpent + installmentsImpact + interest + charges
```

---

### 4.6 Uso del límite

```csharp
usage =
  (currentSpent + pending_statement) / credit_limit
```

---

### 4.7 Balance global

```csharp
cashFlow = ingresos - gastos_efectivo
netPosition = cashFlow - deuda_pendiente
```

---

## 5. Integración con gastos

Reglas:

1. Transaction con PaymentMethod = Credit:

   * crea CreditCardTransaction
   * NO impacta cash inmediatamente

2. Pago de tarjeta:

   * Transaction tipo Expense
   * reduce deuda

3. Transferencias:

   * TransactionType = Transfer
   * no impacta balance

---

## 6. Dashboard (nuevo módulo)

### 6.1 Secciones

#### A. Estado general

* Balance actual
* Flujo mensual
* Deuda total

---

#### B. Tarjetas de crédito

Por cada tarjeta:

* Límite total
* Uso actual (%)
* Consumo período abierto
* Resumen pendiente
* Proyección próximo cierre
* Fecha de cierre / vencimiento

---

#### C. Alertas

* Uso ≥ threshold
* Proyección > capacidad de pago
* Crecimiento de deuda

---

#### D. Indicadores

* % gasto financiado con crédito:

```csharp
credit_ratio = gastos_credito / gastos_totales
```

* deuda / ingreso
* desvío presupuesto

---

## 7. UI — módulo tarjeta

Agregar:

* Campo CreditLimit editable
* Campo AlertThreshold configurable
* Vista:

```text
Tarjeta X
---------
Límite: $500.000
Uso: 72%

Consumo actual: $120.000
Pendiente: $200.000

Proyección cierre: $350.000
Disponible: $150.000
```

---

## 8. Casos de uso

### Caso 1 — compra con tarjeta

* crea Transaction
* crea CreditCardTransaction
* actualiza currentSpent

---

### Caso 2 — compra en cuotas

* crea InstallmentPlan
* distribuye impacto mensual

---

### Caso 3 — pago parcial

* reduce pending_statement
* genera interés futuro

---

## 9. Endpoints sugeridos (FastAPI)

```python
GET /credit-cards/{id}/position
GET /credit-cards/{id}/projection
GET /dashboard/summary
POST /transactions
POST /credit-card-payments
```

---

## 10. Resultado esperado

* Control en tiempo real del crédito
* Proyección antes del cierre
* Alertas preventivas
* Separación clara entre gasto, deuda y flujo

---

## 11. Criterios de aceptación

* El sistema muestra consumo abierto en tiempo real
* Se calcula proyección por tarjeta
* Se dispara alerta por límite configurable
* El dashboard refleja deuda + flujo + crédito
* Las cuotas impactan correctamente múltiples períodos

---

## 12. Notas

* No mezclar Budget con deuda
* No tratar tarjeta como gasto directo
* Toda proyección debe ser recalculable en runtime

---
