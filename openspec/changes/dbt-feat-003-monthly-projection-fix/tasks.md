## Backend

- [#139] [done] Confirmar y reforzar en `debt_record_service` la regla `due_date = start_date + 1 mes` cuando `due_date` no se informa.
- [#139] [done] Asegurar que `_projection_installment_count` y `_projection_schedule` creen una proyeccion por cada cuota pendiente.
- [#139] [done] Validar idempotencia en `_upsert_budget_projection` para evitar duplicados y evitar degradacion a una sola fila.
- [#139] [done] Mantener reconciliacion defensiva de proyecciones inconsistentes por `user_id`.
- [#139] [done] Agregar/ajustar pruebas backend para alta, update y projected con 1, 6, 12 cuotas.

## Frontend

- [#140] [done] Verificar mapeo de payload en `api.js` para no forzar `due_date` al mes de origen.
- [#140] [done] Confirmar labels y help-text en alta/edicion: toma de deuda vs primera cuota.
- [#140] [done] Validar en `DebtManager` que la vista por mes no oculte incorrectamente cuotas futuras por mapeo de fecha.
- [#140] [todo] Agregar smoke test manual guiado de alta de deuda de 12 cuotas sin `fecha_vencimiento`.

## Testing

- [#139] [done] Caso real: crear deuda tipo Personal con `start_date` actual y 12 cuotas; verificar 12 `BudgetItem` en DB desde mes siguiente.
- [#140] [todo] Caso UI: navegar de mes M a M+11 y confirmar presencia de cuota proyectada en cada mes.
- [#139] [done] Caso regresion: editar deuda existente inconsistente y verificar reconciliacion completa.
- [#140] [todo] Documentar evidencia (query + capturas + resultado API) en issue Gitea.
