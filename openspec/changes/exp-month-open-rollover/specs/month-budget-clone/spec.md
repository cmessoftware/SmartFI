## ADDED Requirements

### Req-1: Clonación automática de ítems de presupuesto al abrir mes

Al abrir un nuevo mes, el sistema DEBE clonar todos los ítems de presupuesto del mes anterior.

#### Scenario: Clonación exitosa de ítems de presupuesto

**WHEN** se abre un nuevo mes y el mes anterior tiene ítems de presupuesto

**THEN** el sistema crea copias de cada ítem en el nuevo mes con `cloned_from_item_id = prior_item.id`, `base_cloned = prior_item.amount`, `version_source_month = prior_month`, y `amount = prior_item.amount` (editable)

---

#### Scenario: Apertura de mes sin ítems de presupuesto en el anterior

**WHEN** se abre un nuevo mes y el mes anterior no tiene ítems de presupuesto

**THEN** el sistema crea el mes sin ítems de presupuesto y no genera error (el clonado es vacío)

---

### Req-2: Ítems clonados son completamente editables

**WHEN** un usuario modifica el `amount` de un ítem de presupuesto clonado en el nuevo mes

**THEN** el campo `amount` se actualiza correctamente y `base_cloned` conserva el valor original, permitiendo calcular `adjustment_delta = amount - base_cloned`

---

### Req-3: Trazabilidad de linaje de ítems

**WHEN** se invoca `GET /budget-items/{item_id}/clone-lineage`

**THEN** el sistema retorna la cadena de ítems clonados hacia atrás en el tiempo, mostrando `month`, `item_id`, `amount`, y `description` de cada versión del ítem

---

### Req-4: Consulta de ítems con info de clonación

**WHEN** se invoca `GET /months/{year_month}/budget-items?include_clone_info=true`

**THEN** cada ítem incluye `base_cloned`, `adjustment_delta` (calculado), `cloned_from_item_id`, y `version_source_month`

---

### Req-5: Ajuste de fechas de vencimiento al clonar

**WHEN** se clona un ítem de presupuesto que tiene `fecha_vencimiento`

**THEN** la `fecha_vencimiento` del ítem clonado se ajusta al mes de destino manteniendo el mismo día del mes (o último día del mes si el día no existe en el mes destino)
