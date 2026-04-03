-- ============================================================================
-- ⚠️ ESTE ARCHIVO ESTÁ OBSOLETO - NO USAR
-- ============================================================================
-- Fecha: 2026-03-26
-- Razón: Migrado a Alembic
-- Archivo Alembic equivalente: 
--   alembic/versions/e10c0b8c5dbe_add_credit_card_management_module.py
--
-- Para aplicar esta migración, usar:
--   cd backend
--   alembic upgrade head
-- ============================================================================

-- Migración: Credit Card Management Module
-- Fecha: 2026-03-26
-- Descripción: Tablas para gestión de tarjetas de crédito, compras, cuotas y estados de cuenta

-- ============================================================================
-- 1. CREDIT CARDS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS credit_cards (
    id SERIAL PRIMARY KEY,
    user_id INTEGER, -- Future FK to users table
    card_name VARCHAR(100) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    closing_day INTEGER NOT NULL CHECK (closing_day BETWEEN 1 AND 31),
    due_day INTEGER NOT NULL CHECK (due_day BETWEEN 1 AND 31),
    currency VARCHAR(3) DEFAULT 'USD',
    credit_limit FLOAT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_card_name UNIQUE (card_name)
);

CREATE INDEX IF NOT EXISTS idx_credit_cards_user_id ON credit_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_cards_active ON credit_cards(is_active);

