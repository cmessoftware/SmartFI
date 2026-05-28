## MODIFIED Requirements

### Requirement: Comision de extraccion en porcentaje
Cuando el movimiento sea `cash_advance`, el sistema SHALL interpretar `cash_advance_fee` como porcentaje y no como importe fijo.

#### Scenario: Validacion del porcentaje
- **WHEN** el usuario registra una extraccion
- **THEN** `cash_advance_fee` debe ser mayor a 0
- **AND** `cash_advance_fee` debe ser menor o igual a 100

### Requirement: Gasto total de extraccion incluye comision
El sistema SHALL registrar en modulo Gastos una transaccion espejo de extraccion con monto total igual a `monto_extraccion + comision_calculada`.

#### Scenario: Registro de gasto espejo
- **WHEN** se crea o actualiza una extraccion con `movement_type=cash_advance`
- **THEN** el monto en Gastos es la suma de extraccion y comision
- **AND** el detalle de la transaccion identifica el porcentaje aplicado

### Requirement: Deuda derivada usa monto monetario de comision
El sistema SHALL crear o actualizar la deuda derivada del proximo periodo con el monto de comision calculado en ARS.

#### Scenario: Deuda derivada
- **WHEN** se procesa una extraccion
- **THEN** la deuda derivada se guarda con `monto_total = fee_amount`
- **AND** mantiene la fecha de vencimiento en el siguiente periodo de tarjeta
