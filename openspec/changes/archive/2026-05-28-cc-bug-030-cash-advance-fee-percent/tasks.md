## 1. Modelo de comision en porcentaje

- [x] 1.1 Reinterpretar `cash_advance_fee` como porcentaje en backend.
- [x] 1.2 Validar rango de porcentaje (`> 0` y `<= 100`) para `movement_type=cash_advance`.

## 2. Calculo y persistencia

- [x] 2.1 Calcular monto de comision en ARS (`fee_amount`) desde porcentaje.
- [x] 2.2 Actualizar transaccion espejo de Gastos con `monto_extraccion + fee_amount`.
- [x] 2.3 Mantener deuda derivada del proximo periodo por `fee_amount`.

## 3. UX y validacion

- [x] 3.1 Actualizar label y helper del campo de comision a porcentaje.
- [x] 3.2 Mostrar preview de comision calculada y gasto total.
- [x] 3.3 Verificar flujo create/update sin regresiones para compras normales.

## 4. Documentacion

- [x] 4.1 Corregir entrada de CC-BUG-030 en matriz de bugs del modulo.
- [x] 4.2 Registrar change OpenSpec `cc-bug-030-cash-advance-fee-percent`.
