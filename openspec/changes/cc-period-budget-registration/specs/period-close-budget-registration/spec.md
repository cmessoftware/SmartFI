## ADDED Requirements

### Requirement: Registro automático de BudgetItem al cerrar periodo
Al cerrar un periodo de tarjeta de crédito, el sistema SHALL crear automáticamente un `BudgetItem` en el mes siguiente al cierre con el monto total del periodo, categoría "Tarjeta de Crédito" y descripción que identifica el periodo y la tarjeta.

#### Scenario: Cierre de periodo exitoso
- **WHEN** el usuario cierra un periodo de tarjeta de crédito
- **THEN** el sistema crea un `BudgetItem` en el mes siguiente con el monto total del periodo, categoría "Tarjeta de Crédito" y descripción "Cierre periodo {nombre_periodo} — {nombre_tarjeta}"

#### Scenario: Cierre de periodo ya cerrado (idempotencia)
- **WHEN** el sistema intenta cerrar un periodo que ya está cerrado
- **THEN** el sistema no crea un `BudgetItem` duplicado y retorna el estado actual del periodo sin error

#### Scenario: El BudgetItem queda en el mes siguiente al cierre
- **WHEN** el periodo cierra en el mes M
- **THEN** el `BudgetItem` creado tiene `month = M+1` y `year` ajustado correctamente (e.g., diciembre → enero del año siguiente)

### Requirement: Corrección de visibilidad de botones en nuevo periodo
Al registrar un gasto de un nuevo periodo, los botones de acción SHALL mostrar el estado correcto sin necesidad de recargar la página.

#### Scenario: Registrar gasto — botones visibles correctamente
- **WHEN** el usuario registra un gasto en un nuevo periodo y la operación es exitosa
- **THEN** los botones de acción del periodo muestran el estado actualizado en la misma sesión (sin reload)
