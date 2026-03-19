-- Migración: Separación conceptual OBLIGATION/VARIABLE (Fase A - Compatibilidad)
-- Fecha: 2026-03-18
-- Refactor: Budget Model v2

-- 1. Crear tipo enum para tipo de presupuesto
DO $$ BEGIN
    CREATE TYPE budget_type AS ENUM ('OBLIGATION', 'VARIABLE');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Crear tipo enum para tipo de flujo
DO $$ BEGIN
    CREATE TYPE flow_type AS ENUM ('Gasto', 'Ingreso');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Agregar nuevas columnas a debts
DO $$ 
BEGIN
    -- tipo_presupuesto: distingue obligación vs variable
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'debts' AND column_name = 'tipo_presupuesto'
    ) THEN
        ALTER TABLE debts ADD COLUMN tipo_presupuesto VARCHAR(20) DEFAULT 'OBLIGATION';
    END IF;

    -- tipo_flujo: Gasto o Ingreso (dominio visible)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'debts' AND column_name = 'tipo_flujo'
    ) THEN
        ALTER TABLE debts ADD COLUMN tipo_flujo VARCHAR(20) DEFAULT 'Gasto';
    END IF;

    -- monto_ejecutado: fuente de verdad de ejecución
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'debts' AND column_name = 'monto_ejecutado'
    ) THEN
        ALTER TABLE debts ADD COLUMN monto_ejecutado FLOAT DEFAULT 0.0;
    END IF;
END $$;

-- 4. Backfill inicial: sincronizar monto_ejecutado con monto_pagado en OBLIGATION
UPDATE debts 
SET monto_ejecutado = monto_pagado 
WHERE tipo_presupuesto = 'OBLIGATION' 
  AND monto_ejecutado = 0.0;

-- 5. Crear índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_debts_tipo_presupuesto ON debts(tipo_presupuesto);
CREATE INDEX IF NOT EXISTS idx_debts_tipo_flujo ON debts(tipo_flujo);

-- 6. Agregar columna estado_asignacion a transactions (para futuro)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'transactions' AND column_name = 'estado_asignacion'
    ) THEN
        ALTER TABLE transactions ADD COLUMN estado_asignacion VARCHAR(30) DEFAULT 'ASIGNADA_MANUAL';
    END IF;
END $$;

-- 7. Verificación
SELECT 
    'Migración 002 completada exitosamente. Columnas agregadas:' as mensaje,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'debts' AND column_name = 'tipo_presupuesto') as tipo_presupuesto,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'debts' AND column_name = 'tipo_flujo') as tipo_flujo,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'debts' AND column_name = 'monto_ejecutado') as monto_ejecutado,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'transactions' AND column_name = 'estado_asignacion') as estado_asignacion;
