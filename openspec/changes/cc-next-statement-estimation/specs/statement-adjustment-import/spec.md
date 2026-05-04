## ADDED Requirements

### Requirement: El CSV del banco importa solo ajustes adicionales
Al importar el CSV del banco, el sistema SHALL usar las líneas del extracto únicamente para registrar ajustes adicionales no modelados previamente, como intereses, impuestos, retenciones, percepciones o punitorios.

#### Scenario: CSV con ajustes adicionales
- **WHEN** el usuario importa un CSV que contiene intereses e impuestos además de pagos ya registrados
- **THEN** el sistema registra los ajustes adicionales y no duplica los pagos ya proyectados

### Requirement: El sistema no duplica pagos ya proyectados
Si el CSV contiene líneas negativas equivalentes a pagos ya registrados y proyectados por el sistema, el importador SHALL reconocerlas como conciliadas y SHALL evitar crear un movimiento adicional.

#### Scenario: CSV contiene `SU PAGO EN PESOS` ya proyectado
- **WHEN** el usuario importa un CSV con una línea `SU PAGO EN PESOS 600-` que corresponde a un pago ya registrado
- **THEN** el sistema no crea un segundo movimiento por `-600` y marca esa línea como representada por una proyección existente

#### Scenario: CSV contiene pago negativo sin equivalente previo
- **WHEN** el usuario importa un CSV con una línea negativa que no tiene correlato en pagos registrados
- **THEN** el sistema informa que la línea requiere revisión o conciliación manual antes de incorporarla