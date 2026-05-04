## ADDED Requirements

### Requirement: Pago registrado se proyecta en el período siguiente como movimiento negativo
Cuando el usuario registra un pago del resumen actual, el sistema SHALL generar automáticamente un movimiento proyectado en el período siguiente con importe negativo y semántica bancaria equivalente a `SU PAGO EN PESOS`.

#### Scenario: Registro de pago genera proyección negativa
- **WHEN** el usuario registra un pago por $600 en el período actual
- **THEN** el período siguiente incluye un movimiento proyectado por `-600` identificado como pago aplicado

#### Scenario: Múltiples pagos generan múltiples proyecciones
- **WHEN** el usuario registra dos pagos distintos en el período actual
- **THEN** el período siguiente incluye ambos movimientos negativos proyectados por separado

### Requirement: La estimación del próximo resumen usa pagos proyectados
La estimación del próximo resumen SHALL incluir saldo anterior, pagos proyectados del período actual y cargos del período actual o siguiente según corresponda a la política de la tarjeta.

#### Scenario: Estimación con saldo anterior y pagos registrados
- **WHEN** el período anterior tiene saldo $1000 y el usuario registra pagos por $600 y $100
- **THEN** la estimación del período siguiente refleja saldo arrastrado neto de $300 antes de agregar intereses o cargos adicionales

#### Scenario: Estimación sin CSV bancario
- **WHEN** aún no se importó el extracto del banco
- **THEN** el sistema igualmente muestra la estimación del próximo resumen con base en movimientos ya registrados internamente