-- ============================================================================
-- 2. CREDIT CARD PURCHASES TABLE
-- ============================================================================
-- Representa el CONSUMO REAL (no es financing)
CREATE TABLE IF NOT EXISTS credit_card_purchases (
    id SERIAL PRIMARY KEY,
    card_id INTEGER NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
    transaction_id INTEGER REFERENCES transactions(id) ON DELETE SET NULL,
    purchase_date DATE NOT NULL,
    total_amount FLOAT NOT NULL CHECK (total_amount > 0),
    category VARCHAR(100) NOT NULL,
    description TEXT,
    installments INTEGER DEFAULT 1 CHECK (installments >= 1),
    has_financing BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_cc_purchases_card_id ON credit_card_purchases(card_id);
CREATE INDEX IF NOT EXISTS idx_cc_purchases_transaction_id ON credit_card_purchases(transaction_id);
CREATE INDEX IF NOT EXISTS idx_cc_purchases_date ON credit_card_purchases(purchase_date);
CREATE INDEX IF NOT EXISTS idx_cc_purchases_category ON credit_card_purchases(category);

-- ============================================================================
-- 3. INSTALLMENT PLANS TABLE
-- ============================================================================
-- Representa la ESTRUCTURA DE FINANCIAMIENTO
CREATE TABLE IF NOT EXISTS installment_plans (
    id SERIAL PRIMARY KEY,
    purchase_id INTEGER NOT NULL REFERENCES credit_card_purchases(id) ON DELETE CASCADE,
    debt_id INTEGER REFERENCES debts(id) ON DELETE SET NULL, -- Link to budget/debt tracking
    total_amount FLOAT NOT NULL CHECK (total_amount > 0),
    number_of_installments INTEGER NOT NULL CHECK (number_of_installments >= 1),
    interest_rate FLOAT DEFAULT 0.0 CHECK (interest_rate >= 0),
    start_date DATE NOT NULL,
    plan_type VARCHAR(50) DEFAULT 'REGULAR', -- REGULAR, PROMOTIONAL, etc.
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_purchase_plan UNIQUE (purchase_id)
);

CREATE INDEX IF NOT EXISTS idx_installment_plans_purchase_id ON installment_plans(purchase_id);
CREATE INDEX IF NOT EXISTS idx_installment_plans_debt_id ON installment_plans(debt_id);

-- ============================================================================
-- 4. INSTALLMENT SCHEDULE TABLE
-- ============================================================================
-- Representa cada CUOTA individual
CREATE TABLE IF NOT EXISTS installment_schedule (
    id SERIAL PRIMARY KEY,
    plan_id INTEGER NOT NULL REFERENCES installment_plans(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL CHECK (installment_number >= 1),
    due_date DATE NOT NULL,
    principal_amount FLOAT NOT NULL CHECK (principal_amount >= 0),
    interest_amount FLOAT DEFAULT 0.0 CHECK (interest_amount >= 0),
    total_installment_amount FLOAT NOT NULL CHECK (total_installment_amount >= 0),
    status VARCHAR(20) DEFAULT 'PENDING',
    paid_date DATE,
    payment_transaction_id INTEGER REFERENCES transactions(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_plan_installment UNIQUE (plan_id, installment_number)
);

CREATE INDEX IF NOT EXISTS idx_installment_schedule_plan_id ON installment_schedule(plan_id);
CREATE INDEX IF NOT EXISTS idx_installment_schedule_due_date ON installment_schedule(due_date);
CREATE INDEX IF NOT EXISTS idx_installment_schedule_status ON installment_schedule(status);

-- ============================================================================
-- 5. CREDIT CARD STATEMENTS TABLE
-- ============================================================================
-- Agregación mensual de cargos
CREATE TABLE IF NOT EXISTS credit_card_statements (
    id SERIAL PRIMARY KEY,
    card_id INTEGER NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    statement_date DATE NOT NULL,
    due_date DATE NOT NULL,
    previous_balance FLOAT DEFAULT 0.0,
    total_purchases FLOAT DEFAULT 0.0,
    total_installments FLOAT DEFAULT 0.0,
    total_interest FLOAT DEFAULT 0.0,
    total_fees FLOAT DEFAULT 0.0,
    total_taxes FLOAT DEFAULT 0.0,
    total_credits FLOAT DEFAULT 0.0,
    total_amount FLOAT NOT NULL,
    minimum_payment FLOAT DEFAULT 0.0,
    paid_amount FLOAT DEFAULT 0.0,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, PARTIALLY_PAID, PAID, OVERDUE
    payment_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_card_period UNIQUE (card_id, period_start, period_end)
);

CREATE INDEX IF NOT EXISTS idx_cc_statements_card_id ON credit_card_statements(card_id);
CREATE INDEX IF NOT EXISTS idx_cc_statements_status ON credit_card_statements(status);
CREATE INDEX IF NOT EXISTS idx_cc_statements_due_date ON credit_card_statements(due_date);

-- ============================================================================
-- 6. CREDIT CARD PAYMENTS TABLE
-- ============================================================================
-- Representa pagos REALES (cash flow)
CREATE TABLE IF NOT EXISTS credit_card_payments (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER REFERENCES transactions(id) ON DELETE SET NULL,
    statement_id INTEGER REFERENCES credit_card_statements(id) ON DELETE SET NULL,
    card_id INTEGER NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    amount_paid FLOAT NOT NULL CHECK (amount_paid > 0),
    payment_method VARCHAR(50) DEFAULT 'Transfer',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_payment_transaction_or_statement 
        CHECK (transaction_id IS NOT NULL OR statement_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_cc_payments_card_id ON credit_card_payments(card_id);
CREATE INDEX IF NOT EXISTS idx_cc_payments_transaction_id ON credit_card_payments(transaction_id);
CREATE INDEX IF NOT EXISTS idx_cc_payments_statement_id ON credit_card_payments(statement_id);
CREATE INDEX IF NOT EXISTS idx_cc_payments_date ON credit_card_payments(payment_date);

-- ============================================================================
-- 7. ENUMS (via CHECK constraints and indexes)
-- ============================================================================

-- Installment status: PENDING, PAID
-- Statement status: PENDING, PARTIALLY_PAID, PAID, OVERDUE
-- Plan type: REGULAR, PROMOTIONAL, ZERO_INTEREST

-- ============================================================================
-- 8. VERIFICATION
-- ============================================================================
SELECT 
    'Credit Card Module Migration Completed' as mensaje,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'credit_cards') as credit_cards,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'credit_card_purchases') as purchases,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'installment_plans') as plans,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'installment_schedule') as schedule,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'credit_card_statements') as statements,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'credit_card_payments') as payments;
