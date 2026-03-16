-- Agregar nuevo valor al enum DebtStatus
ALTER TYPE debtstatus ADD VALUE IF NOT EXISTS 'Pago parcial' AFTER 'PENDIENTE';

-- Verificar valores del enum
SELECT enumlabel FROM pg_enum WHERE enumtypid = 'debtstatus'::regtype ORDER BY enumsortorder;
