-- Migration 002: Remove partida field (redundant with categoria)
-- Date: 2026-03-18
-- Description: Partida was a duplicate of categoria, removing for simplicity

-- Step 1: Drop the partida column from transactions table
ALTER TABLE transactions DROP COLUMN IF EXISTS partida;

-- Migration complete
-- The partida field was redundant and always copied from categoria
