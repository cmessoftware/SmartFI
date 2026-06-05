## ADDED Requirements

### Requirement: Reconciliacion de pagos en deuda no tarjeta
El sistema SHALL reconciliar cada pago parcial o total contra `debt-records` actualizando saldo pendiente y avance de cuotas.

#### Scenario: Pago parcial
- **WHEN** el usuario registra un pago menor al saldo pendiente
- **THEN** `outstanding_amount` disminuye por el monto pagado
- **AND** `current_installment` y `pending_installments` se actualizan de forma proporcional
- **AND** la deuda permanece activa

#### Scenario: Pago total
- **WHEN** el usuario registra un pago igual al saldo pendiente
- **THEN** `outstanding_amount` pasa a 0
- **AND** la deuda cambia a estado `CANCELADA`
- **AND** `pending_installments` pasa a 0

### Requirement: Sincronizacion de proyecciones tras pago
El sistema SHALL recalcular la proyeccion mensual de presupuesto vinculada a la deuda despues de cada pago.

#### Scenario: Recalculo posterior a pago
- **WHEN** se persiste un pago en una deuda activa
- **THEN** las proyecciones asociadas se actualizan sin duplicados
- **AND** la vista proyectada refleja el nuevo estado de saldo y cuotas

### Requirement: Flujo frontend de registro de pagos DBT
El sistema SHALL permitir registrar pagos desde la vista de Deudas sin salir del modulo.

#### Scenario: Registro desde tabla de deudas
- **WHEN** el usuario abre la accion de pago sobre una deuda
- **THEN** puede informar fecha, monto y comentario
- **AND** al confirmar, la tabla se refresca mostrando saldo/avance actualizado
- **AND** se informa error si el pago es invalido (monto <= 0 o mayor al saldo).