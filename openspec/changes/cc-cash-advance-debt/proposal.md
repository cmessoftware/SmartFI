## Why

Hoy las extracciones de efectivo con tarjeta de crédito no tienen tratamiento contable completo en un solo flujo. Deben impactar como gasto del período actual de tarjeta y, además, generar deuda en el módulo DEBTS para el período siguiente, incluyendo la comisión de extracción.

Esto provoca subregistro de obligaciones futuras, diferencias entre módulos y cálculos incompletos del próximo resumen.

## What Changes

- Incorporar el tipo de compra Extracción de Efectivo en la carga manual y CSV del módulo de tarjeta.
- Hacer obligatorio el campo de comisión cuando el tipo sea Extracción de Efectivo.
- Registrar la extracción como gasto del período actual de tarjeta.
- Generar automáticamente una deuda en DEBTS para el período siguiente, por monto extraído + comisión.
- Persistir trazabilidad entre compra de tarjeta y deuda generada para evitar duplicaciones y facilitar auditoría.

## Capabilities

### New Capabilities
- cash-advance-dual-recording: doble imputación de extracción (gasto actual + deuda siguiente).
- cash-advance-fee-validation: validación obligatoria de comisión para extracciones.
- cash-advance-debt-linking: vínculo trazable entre purchase_id y debt_id.

### Modified Capabilities
- credit-card-manual-purchase-flow: incorpora selector de tipo extracción y comisión.
- credit-card-csv-import-flow: clasifica extracciones y aplica la misma regla de doble impacto.

## Impact

- Backend: backend/services/credit_card_service.py, backend/services/debt_service.py, backend/main.py.
- Frontend: frontend/src/components del módulo de tarjeta y formulario Nueva Compra/importación CSV.
- Data: extensión de modelo de compras de tarjeta para tipo de movimiento, comisión y referencias de deuda derivada.
- Validación: reglas transaccionales para garantizar atomicidad (si falla la deuda, no persiste la compra como extracción).