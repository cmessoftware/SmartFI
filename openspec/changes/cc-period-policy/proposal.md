## Why

El módulo de tarjetas de crédito no valida que los pagos y las cargas manuales/CSV respeten las ventanas temporales de los periodos. Esto genera inconsistencias: pagos registrados fuera del periodo vigente, compras importadas con fecha de cierre que no corresponde al periodo, y cargas que violan la política de cierre-vencimiento sin que el sistema lo detecte.

## What Changes

- Al registrar o editar un pago, el sistema sugerirá el periodo correcto si la fecha de pago no corresponde al periodo seleccionado.
- En la importación CSV, la fecha de cierre de cada ítem debe imputarse al periodo cuyo cierre coincide con esa fecha.
- Las cargas manuales y CSV fuera de la ventana cierre-vencimiento del periodo serán bloqueadas por defecto, con opción de override para roles con permisos.
- Si un CSV contiene ítems fuera de la política del periodo, el lote completo será rechazado con un reporte de errores.

## Capabilities

### New Capabilities

- `payment-period-validation`: Validar que la fecha de pago corresponde al periodo seleccionado; si no, sugerir el periodo correcto y permitir confirmación.
- `csv-billing-date-period-match`: En importación CSV, imputar cada ítem al periodo cuyo cierre coincide con la fecha de cierre del ítem.
- `period-window-enforcement`: Bloquear cargas manuales y CSV fuera de la ventana cierre-vencimiento del periodo activo, con override por rol.
- `csv-all-or-nothing-import`: Si cualquier ítem del CSV viola la política del periodo, rechazar el lote completo con reporte de errores.

### Modified Capabilities

<!-- No hay specs existentes que modificar -->

## Impact

- **Backend** (`backend/services/credit_card_service.py`): lógica de validación de periodos en `create_payment()`, `update_payment()`, `import_csv()`.
- **Backend** (`backend/main.py`): endpoints de pagos e importación CSV.
- **Frontend** (`frontend/src/`): componentes de registro de pago e importación CSV.
- **Base de datos**: posible adición de campo `period_window_start` / `period_window_end` en `CreditCardPeriodConfig`, o uso de campos existentes.
