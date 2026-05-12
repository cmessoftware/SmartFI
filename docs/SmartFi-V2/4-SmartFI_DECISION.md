# SmartFi - Decision Engine

## Objective

Convert historical financial data and probabilistic projections into concrete and prioritized recommendations to optimize user financial health.

---

# Problem

Financial data without interpretation generates:
- cognitive overload
- difficulty prioritizing
- poor financial decisions

The system must transform:
- metrics
- projections
- simulations

into concrete actions.

---

# Functional Objectives

The module must:
- detect financial risks
- identify improvement opportunities
- recommend prioritized actions
- estimate expected impact of each decision

---

# Inputs

## Financial Data
- income
- expenses
- debt
- investments
- projected cashflow

## Probabilistic Data
- simulations
- probability of deficit
- probability of achieving objectives

---

# Decision Rules

## Insufficient Savings

Condition:
- savings_rate < target

Action:
- recommend reduction of variable expenses

---

## Deficit Risk

Condition:
- prob_deficit > threshold

Action:
- recommend expense reduction
- freeze risky investments

---

## High Debt Levels

Condition:
- debt_to_income > threshold

Action:
- prioritize debt payoff

---

## Insufficient Emergency Fund

Condition:
- emergency_fund_months < minimum

Action:
- prioritize liquidity

---

## Excess Unproductive Liquidity

Condition:
- cash_idle > threshold

Action:
- suggest conservative investment

---

# Prioritization

Recommendations must be ordered by:
- expected financial impact
- risk reduction
- urgency

---

# Types of Recommendations

## Expense Control
- category reduction
- suggested limits

## Debt Management
- prioritized payoff
- refinancing

## Savings
- savings rate increase
- automation

## Investment
- suggested allocation
- risk profile

---

# Outputs

## Recommendations
Prioritized list of actions.

## Expected Impact
Each recommendation must show:
- expected savings
- expected risk reduction
- impact on financial objectives

---

# Financial Objectives

The engine must evaluate:
- probability of achieving USD 3000 monthly
- sustained savings capacity
- financial stability

---

# Integrations

## Dependencies
- Simulation Module
- Projection Module
- Investment Module

---

# Constraints

- Avoid contradictory recommendations
- Avoid actions incompatible with minimum liquidity
- Do not assume unlimited income growth

---

# Expected KPIs

- savings_rate
- debt_to_income
- emergency_fund_months
- projected_financial_health

---

# Expected Result

The user must:
- understand what actions to take
- understand why they should take them
- visualize expected impact on their financial future