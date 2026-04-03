# Credit Card Management Module – Functional Design (Finly)

## 1. Objective

Design a credit card module aligned with the current PostgreSQL schema to:

- Separate **consumption vs financing**
- Track **debt and installments**
- Identify **financial costs (interest, fees, taxes)**
- Integrate with existing tables: `transactions`, `debts`

---

## 2. Existing Data Model (Mapped to English)

### transactions → `transactions` (no change)

| Current | Suggested Meaning |
|--------|------------------|
| id | transaction_id |
| fecha | transaction_date |
| tipo | transaction_type |
| categoria | category |
| monto | amount |
| forma_pago | payment_method |
| detalle | description |
| debt_id | debt_id |

---

### debts → `debts`

| Current | Suggested Meaning |
|--------|------------------|
| id | debt_id |
| fecha | debt_date |
| tipo | debt_type |
| categoria | category |
| monto_total | total_amount |
| monto_pagado | paid_amount |
| fecha_vencimiento | due_date |
| status | debt_status |
| tipo_presupuesto | budget_type |
| tipo_flujo | flow_type |

---

## 3. Required Extensions (New Tables)

### 3.1 credit_cards
credit_cards

id (pk)
user_id (fk → users.id)
card_name
bank_name
closing_day
due_day
currency
created_at

---

### 3.2 credit_card_purchases

Represents real consumption (NOT financing)


credit_card_purchases

id (pk)
transaction_id (fk → transactions.id)
card_id (fk → credit_cards.id)
purchase_date
total_amount
category
description
installments
created_at

---

### 3.3 installment_plans

Represents financing structure


installment_plans

id (pk)
purchase_id (fk → credit_card_purchases.id)
debt_id (fk → debts.id)
total_amount
number_of_installments
interest_rate
start_date
created_at

---

### 3.4 installment_schedule

Represents each installment


installment_schedule

id (pk)
plan_id (fk → installment_plans.id)
installment_number
due_date
principal_amount
interest_amount
total_installment_amount
status (PENDING, PAID)

---

### 3.5 credit_card_statements

Monthly aggregation


credit_card_statements

id (pk)
card_id (fk → credit_cards.id)
period_start
period_end
total_amount
total_interest
total_fees
total_taxes
due_date
created_at

---

### 3.6 credit_card_payments

Represents actual payment (cash flow)


credit_card_payments

id (pk)
transaction_id (fk → transactions.id)
statement_id (fk → credit_card_statements.id)
payment_date
amount_paid
created_at

---

## 4. Business Rules

### 4.1 Purchase (Installments)

- Create:
  - `transaction` (full amount)
  - `credit_card_purchase`
  - `debt`
  - `installment_plan`
  - `installment_schedule`

---

### 4.2 Monthly Processing

- Generate statement:
  - sum of installments due
  - interests
  - fees
  - taxes

---

### 4.3 Payment

- Register:
  - `transaction` (cash outflow)
  - `credit_card_payment`
- Update:
  - `installment_schedule.status`
  - `debts.paid_amount`

---

## 5. Financial Classification

### 5.1 Consumption

- Stored in:
  - `transactions.category`
- Example:
  - Food, Education, Transport

---

### 5.2 Financing

- Stored in:
  - `debts`
  - `installment_schedule`

---

### 5.3 Financial Costs

| Type | Category |
|------|----------|
| Interest | Interest |
| Fees | Fees |
| Insurance | Insurance |
| Taxes | Taxes |

Stored as:

transactions

transaction_type = GASTO
category = Interest / Fees / Taxes

---

## 6. Budget Integration

### Consumption Budget


SUM(transactions.amount WHERE category != financial)


---

### Financial Budget


SUM(interest + fees + taxes)


---

### Debt Tracking


remaining_debt = debts.total_amount - debts.paid_amount


---

## 7. Metrics

### Core


real_consumption
financial_cost
monthly_cash_flow


---

### Risk


debt_ratio = total_debt / income
installment_load = monthly_installments / income
financial_cost_ratio = financial_cost / income


---

## 8. Design Principles

- Consumption is recorded **once**
- Installments are **not expenses**
- Interest is **financial cost**
- Credit card payment is **cash flow**
- Debt is **state, not expense**