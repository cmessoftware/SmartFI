# SmartFi - Simulation Module

## Objective

Enable probabilistic simulation of future financial scenarios for horizons of 6 to 12 months, considering uncertainty in income, expenses, inflation, and external events.

---

# Problem

Deterministic projections generate a single result and do not adequately represent:
- expense variability
- future inflation
- salary changes
- unexpected events

The user needs to:
- visualize possible scenarios
- estimate deficit probabilities
- evaluate impact of financial decisions

---

# Functional Objectives

The module must allow:

- Simulate future financial scenarios
- Estimate probabilities of:
  - deficit
  - meeting savings goals
  - asset growth
- Analyze sensitivity of critical variables
- Compare alternative scenarios

---

# Simulation Horizon

- minimum: 6 months
- maximum: 12 months

---

# Inputs

## Historical Data
- income
- expenses
- debts
- investments

## Configurable Variables
- expected inflation
- salary increase frequency
- increase percentage
- secondary income growth
- expense limits

---

# Scenarios

## Base
Expected normal conditions.

## Optimistic
- lower inflation
- higher income growth
- reduction of variable expenses

## Adverse
- partial income loss
- higher inflation
- unexpected expense increase

---

# Probabilistic Engine

The system must:
- support Monte Carlo simulation
- execute multiple iterations
- generate result distributions

---

# Outputs

## Monthly Projection
- estimated income
- estimated expenses
- estimated savings
- net balance

## Probabilistic Metrics
- probability of deficit
- probability of reaching financial goal
- cashflow volatility

## Percentiles
- p10
- p50
- p90

---

# Visualizations

- projection curves
- confidence bands
- scenario comparison
- asset evolution

---

# Functional Rules

## Inflation
All recurring expenses must be adjusted according to configured inflation.

## Salary Income
Fixed income must be updated according to:
- configured percentage
- configured frequency

---

# Integrations

## Dependencies
- Projection Module
- Expense Module
- Debt Module

---

# Constraints

- Do not execute extremely heavy simulations on frontend
- Limit maximum configurable iterations

---

# Expected KPIs

- expected_savings
- prob_deficit
- projected_networth
- cashflow_volatility

---

# Expected Result

The user must be able to:
- understand future financial risks
- evaluate impact of decisions
- anticipate problems before they occur