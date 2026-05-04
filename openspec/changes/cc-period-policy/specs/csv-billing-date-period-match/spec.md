## ADDED Requirements

### Requirement: Imputación de ítems CSV al periodo por fecha de cierre
En la importación CSV, el sistema SHALL imputar cada ítem al periodo cuyo `billing_date` (fecha de cierre) coincide exactamente con la fecha de cierre indicada en el ítem. Si no hay coincidencia, el ítem SHALL marcarse como error.

#### Scenario: Ítem CSV con fecha de cierre coincidente
- **WHEN** se importa un CSV y un ítem tiene fecha de cierre que coincide con el `billing_date` de un periodo existente
- **THEN** el ítem se imputa a ese periodo

#### Scenario: Ítem CSV sin periodo coincidente
- **WHEN** se importa un CSV y un ítem tiene fecha de cierre que no coincide con ningún periodo
- **THEN** el ítem se marca como error y el lote completo es rechazado
