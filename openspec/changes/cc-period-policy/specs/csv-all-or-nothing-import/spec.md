## ADDED Requirements

### Requirement: Rechazo all-or-nothing de lotes CSV con errores de política
Si cualquier ítem de un CSV importado viola la política del periodo (fuera de ventana, sin periodo coincidente, o sin fecha de cierre), el sistema SHALL rechazar el lote completo y SHALL retornar un reporte con los ítems que fallaron y el motivo de cada error. No se importará ningún ítem del lote.

#### Scenario: CSV con todos los ítems válidos
- **WHEN** se importa un CSV donde todos los ítems cumplen las políticas del periodo
- **THEN** el sistema importa todos los ítems exitosamente

#### Scenario: CSV con al menos un ítem fuera de política
- **WHEN** se importa un CSV donde al menos un ítem viola alguna política del periodo
- **THEN** el sistema rechaza el lote completo, no importa ningún ítem, y retorna reporte de errores con fila, tipo de error y descripción

#### Scenario: Reporte de errores contiene información accionable
- **WHEN** el lote CSV es rechazado por errores de política
- **THEN** el reporte SHALL incluir por cada ítem con error: número de fila, descripción del ítem, tipo de error (fuera de ventana / sin periodo / sin fecha) y la acción sugerida
