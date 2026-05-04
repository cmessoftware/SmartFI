## ADDED Requirements

### Req-1: Captura automática de snapshot al cierre

El sistema DEBE crear un `MonthlyPeriodSnapshot` en el momento exacto en que un mes pasa al estado `CLOSED`.

#### Scenario: Snapshot creado al cerrar mes

**WHEN** un admin ejecuta `POST /months/{year_month}/close` exitosamente

**THEN** el sistema crea un `MonthlyPeriodSnapshot` con `total_expenses`, `total_income`, `net_balance`, `transaction_count` calculados en ese instante, y los retorna en el cuerpo de la respuesta

---

#### Scenario: Snapshot único por cierre

**WHEN** un mes es cerrado, reabierto y vuelto a cerrar

**THEN** se crea un nuevo snapshot en cada cierre, sin modificar los snapshots anteriores, preservando la trazabilidad histórica

---

### Req-2: Composición del snapshot

El snapshot DEBE contener:
- `total_expenses`: suma de transacciones con tipo `C`, `D`, `E`
- `total_income`: suma de transacciones con tipo `I`
- `net_balance`: `total_income - total_expenses`
- `transaction_count`: cantidad total de transacciones en el mes

#### Scenario: Cálculo correcto de totales

**WHEN** el sistema crea el snapshot para un mes con transacciones de distintos tipos

**THEN** los campos `total_expenses`, `total_income`, `net_balance` reflejan correctamente la suma por tipo según las definiciones anteriores

---

### Req-3: Snapshot accesible desde API

**WHEN** se consulta `GET /months/{year_month}/status` para un mes cerrado

**THEN** la respuesta incluye el snapshot más reciente en el campo `snapshot`

---

### Req-4: Snapshot inmutable post-cierre

**WHEN** se intenta modificar un snapshot existente directamente

**THEN** el sistema no expone ningún endpoint de escritura sobre snapshots; solo se crean en cierre, nunca se editan
