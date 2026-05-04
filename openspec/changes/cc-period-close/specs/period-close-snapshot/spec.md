## ADDED Requirements

### Req-1: Captura automática de snapshot al cierre

El sistema DEBE crear un `CreditCardPeriodSnapshot` en el momento exacto en que un período pasa al estado `CLOSED`.

#### Scenario: Snapshot creado al cerrar período

**WHEN** un admin ejecuta `POST /periods/{period_id}/close` exitosamente

**THEN** el sistema crea un `CreditCardPeriodSnapshot` con `total_purchases`, `total_payments`, `pending_balance`, `purchase_count`, `installment_count` calculados en ese instante, y los retorna en el cuerpo de la respuesta

---

#### Scenario: Snapshot único por cierre

**WHEN** un período es cerrado, reabierto y vuelto a cerrar

**THEN** se crea un nuevo snapshot en cada cierre sin modificar los snapshots anteriores

---

### Req-2: Composición del snapshot

El snapshot DEBE contener:
- `total_purchases`: suma de todas las compras del período (excluyendo pagos)
- `total_payments`: suma de todos los pagos registrados en el período
- `pending_balance`: `total_purchases - total_payments`
- `purchase_count`: cantidad de compras (no pagos)
- `installment_count`: cantidad de compras en cuotas activas

#### Scenario: Cálculo correcto de pending_balance

**WHEN** el sistema crea el snapshot para un período con compras y pagos registrados

**THEN** `pending_balance = total_purchases - total_payments` refleja correctamente el monto pendiente al momento del cierre

---

### Req-3: Snapshot accesible desde API

**WHEN** se consulta `GET /periods/{period_id}/status` para un período cerrado

**THEN** la respuesta incluye el snapshot más reciente en el campo `snapshot`

---

### Req-4: Snapshot inmutable post-cierre

**WHEN** se intenta modificar un snapshot existente

**THEN** el sistema no expone ningún endpoint de escritura sobre snapshots; solo se crean al cerrar, nunca se editan
