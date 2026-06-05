## ADDED Requirements

### Requirement: Debt records como fuente de verdad DBT
El sistema SHALL usar `debt-records` como fuente de verdad para deudas bancarias y no bancarias que no pertenecen al modulo de tarjeta de credito.

#### Scenario: Alta de deuda no tarjeta
- **WHEN** el usuario crea una deuda no tarjeta
- **THEN** la deuda se persiste en `debt-records`
- **AND** el modulo de presupuesto consume una proyeccion derivada, no la entidad canonica

### Requirement: Proyeccion mensual a presupuesto por cuota
El sistema SHALL crear y mantener una proyeccion mensual en presupuesto con cuota vigente `X/Y` por mes calendario.

#### Scenario: Generacion de proyeccion inicial
- **WHEN** se registra una deuda con plan de cuotas
- **THEN** el sistema crea items de presupuesto para los meses necesarios
- **AND** cada item identifica numero de cuota actual y total de cuotas

#### Scenario: Recalculo idempotente
- **WHEN** el sistema reprocesa una deuda ya proyectada
- **THEN** no crea duplicados
- **AND** actualiza solo los items que cambiaron

### Requirement: Reconciliacion de pagos desde presupuesto
El sistema SHALL reconciliar cada pago registrado contra item asociado para actualizar el saldo pendiente de la deuda canonica.

#### Scenario: Pago parcial o total
- **WHEN** el usuario registra un pago asociado a deuda DBT
- **THEN** `outstanding_amount` se actualiza en `debt-records`
- **AND** el estado de deuda se recalcula segun saldo resultante

### Requirement: Cuotas fraccionarias con dos decimales
El sistema SHALL manejar cuotas pendientes fraccionarias con precision de 2 decimales.

#### Scenario: Redondeo funcional
- **WHEN** el resultado de cuotas pendientes tenga mas de 2 decimales
- **THEN** el sistema redondea con regla comercial a 2 decimales
- **AND** el mismo valor se usa en persistencia funcional y visualizacion

### Requirement: Analitica de deuda por fuente y tendencia mensual
El sistema SHALL mostrar analitica de deuda por fuente y tendencia mensual para el modulo DBT.

#### Scenario: Torta de deuda historica por fuente
- **WHEN** el usuario abre el encabezado del modulo de deudas
- **THEN** visualiza un grafico de torta con total historico agrupado por fuente

#### Scenario: Torta de deuda del mes actual por fuente
- **WHEN** el usuario filtra o visualiza el mes actual
- **THEN** visualiza un grafico de torta del mes actual agrupado por fuente

#### Scenario: Variacion mensual 12 meses
- **WHEN** el usuario visualiza tendencia temporal
- **THEN** visualiza un grafico de barras con linea de tendencia
- **AND** la ventana incluye 12 meses centrados en el mes actual
