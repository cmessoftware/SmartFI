## ADDED Requirements

### Requirement: Paginación de tabla de compras en 5 ítems
La tabla de compras SHALL mostrar 5 ítems por página. El cronograma de cuotas también SHALL paginar de a 5 ítems por página.

#### Scenario: Tabla con más de 5 compras
- **WHEN** el periodo tiene más de 5 compras
- **THEN** la tabla muestra las primeras 5 y los controles de paginación permiten navegar al resto

#### Scenario: Cronograma con más de 5 cuotas
- **WHEN** una compra en cuotas tiene más de 5 ítems en el cronograma
- **THEN** el cronograma muestra las primeras 5 y permite navegar al resto

### Requirement: Ordenamiento por monto en tabla de compras
La tabla de compras SHALL permitir ordenar por monto ascendente y descendente haciendo click en el encabezado de la columna monto.

#### Scenario: Ordenar por monto ascendente
- **WHEN** el usuario hace click en el encabezado "Monto" por primera vez
- **THEN** la tabla muestra las compras ordenadas de menor a mayor monto

#### Scenario: Ordenar por monto descendente
- **WHEN** el usuario hace click en el encabezado "Monto" por segunda vez
- **THEN** la tabla muestra las compras ordenadas de mayor a menor monto

### Requirement: Agrupación visual de cuotas vs. pagos únicos
La tabla de compras SHALL diferenciar visualmente entre compras en cuotas y compras de pago único (standalone).

#### Scenario: Compra en cuotas en la tabla
- **WHEN** una compra tiene un plan de cuotas asociado
- **THEN** la fila muestra un indicador visual (badge, ícono o color) que la identifica como compra en cuotas

#### Scenario: Compra de pago único en la tabla
- **WHEN** una compra es de pago único
- **THEN** la fila muestra indicador de pago único diferente al de cuotas

### Requirement: Tooltip de detalle por compra
Al hacer hover sobre una fila de compra en la tabla, el sistema SHALL mostrar un tooltip con información adicional de la compra (descripción, fecha, cuotas si aplica).

#### Scenario: Hover sobre compra en cuotas
- **WHEN** el usuario hace hover sobre una fila de compra en cuotas
- **THEN** el tooltip muestra: descripción, fecha, número de cuota actual / total de cuotas, monto de la cuota

#### Scenario: Hover sobre compra standalone
- **WHEN** el usuario hace hover sobre una fila de compra única
- **THEN** el tooltip muestra: descripción, fecha, monto, moneda

### Requirement: Ocultar combo tipo de plan cuando no aplica
El combo "tipo de plan" en el formulario de compra SHALL estar oculto o deshabilitado cuando el contexto no requiere selección de plan.

#### Scenario: Formulario sin tipo de plan disponible
- **WHEN** se abre el formulario de compra en un contexto donde no hay planes disponibles o la compra es siempre de un único tipo
- **THEN** el combo tipo de plan no es visible en el formulario

### Requirement: Campo de texto libre detalle en compras
El formulario de compra SHALL incluir un campo de texto libre "Detalle" (máx. 500 caracteres) opcional. El sistema SHALL persistir y mostrar este campo en la tabla y tooltip.

#### Scenario: Crear compra con detalle
- **WHEN** el usuario completa el campo "Detalle" al crear una compra
- **THEN** el campo se persiste en BD y se muestra en la tabla/tooltip

#### Scenario: Crear compra sin detalle
- **WHEN** el usuario deja el campo "Detalle" vacío
- **THEN** la compra se guarda normalmente sin error (campo opcional)
