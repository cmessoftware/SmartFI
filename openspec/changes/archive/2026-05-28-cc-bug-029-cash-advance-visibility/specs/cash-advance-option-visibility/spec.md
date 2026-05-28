## ADDED Requirements

### Requirement: La opcion de extraccion debe ser visible y accionable en Nueva Compra
El sistema SHALL exponer una accion clara en el formulario de Nueva Compra para que el usuario marque una operacion como extraccion de efectivo.

#### Scenario: Activar extraccion desde la UI
- **WHEN** el usuario abre Nueva Compra
- **THEN** ve una accion explicita para activar "Extraccion de efectivo"
- **AND** al activarla el formulario configura `movement_type = cash_advance`

### Requirement: Reglas de formulario para extraccion en UI
Cuando la extraccion este activa, el sistema SHALL exigir comision positiva y SHALL restringir la operacion a una sola cuota desde el formulario.

#### Scenario: Extraccion activa
- **WHEN** el usuario activa extraccion
- **THEN** el campo de comision aparece como obligatorio
- **AND** la cantidad de cuotas queda fijada en 1

#### Scenario: Operacion normal
- **WHEN** el usuario no activa extraccion
- **THEN** el flujo de compra normal mantiene cuotas configurables
- **AND** el payload mantiene `movement_type = normal`
