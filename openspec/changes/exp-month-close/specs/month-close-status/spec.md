## ADDED Requirements

### Req-1: Ciclo de vida de estado mensual

El sistema DEBE mantener un estado (`OPEN`, `CLOSED`, `REOPENED`) por cada mes calendario (YYYY-MM) en el módulo de gastos.

#### Scenario: Cierre de mes por admin o writer

**WHEN** un usuario con rol `ADMIN` o `WRITER` envía `POST /months/{year_month}/close` para un mes con `status = OPEN`

**THEN** el sistema establece `status = CLOSED`, registra `closed_at` con timestamp UTC, retorna `200` con el nuevo estado y el snapshot creado

---

#### Scenario: Intento de cierre por usuario sin permiso

**WHEN** un usuario sin rol `ADMIN` ni `WRITER` envía `POST /months/{year_month}/close`

**THEN** el sistema retorna `403` con código `FORBIDDEN` y mensaje "Solo administradores o writers pueden cerrar meses"

---

#### Scenario: Reapertura de mes (solo admin)

**WHEN** un usuario con rol `WRITER` (sin `ADMIN`) envía `POST /months/{year_month}/reopen`

**THEN** el sistema retorna `403` — la reapertura es exclusiva de `ADMIN`

---

#### Scenario: Cierre de mes ya cerrado

**WHEN** se envía `POST /months/{year_month}/close` para un mes con `status = CLOSED`

**THEN** el sistema retorna `400` con código `MONTH_ALREADY_CLOSED` y mensaje "Este mes ya está cerrado"

---

### Req-2: Bloqueo de transacciones en mes cerrado

Las operaciones de creación, edición y eliminación de transacciones DEBEN estar bloqueadas para usuarios no-admin en meses con `status = CLOSED`.

#### Scenario: Crear transacción en mes cerrado (no-admin)

**WHEN** un usuario sin rol `ADMIN` intenta crear una transacción con fecha dentro de un mes con `status = CLOSED`

**THEN** el sistema retorna `403` con código `MONTH_CLOSED` y mensaje indicando que el mes está cerrado

---

#### Scenario: Crear transacción en mes cerrado (admin)

**WHEN** un usuario con rol `ADMIN` crea una transacción en un mes con `status = CLOSED`

**THEN** el sistema permite la operación y registra el evento de auditoría correspondiente

---

### Req-3: Exención de ajustes bancarios

Los ajustes bancarios (`origin = bank_adjustment`) DEBEN poder agregarse a meses cerrados por usuarios admin.

#### Scenario: Agregar ajuste bancario en mes cerrado

**WHEN** un usuario con rol `ADMIN` crea una transacción con `origin = bank_adjustment` en un mes con `status = CLOSED`

**THEN** el sistema permite la operación, registra el evento `BANK_ADJUSTMENT_IN_CLOSED_MONTH` en auditoría, y retorna `201`

---

### Req-4: Transición REOPENED

**WHEN** un mes `CLOSED` es reabierto, su estado cambia a `REOPENED`

**THEN** todas las operaciones de C/E/D de transacciones quedan habilitadas para todos los usuarios (como en `OPEN`), y los cambios se auditan con mayor granularidad

---

### Req-5: Consulta de estado

**WHEN** se invoca `GET /months/{year_month}/status`

**THEN** el sistema retorna el estado actual, `closed_at`, `closed_by`, `reopened_at`, `reopened_by`, y el snapshot más reciente si existe

---

### Req-6: Listado con estado

**WHEN** se invoca `GET /months?include_status=true`

**THEN** cada entrada del listado incluye `status`, `closed_at`, y un resumen del snapshot si el mes está cerrado

---

### Req-7: Cierre exclusivamente manual

El sistema NO DEBE cerrar meses automáticamente por cambio de mes calendario, jobs programados, ni al alcanzar fin de mes.

#### Scenario: Cambio de mes sin cierre manual

**WHEN** el sistema pasa de abril a mayo sin que un admin ejecute `POST /months/2026-04/close`

**THEN** abril conserva su estado previo (`OPEN` o `REOPENED`), permanece editable según reglas de rol, y no se crea ningún snapshot automático
