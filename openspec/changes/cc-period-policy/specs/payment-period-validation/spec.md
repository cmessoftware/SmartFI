## ADDED Requirements

### Requirement: Validación de periodo en registro de pago
Al registrar o editar un pago, el sistema SHALL verificar que la fecha del pago corresponde al periodo seleccionado. Si no corresponde, SHALL retornar una advertencia con el periodo sugerido. El usuario DEBE poder confirmar el periodo sugerido o mantener el seleccionado.

#### Scenario: Pago con fecha dentro del periodo seleccionado
- **WHEN** el usuario registra un pago con fecha dentro del rango del periodo seleccionado
- **THEN** el sistema guarda el pago sin advertencias

#### Scenario: Pago con fecha fuera del periodo seleccionado
- **WHEN** el usuario registra un pago con fecha que no corresponde al periodo seleccionado
- **THEN** el sistema retorna advertencia con el periodo correcto sugerido y el usuario puede confirmar o corregir

#### Scenario: Pago confirmado en periodo incorrecto
- **WHEN** el usuario confirma explícitamente el pago en un periodo que no coincide con la fecha
- **THEN** el sistema persiste el pago en el periodo confirmado por el usuario
