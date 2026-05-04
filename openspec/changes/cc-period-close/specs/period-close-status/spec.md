## ADDED Requirements

### Req-1: Ciclo de vida de estado de período

El sistema DEBE mantener un estado (`OPEN`, `CLOSED`, `REOPENED`) para cada `CreditCardPeriodConfig`.

#### Scenario: Cierre de período por admin

**WHEN** un usuario con rol `ADMIN` envía `POST /credit-cards/{card_id}/periods/{period_id}/close` para un período con `status = OPEN`

**THEN** el sistema establece `status = CLOSED`, registra `closed_at` con timestamp UTC, retorna `200` con el nuevo estado y el snapshot creado

---

#### Scenario: Intento de cierre por no-admin

**WHEN** un usuario sin rol `ADMIN` envía la solicitud de cierre

**THEN** el sistema retorna `403` con código `FORBIDDEN` y mensaje "Solo administradores pueden cerrar períodos"

---

#### Scenario: Cierre de período ya cerrado

**WHEN** se envía la solicitud de cierre para un período con `status = CLOSED`

**THEN** el sistema retorna `400` con código `PERIOD_ALREADY_CLOSED` y mensaje "Este período ya está cerrado"

---

### Req-2: Bloqueo de compras en período cerrado

Las operaciones de creación, edición y eliminación de compras DEBEN estar bloqueadas para usuarios no-admin en períodos con `status = CLOSED`.

#### Scenario: Crear compra en período cerrado (no-admin)

**WHEN** un usuario sin rol `ADMIN` intenta crear una compra en un período con `status = CLOSED`

**THEN** el sistema retorna `403` con código `PERIOD_CLOSED` y mensaje indicando que el período está cerrado

---

#### Scenario: Crear compra en período cerrado (admin)

**WHEN** un usuario con rol `ADMIN` crea una compra en un período con `status = CLOSED`

**THEN** el sistema permite la operación y registra el evento de auditoría correspondiente

---

### Req-3: Exención de ajustes bancarios

Los ajustes bancarios (`purchase_type ∈ [INTEREST, TAX, PENALTY, FEE, BANK_ADJUSTMENT]`) DEBEN poder agregarse a períodos cerrados por usuarios admin.

#### Scenario: Agregar ajuste bancario en período cerrado

**WHEN** un usuario con rol `ADMIN` crea una compra con `purchase_type` de tipo ajuste bancario en un período `CLOSED`

**THEN** el sistema permite la operación, registra el evento `BANK_ADJUSTMENT_IN_CLOSED_PERIOD` en auditoría, y retorna `201`

---

### Req-4: Transición REOPENED

**WHEN** un período `CLOSED` es reabierto

**THEN** el estado cambia a `REOPENED`, todas las operaciones de C/E/D quedan habilitadas para todos los usuarios, y los cambios se auditan

---

### Req-5: Consulta de estado de período

**WHEN** se invoca `GET /credit-cards/{card_id}/periods/{period_id}/status`

**THEN** el sistema retorna `status`, `closed_at`, `reopened_at`, `reopened_by`, y el snapshot más reciente si el período está cerrado

---

### Req-6: Listado de períodos con estado

**WHEN** se invoca `GET /credit-cards/{card_id}/periods?include_status=true`

**THEN** cada período en la respuesta incluye `status`, `closed_at`, y un resumen del snapshot si está cerrado
