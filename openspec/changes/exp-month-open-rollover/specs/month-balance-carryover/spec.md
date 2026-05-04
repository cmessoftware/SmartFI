## ADDED Requirements

### Req-1: Cálculo de balance al abrir mes

Al abrir un nuevo mes, el sistema DEBE calcular el balance neto del mes anterior cerrado.

#### Scenario: Balance positivo (crédito) se traslada como ingreso

**WHEN** el mes anterior tiene `total_income > total_expenses + adjustments` y se abre el nuevo mes

**THEN** el sistema calcula `net_balance = income - expenses + adjustments` y crea una transacción de tipo `I` (ingreso) con `origin = CARRYOVER`, `category = "Saldo Anterior"`, `amount = net_balance`, `source_month = prior_month`

---

#### Scenario: Balance negativo (débito) se traslada como gasto

**WHEN** el mes anterior tiene `total_income < total_expenses + adjustments` y se abre el nuevo mes

**THEN** el sistema calcula `net_balance = abs(income - expenses + adjustments)` y crea una transacción de tipo `E` (gasto) con `origin = CARRYOVER`, `amount = net_balance`, `source_month = prior_month`

---

#### Scenario: Balance exactamente cero

**WHEN** el mes anterior tiene `net_balance = 0`

**THEN** el sistema no crea ninguna transacción de carryover pero sí registra el `MonthlyBalance` con `balance_amount = 0`

---

### Req-2: Validación de mes anterior cerrado

**WHEN** se invoca `POST /months` con un `year_month` cuyo mes anterior existe pero tiene `status ≠ CLOSED`

**THEN** el sistema retorna `400` con código `PRIOR_MONTH_NOT_CLOSED` y mensaje "El mes anterior no está cerrado"

---

### Req-3: Creación de registro de trazabilidad

**WHEN** se crea una transacción de carryover

**THEN** el sistema crea un registro en `monthly_balances` con `source_month`, `target_month`, `balance_amount`, `balance_type`, y `carryover_date`

---

### Req-4: Detalle de carryover accesible

**WHEN** se invoca `GET /months/{year_month}/carryover`

**THEN** el sistema retorna el desglose del carryover: `income_total`, `expense_total`, `adjustments_total`, `net_balance`, y la transacción de carryover creada

---

### Req-5: Idempotencia de apertura

**WHEN** se intenta crear un mes con `year_month` que ya existe

**THEN** el sistema retorna `400` con código `MONTH_EXISTS` y mensaje "Mes {year_month} ya existe"
