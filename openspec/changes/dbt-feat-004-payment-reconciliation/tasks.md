## Backend

- [#141] [done] Implementar en `debt_record_service` la reconciliacion de pagos con actualizacion de `outstanding_amount`, `current_installment` y `pending_installments` para pagos parciales/totales.
- [#141] [done] Agregar validaciones de negocio para pagos invalidos (monto <= 0, deuda inexistente, sobrepago).
- [#141] [done] Ajustar recalculo de proyecciones luego de cada pago/delecion de pago manteniendo idempotencia.
- [#141] [done] Agregar/actualizar pruebas backend de reconciliacion de pagos parciales y totales.

## Frontend

- [#142] [done] Extender `debtRecordsAPI` con operaciones de pagos (`getPayments`, `addPayment`, `deletePayment`).
- [#142] [done] Implementar en `DebtManager` accion de registrar pago con modal y validaciones basicas.
- [#142] [done] Refrescar tabla/resumen al registrar pago para reflejar estado de deuda sin recarga manual.

## Testing

- [#141] [done] Validar caso parcial: pago no entero de cuota y actualizacion de `pending_installments`.
- [#141] [done] Validar caso total: cancelacion de deuda y saldo 0.
- [#142] [todo] Verificar flujo UI completo (abrir modal -> registrar pago -> actualizar vista).
- [#141] [in-progress] Documentar evidencia tecnica (comandos + resultados) para cierre de FEAT-004.