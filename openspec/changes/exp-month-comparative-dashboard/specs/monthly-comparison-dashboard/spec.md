## ADDED Requirements

### Req-1: Datos comparativos por rango de meses

El sistema DEBE proveer métricas agregadas para un rango de meses en una sola respuesta.

#### Scenario: Consulta de rango válido

**WHEN** se invoca `GET /reports/comparative-months?start_month=2026-01&end_month=2026-04`

**THEN** el sistema retorna un array de objetos con `year_month`, `total_income`, `total_expenses`, `net_balance`, `savings_percentage`, `transaction_count`, `delta_vs_prior`, `delta_percentage`, `deviation_severity`, y `top_categories` (top 3 categorías con amount y %)

---

#### Scenario: Rango con más de 5 años

**WHEN** la diferencia entre `end_month` y `start_month` supera 60 meses

**THEN** el sistema retorna `400` con código `RANGE_TOO_LARGE` y mensaje "Rango máximo permitido es 5 años"

---

#### Scenario: Rango sin datos disponibles

**WHEN** no existen transacciones ni snapshots en el rango solicitado

**THEN** el sistema retorna `404` con código `NO_DATA` y mensaje "No hay datos disponibles para el rango seleccionado"

---

### Req-2: Detección de desviaciones

El sistema DEBE calcular automáticamente si un mes tiene desviación respecto al mes anterior usando un umbral del 20% por defecto.

#### Scenario: Desviación leve (GREEN)

**WHEN** `|delta_percentage| > 20%` pero `≤ 30%`

**THEN** `deviation_severity = "GREEN"` en la respuesta del mes

---

#### Scenario: Desviación moderada (YELLOW)

**WHEN** `|delta_percentage| > 30%` pero `≤ 50%`

**THEN** `deviation_severity = "YELLOW"` en la respuesta del mes

---

#### Scenario: Desviación severa (RED)

**WHEN** `|delta_percentage| > 50%`

**THEN** `deviation_severity = "RED"` en la respuesta del mes

---

#### Scenario: Sin desviación o primer mes del rango

**WHEN** `|delta_percentage| ≤ 20%` o el mes no tiene mes anterior en el rango

**THEN** `deviation_severity = "GREEN"` y `delta_vs_prior = null` para el primer mes

---

### Req-3: Desglose de categorías por mes

**WHEN** se invoca `GET /reports/comparative-months/{year_month}/categories`

**THEN** el sistema retorna todas las categorías del mes con `amount`, `percentage_of_total`, `transaction_count`, y `avg_transaction`

---

### Req-4: Comparación de categoría entre meses

**WHEN** se invoca `GET /reports/category-comparison/{category_id}?start_month=...&end_month=...`

**THEN** el sistema retorna el historial de gasto para esa categoría por mes, con `avg`, `min`, `max`, y tendencia (`UP`/`DOWN`/`STABLE`)

---

### Req-5: Resumen del rango

**WHEN** se obtiene la respuesta del endpoint comparativo

**THEN** la respuesta incluye un objeto `summary` con `avg_income`, `avg_expenses`, `avg_balance`, `avg_savings_percentage`, `max_expense_month`, `min_expense_month`

---

### Req-6: Exportación de datos comparativos

**WHEN** se invoca `GET /reports/comparative-months/export?start_month=...&end_month=...&format=csv`

**THEN** el sistema retorna el archivo en el formato solicitado (`csv`, `json`, `pdf`) con headers HTTP apropiados (`Content-Type`, `Content-Disposition`)

---

#### Scenario: Formato de exportación inválido

**WHEN** se solicita exportación con `format` diferente de `csv`, `json`, `pdf`

**THEN** el sistema retorna `400` con código `INVALID_FORMAT` y mensaje "Formato debe ser: csv, json, pdf"
