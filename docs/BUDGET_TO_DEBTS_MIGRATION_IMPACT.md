# Budget → Debts Migration Impact Analysis

**Date:** March 26, 2026  
**Context:** Implementing Credit Card Management Module  

## Executive Summary

The Finly system originally used "budget" terminology but migrated to "debts" as the core database table name. However, significant **semantic duality** remains:

- **Database Layer:** Uses `debts` table and `Debt` model
- **API Layer:** Maintains `/api/budget-items` endpoints (backward compatibility)
- **Frontend:** Uses "presupuesto" (budget) terminology in Spanish UI
- **Business Logic:** `BudgetType` enum for `tipo_presupuesto` column

## Current State

### Database Structure

```sql
CREATE TABLE debts (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    monto_total FLOAT NOT NULL,
    monto_pagado FLOAT DEFAULT 0,
    detalle TEXT,
    fecha_vencimiento DATE,
    status VARCHAR(20) DEFAULT 'Pendiente',
    
    -- Budget Model Refactor (Fase A)
    tipo_presupuesto VARCHAR(20) DEFAULT 'OBLIGATION', -- BudgetType enum
    tipo_flujo VARCHAR(20) DEFAULT 'Gasto',           -- FlowType enum
    monto_ejecutado FLOAT DEFAULT 0.0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### API Layer

**Primary Endpoints (`/api/debts`)**
- `GET /api/debts` - Get all debts
- `POST /api/debts` - Create debt
- `PUT /api/debts/{id}` - Update debt
- `DELETE /api/debts/{id}` - Delete debt

**Alias Endpoints (`/api/budget-items`)** - For backward compatibility
- `GET /api/budget-items` → `/api/debts`
- `POST /api/budget-items` → `/api/debts`
- `PUT /api/budget-items/{id}` → `/api/debts/{id}`
- `DELETE /api/budget-items/{id}` → `/api/debts/{id}`

### Python Models

```python
class BudgetType(str, enum.Enum):
    OBLIGATION = "OBLIGATION"
    VARIABLE = "VARIABLE"

class Debt(Base):
    __tablename__ = "debts"
    
    tipo_presupuesto = Column(SQLEnum(BudgetType), ...)
    tipo_flujo = Column(SQLEnum(FlowType), ...)
    monto_ejecutado = Column(Float, ...)
```

### Frontend Code

**Services (`api.js`)**
```javascript
getDebts: () => api.get('/api/budget-items'),  // Uses budget-items alias
createDebt: (debt) => api.post('/api/budget-items', debt),
```

**Components**
- `DebtManager.jsx` - Manages "Items de Presupuesto"
- `BudgetCSVImport.jsx` - CSV import for budgets
- `filterTipoPresupuesto` - State variable for budget type filtering

**UI Labels**
- Spanish: "presupuesto", "Item de Presupuesto", "Tipo de Presupuesto"
- English (internal): debt, budget item, obligation, variable

## Semantic Confusion Points

### 1. "Debt" vs "Budget Item"

**Current Implementation:** The `debts` table serves DUAL PURPOSE:

1. **Debt Tracking** (Original Intent)
   - Credit card debt
   - Loans
   - Payment obligations

2. **Budget Planning** (Refactor Addition)
   - Planned expenses (`tipo_presupuesto = OBLIGATION`)
   - Variable budget items (`tipo_presupuesto = VARIABLE`)

### 2. Column Naming Inconsistency

| Column | English | Spanish | Semantic Domain |
|--------|---------|---------|-----------------|
| `monto_total` | Total Amount | Monto Total | Debt |
| `monto_pagado` | Paid Amount | Monto Pagado | Debt |
| `tipo_presupuesto` | Budget Type | Tipo de Presupuesto | Budget |
| `monto_ejecutado` | Executed Amount | Monto Ejecutado | Budget |

**Problem:** Mixing debt-focused columns (`monto_pagado`) with budget-focused columns (`monto_ejecutado`).

### 3. Status Field Ambiguity

```python
class DebtStatus(str, enum.Enum):
    PENDIENTE = "PENDIENTE"
    PAGO_PARCIAL = "Pago parcial"
    PAGADA = "PAGADA"
    VENCIDA = "VENCIDA"
