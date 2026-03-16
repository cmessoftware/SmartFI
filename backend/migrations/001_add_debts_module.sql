-- Migración: Agregar módulo de gestión de deudas
-- Fecha: 2026-03-11

-- 1. Crear tipo enum para estado de deuda
DO $$ BEGIN
    CREATE TYPE debt_status AS ENUM ('Pendiente', 'Pagada', 'Vencida');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Crear tabla debts
CREATE TABLE IF NOT EXISTS debts (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    monto_total FLOAT NOT NULL,
    monto_pagado FLOAT DEFAULT 0,
    detalle TEXT,
    fecha_vencimiento DATE,
    status VARCHAR(20) DEFAULT 'Pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Agregar columna debt_id a transactions (si no existe)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'transactions' AND column_name = 'debt_id'
    ) THEN
        ALTER TABLE transactions ADD COLUMN debt_id INTEGER REFERENCES debts(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 4. Crear índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_transactions_debt_id ON transactions(debt_id);
CREATE INDEX IF NOT EXISTS idx_debts_status ON debts(status);
CREATE INDEX IF NOT EXISTS idx_debts_fecha ON debts(fecha);

-- 5. Verificación
SELECT 
    'Migración completada exitosamente. Tablas creadas:' as mensaje,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'debts') as tabla_debts,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'transactions' AND column_name = 'debt_id') as columna_debt_id;
