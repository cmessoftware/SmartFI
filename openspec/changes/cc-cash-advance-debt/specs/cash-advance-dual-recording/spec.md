## ADDED Requirements

### Requirement: Registro dual de extracción de efectivo con tarjeta
El sistema SHALL registrar una extracción de efectivo de tarjeta como gasto del período actual y SHALL crear una deuda derivada en DEBTS para el período siguiente de esa tarjeta por el monto extraído más la comisión.

#### Scenario: Extracción válida con comisión
- WHEN el usuario registra una compra de tipo extracción con comisión válida
- THEN el sistema persiste la compra en el período actual y crea deuda derivada en DEBTS del período siguiente por extracción + comisión

#### Scenario: Compra normal
- WHEN el usuario registra una compra de tipo normal
- THEN el sistema persiste la compra sin crear deuda derivada

### Requirement: Comisión obligatoria para extracción
Cuando el tipo de movimiento sea extracción de efectivo, el sistema SHALL exigir una comisión informada y no negativa.

#### Scenario: Extracción sin comisión
- WHEN el usuario intenta registrar extracción sin comisión
- THEN el sistema rechaza la operación con error de validación

#### Scenario: Extracción con comisión negativa
- WHEN el usuario intenta registrar extracción con comisión menor a cero
- THEN el sistema rechaza la operación con error de validación

### Requirement: Trazabilidad e idempotencia de deuda derivada
El sistema SHALL mantener vínculo entre la compra de extracción y la deuda derivada, y SHALL evitar la creación de deudas duplicadas para el mismo origen.

#### Scenario: Reintento de operación
- WHEN la misma extracción se reintenta por timeout o duplicación de envío
- THEN el sistema no crea una segunda deuda derivada para el mismo origen

#### Scenario: Consulta de detalle de extracción
- WHEN se consulta una extracción registrada
- THEN la respuesta incluye referencia a la deuda derivada asociada cuando exista
