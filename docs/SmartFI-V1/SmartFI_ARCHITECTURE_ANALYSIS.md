🔷 1) System Context

You are analyzing part of the SmartFi system.

SmartFi is a personal finance app that handles:
- Transactions (expenses/income)
- Budgets
- Debts (loans, credit cards)
- Automatic statuses (PENDING, PARTIAL, PAID, OVERDUE)
- Users Admin

Key Rules:
- Transactions can be linked to budgets/debts
- The paid amount is calculated automatically from transactions
- Status depends on amount_paid and due_date
- Google Sheets synchronization exists


🔷 2) Specific Functional Context

- ADMIN MODULE: SmartFI_ADMIN_MODULE.md
- BUDGET MODULE: SmartFI_BUDGET_EXPENSE_CREDIT_CART_INTEGRATION
- CREDIT CARD MODULE: SmartFI_CREDIT_CARD_MODULE.md
- EXPRENSES MODULE: SmartFI_EXPENSES_MODULES.md
- SECURITY MODULE: SmartFI_SECURITY_MODULE_INIT.md

🔷 3) Request
Analyze thr referece code for each module as if you were a senior architect.

I want you to identify:

1. Logic errors or inconsistencies
2. Design or coupling problems
3. Data risks (duplicates, inconsistencies, corruption)
4. Unaccounted edge cases
5. Performance issues (if applicable)
6. Real-world scenario problems (e.g: synchronization, concurrency)

Additionally:
- Propose concrete improvements
- If applicable, suggest refactoring
- Indicate impact on other parts of the system
