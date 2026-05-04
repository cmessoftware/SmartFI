## 1. Backend — Validación de periodo en pagos

- [ ] 1.1 En `create_payment()` y `update_payment()`, agregar lógica que compare la fecha del pago con el rango del periodo seleccionado y retorne `period_mismatch: bool` + `suggested_period: str | None`.
- [ ] 1.2 Actualizar respuesta de endpoints de pago en `main.py` para incluir `period_mismatch` y `suggested_period`.

## 2. Frontend — Advertencia de periodo en pagos

- [ ] 2.1 En el componente de registro de pago, capturar `period_mismatch` y mostrar advertencia con el periodo sugerido.
- [ ] 2.2 Permitir al usuario confirmar el periodo actual o cambiar al sugerido.

## 3. Backend — Imputación CSV por fecha de cierre

- [ ] 3.1 En el servicio de importación CSV, para cada ítem buscar el periodo cuyo `billing_date` coincida con la fecha de cierre del ítem.
- [ ] 3.2 Si no hay coincidencia exacta, marcar el ítem como error.

## 4. Backend — Bloqueo de ventana cierre-vencimiento

- [ ] 4.1 Definir función `is_within_period_window(date, period)` que verifica si una fecha está dentro de la ventana válida del periodo.
- [ ] 4.2 En `create_purchase()` e `import_csv()`, invocar la validación de ventana.
- [ ] 4.3 Para rol `user`: rechazar cargas fuera de ventana con mensaje descriptivo.
- [ ] 4.4 Para rol `admin`/`manager`: retornar `outside_window: true` y permitir override con confirmación.

## 5. Backend — Rechazo all-or-nothing de CSV

- [ ] 5.1 En `import_csv()`, ejecutar validación completa de todos los ítems antes de persistir cualquiera.
- [ ] 5.2 Si hay errores, retornar lote rechazado con lista de errores por fila (número de fila, tipo de error, descripción, acción sugerida).
- [ ] 5.3 Solo persistir si todos los ítems pasan validación.

## 6. Frontend — Reporte de errores CSV

- [ ] 6.1 En el componente de importación CSV, mostrar reporte de errores si el backend retorna lote rechazado.
- [ ] 6.2 El reporte debe listar cada fila con error, tipo y descripción.

## 7. Validación

- [ ] 7.1 Verificar: pago dentro de periodo → sin advertencia.
- [ ] 7.2 Verificar: pago fuera de periodo → advertencia con sugerencia.
- [ ] 7.3 Verificar: CSV ítem con fecha de cierre coincidente → imputado al periodo correcto.
- [ ] 7.4 Verificar: CSV ítem sin periodo coincidente → lote rechazado.
- [ ] 7.5 Verificar: carga manual fuera de ventana + rol `user` → bloqueada.
- [ ] 7.6 Verificar: carga fuera de ventana + rol `admin` + override → aceptada.
- [ ] 7.7 Verificar: CSV con un solo ítem inválido → lote completo rechazado, reporte con esa fila.
