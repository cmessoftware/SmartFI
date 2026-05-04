## ADDED Requirements

### Requirement: Reasignación de periodo al editar fecha de compra
Al editar la fecha de una compra standalone, el sistema SHALL recalcular el `billing_date` y determinar si la compra debe moverse a un periodo diferente. Si hay cambio de periodo, el endpoint SHALL retornar `period_changed: true` y el nombre del nuevo periodo en `new_period`. El frontend SHALL mostrar un modal de confirmación indicando el periodo destino antes de persistir el cambio.

#### Scenario: Edición de fecha sin cambio de periodo
- **WHEN** el usuario edita la fecha de una compra y el nuevo `billing_date` calculado cae en el mismo periodo que el actual
- **THEN** el sistema guarda el cambio sin mostrar confirmación adicional y retorna `period_changed: false`

#### Scenario: Edición de fecha con cambio de periodo — usuario confirma
- **WHEN** el usuario edita la fecha de una compra, el nuevo `billing_date` cae en un periodo diferente, y el usuario confirma en el modal
- **THEN** el sistema persiste el cambio y la compra queda imputada en el nuevo periodo

#### Scenario: Edición de fecha con cambio de periodo — usuario cancela
- **WHEN** el usuario edita la fecha de una compra, el nuevo `billing_date` cae en un periodo diferente, y el usuario cancela en el modal
- **THEN** el sistema NO persiste ningún cambio y la compra permanece en el periodo original

#### Scenario: Compra en cuotas — edición de fecha
- **WHEN** el usuario edita la fecha de una compra que tiene cuotas (installment plan)
- **THEN** el sistema aplica solo la actualización de fecha sin reasignación de periodo (out of scope para esta iteración)

### Requirement: Refresco del Cronograma de Cuotas al editar fecha de compra en cuotas
Al guardar exitosamente la edición de la fecha de una compra con plan de cuotas, el frontend SHALL refrescar el panel de Cronograma de Cuotas para reflejar las nuevas fechas de vencimiento calculadas.

#### Scenario: Edición de fecha en compra con cuotas — cronograma se actualiza
- **WHEN** el usuario edita la fecha de una compra que tiene un plan de cuotas y guarda
- **THEN** el panel Cronograma de Cuotas muestra las fechas de vencimiento actualizadas sin necesidad de recargar la página

#### Scenario: Edición de fecha en compra sin cuotas — cronograma no aplica
- **WHEN** el usuario edita la fecha de una compra standalone (sin plan de cuotas)
- **THEN** el panel Cronograma de Cuotas no se ve afectado

### Requirement: Refresco del header al editar moneda de compra
Al guardar exitosamente la edición de la moneda de una compra (ARS→USD o USD→ARS), el frontend SHALL disparar un refresco del resumen de la tarjeta para actualizar el header "Total Pendiente".

#### Scenario: Cambio de moneda ARS a USD
- **WHEN** el usuario cambia la moneda de una compra de ARS a USD y guarda
- **THEN** tras la respuesta 200 del backend, el frontend refresca el endpoint `GET /api/credit-cards/{card_id}/summary` y el header muestra el nuevo Total Pendiente sin necesidad de recargar la página

#### Scenario: Cambio de moneda USD a ARS
- **WHEN** el usuario cambia la moneda de una compra de USD a ARS y guarda
- **THEN** tras la respuesta 200 del backend, el frontend refresca el resumen y el header muestra el Total Pendiente actualizado

#### Scenario: Edición sin cambio de moneda
- **WHEN** el usuario guarda una edición que no cambia la moneda
- **THEN** el frontend no dispara un refresco adicional del summary (comportamiento existente se mantiene)
