## 0. UX — Navegación de períodos en extremos (CC-BUG-010)

- [x] 0.1 Mantener visible la navegación de períodos al llegar a extremos de rango (pasado/futuro) para permitir volver sin recargar.

## 1. Backend — Reasignación de periodo al editar fecha

- [ ] 1.1 En `update_purchase()` (`credit_card_service.py`), después de calcular el nuevo `billing_date`, determinar a qué periodo corresponde y comparar con el periodo actual de la compra.
- [ ] 1.2 Agregar campo `period_changed: bool` y `new_period: str | None` a la respuesta del endpoint `PUT /api/credit-cards/{card_id}/purchases/{purchase_id}` en `main.py`.
- [ ] 1.3 Si `period_changed` es `True`, el servicio debe persistir el cambio de periodo (actualizar el campo correspondiente en la compra).

## 2. Frontend — Confirmación de cambio de periodo

- [ ] 2.1 En el componente de edición de compra, capturar `period_changed` y `new_period` de la respuesta del PUT.
- [ ] 2.2 Si `period_changed` es `True`, mostrar un modal de confirmación indicando el nombre del nuevo periodo antes de cerrar el formulario.
- [ ] 2.3 Si el usuario cancela el modal, revertir el estado del formulario (no cerrar, no actualizar la lista).

## 3. Frontend — Refresco del header al cambiar moneda

- [ ] 3.1 En el handler de guardado de edición de compra, detectar si la moneda cambió respecto al valor original.
- [ ] 3.2 Tras un PUT exitoso con cambio de moneda, llamar al endpoint `GET /api/credit-cards/{card_id}/summary` y actualizar el estado del header.

## 4. Frontend — Refresco del Cronograma de Cuotas (CC-BUG-028)

- [ ] 4.1 En el handler de guardado de edición de compra, detectar si la compra tiene un plan de cuotas asociado.
- [ ] 4.2 Tras un PUT exitoso en una compra con cuotas, disparar un refresco del panel Cronograma de Cuotas.

## 5. Validación

- [ ] 5.1 Verificar escenario: editar fecha dentro del mismo periodo → sin modal, compra permanece en el periodo.
- [ ] 5.2 Verificar escenario: editar fecha a otro periodo → modal aparece con nombre del nuevo periodo, confirmar mueve la compra.
- [ ] 5.3 Verificar escenario: editar fecha a otro periodo → cancelar → compra permanece en periodo original.
- [ ] 5.4 Verificar escenario: cambiar moneda ARS→USD → header Total Pendiente se actualiza sin reload.
- [ ] 5.5 Verificar escenario: cambiar moneda USD→ARS → header Total Pendiente se actualiza sin reload.
- [ ] 5.6 Verificar escenario: editar fecha de compra en cuotas → panel Cronograma muestra fechas actualizadas sin reload.
