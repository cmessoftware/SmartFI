## ADDED Requirements

### Req-1: Cálculo automático de saldo impago al crear período

Al crear un nuevo período, el sistema DEBE calcular el saldo pendiente total de todos los períodos anteriores cerrados con saldo impago.

#### Scenario: Nuevo período con saldo impago anterior

**WHEN** se crea un nuevo período y existen períodos anteriores con `status = CLOSED` y `pending_balance > 0`

**THEN** el sistema calcula `unpaid_balance = SUM(purchase_total + interest_accrued - payment_total)` para todos esos períodos, crea un registro en `credit_card_period_carryovers`, y crea una pseudo-compra con `origin = CARRYOVER`, `amount = unpaid_balance`, en la lista de compras del nuevo período

---

#### Scenario: Nuevo período sin saldo impago anterior

**WHEN** se crea un nuevo período y no existen períodos anteriores con saldo impago

**THEN** el sistema crea el período sin carryover y la lista de compras comienza vacía

---

#### Scenario: Carryover negativo o cero

**WHEN** el cálculo de `unpaid_balance` resulta en `<= 0`

**THEN** el sistema no crea carryover ni pseudo-transacción; el período se crea sin línea de saldo anterior

---

### Req-2: Pago mínimo incluye carryover

**WHEN** un nuevo período tiene carryover y se consulta el resumen del período

**THEN** el campo `minimum_payment` incluye el carryover en su cálculo y la respuesta de API indica `carryover_amount` separado del monto de nuevas compras

---

### Req-3: Drill-down del carryover

**WHEN** se invoca `GET /credit-cards/{card_id}/periods/{period_id}/carryover/{carryover_id}`

**THEN** el sistema retorna el desglose completo: `source_period_range`, `purchases_in_source`, `payments_in_source`, `interest_accrued_pre_close`, `interest_accrued_post_close`, `net_at_carryover`, y la lista de transacciones no pagas del período origen

---

### Req-4: Trazabilidad de carryover en resumen del período

**WHEN** se invoca `GET /credit-cards/{card_id}/periods/{period_id}?include_carryover=true`

**THEN** la respuesta incluye `carryover.total_amount`, `carryover.sources` (lista de períodos origen con sus montos), y el resumen con `purchases`, `carryover`, `total_outstanding`, `minimum_payment`

---

### Req-5: Fechas y solapamiento de períodos

**WHEN** se intenta crear un período con fechas que se solapan con un período existente

**THEN** el sistema retorna `400` con código `PERIOD_OVERLAP` y mensaje "Fechas del período se solapan con período existente"

---

### Req-6: Campos obligatorios del período

**WHEN** se intenta crear un período sin `period_start`, `period_end`, `closing_date` o `due_date`

**THEN** el sistema retorna `400` con código `MISSING_FIELDS` y mensaje "Faltan campos obligatorios: period_start, period_end, closing_date, due_date"

---

### Req-7: Listado con resumen incluyendo carryover

**WHEN** se invoca `GET /credit-cards/{card_id}/periods?include_summary=true`

**THEN** cada período incluye en `summary`: `new_purchases`, `carryover` (si aplica), `total_outstanding`, `minimum_payment`
