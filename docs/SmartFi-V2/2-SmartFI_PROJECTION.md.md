2. Module: Probabilistic Financial Projection
2.1. Function

- Generate monthly projections of:

  - Income
  - Expenses
  - Net savings
  - Deficit/surplus

For 6–12 months.

2.2. Inputs

  - Transaction history (min. 3 months)
  - Debts and future commitments

- Assumptions:
  - Expected monthly inflation
  - Salary increases (percentage and frequency)
  - Expected growth of variable income

2.3. Processing

- Separation:
  - Fixed expenses (deterministic)
  - Variable expenses (probabilistic)

- Modeling:
  - Simple distributions (normal / triangular)
  - Monte Carlo simulation (N iterations)
  - Inflation adjustment: expense(t)=expense(t−1)*(1+inflation)

3.4. Outputs

- Per month:
  - Expected value (mean)
  - Confidence interval (p10, p50, p90)
  - Probability of: deficit meeting savings goal

- 3.5. KPIs
  - prob_deficit
  - expected_savings
  - cashflow_volatility