```

**For Debts:** "PAGADA" means debt is paid off.  
**For Budget Items:** "PAGADA" means budget item is fully executed.

## Impact on Credit Card Module

### Critical Design Decision

The Credit Card Module introduces NEW concepts:

1. **Credit Card Purchase** - Real consumption (NOT financing)
2. **Installment Plan** - Financing structure
3. **Installment** - Individual payment obligation
4. **Credit Card Statement** - Monthly billing cycle
5. **Credit Card Payment** - Cash outflow to pay statement

### Recommended Approach

**DO NOT overload `debts` table**. Create dedicated tables:

```sql
credit_cards
credit_card_purchases
installment_plans        -- Links purchase to debt
installment_schedule     -- Individual installments
credit_card_statements
credit_card_payments
```

**Relationship with `debts`:**

```
credit_card_purchase (total: $900)
    ↓ (creates)
installment_plan (9 cuotas × $100)
    ↓ (creates)
debt (tipo: "Tarjeta de Crédito", monto_total: $900)
    ↓ (generates)
installment_schedule (9 rows, each $100)
```

### Integration Points

1. **Debt Creation**
   - When `installment_plan` is created → Create `debt` record
   - Set `debt.tipo = "Tarjeta de Crédito"`
   - Set `debt.tipo_presupuesto = OBLIGATION` (required payment)
   - Link `installment_plan.debt_id → debts.id`

2. **Transaction Linking**
   - Purchase transaction → `credit_card_purchases`
   - Payment transaction → `credit_card_payments`
   - Interest transaction → `transactions` (categoria: "Interest")

3. **Budget Impact**
   - Real consumption (purchase) → Affects budget categories
   - Financial costs (interest, fees) → Separate category
   - Installment payment → Does NOT affect budget (cash flow only)

## Recommendations

### Short Term (Credit Card Module)

1. **Create Separate Tables** - Do not extend `debts`
2. **Link via Foreign Key** - `installment_plans.debt_id → debts.id`
3. **Maintain Compatibility** - Keep existing `debts` API unchanged
4. **Clear Naming** - Use "credit_card_debt" vs "budget_item" in code comments

### Medium Term (Post Credit Card)

1. **Rename Table** - Consider `budget_items` instead of `debts`
2. **Separate Concerns** - Split into:
   - `budget_items` - Planning (OBLIGATION/VARIABLE)
   - `debt_obligations` - Tracking (PENDIENTE/PAGADA)
3. **API Versioning** - `/api/v2/budget-items` and `/api/v2/debts`

### Long Term (V2.0 Refactor)

1. **Domain-Driven Design**
   - Budget Bounded Context
   - Debt Bounded Context
   - Credit Card Bounded Context
2. **Clear Separation**
   - Budget = Planning (future allocation)
   - Debt = Obligation (payment tracking)
   - Credit Card = Financing (installment management)

## Migration Checklist for Credit Card Module

- [ ] Create migration `003_create_credit_card_tables.sql`
- [ ] Add models in `database.py` (CreditCard, CreditCardPurchase, etc.)
- [ ] Create `credit_card_service.py` (separate from `debt_service.py`)
- [ ] Add API routes `/api/credit-cards/*`
- [ ] Frontend components (CreditCardManager.jsx, etc.)
- [ ] Update documentation with clear terminology

## Glossary

| Term | Spanish | Database Table | Use Case |
|------|---------|----------------|----------|
| Budget Item | Item de Presupuesto | `debts` (tipo_presupuesto) | Planning expenses/income |
| Debt | Deuda | `debts` | Tracking payment obligations |
| Credit Card Purchase | Compra con Tarjeta | `credit_card_purchases` | Real consumption |
| Installment | Cuota | `installment_schedule` | Monthly payment |
| Installment Plan | Plan de Cuotas | `installment_plans` | Financing structure |
| Credit Card Statement | Estado de Cuenta | `credit_card_statements` | Monthly billing |

---

**Conclusion:** The `debts` table currently serves as both budget planning and debt tracking. The Credit Card Module should create **dedicated tables** and only link to `debts` for installment payment obligations, maintaining clear semantic boundaries.
