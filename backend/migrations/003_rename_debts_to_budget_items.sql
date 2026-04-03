-- Migration 003: Rename debts table to budget_items
-- Date: 2026-03-26
-- Purpose: Improve semantic clarity - "budget items" is more accurate than "debts"

-- Step 1: Rename the table
ALTER TABLE debts RENAME TO budget_items;

-- Step 2: Rename the sequences
ALTER SEQUENCE debts_id_seq RENAME TO budget_items_id_seq;

-- Step 3: Rename indexes (if any exist with "debts" in the name)
-- Note: PostgreSQL automatically renames some indexes, but custom ones may need manual rename

-- Step 4: Update foreign key constraints in other tables
-- installment_plans has debt_id → now references budget_items
-- (The foreign key constraint automatically updates when table is renamed)

-- Verification queries (run these to check):
-- SELECT * FROM budget_items LIMIT 5;
-- SELECT table_name FROM information_schema.tables WHERE table_name = 'budget_items';
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'budget_items';

-- IMPORTANT: This migration is backward-compatible at the database level
-- The API will maintain /api/debts as an alias to /api/budget-items
