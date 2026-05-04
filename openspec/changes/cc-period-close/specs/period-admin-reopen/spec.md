## ADDED Requirements

### Req-1: Reapertura de período cerrado con motivo obligatorio

Un usuario con rol `ADMIN` DEBE poder reabrir un período con `status = CLOSED` proporcionando un motivo de al menos 10 caracteres.

#### Scenario: Reapertura exitosa con motivo válido

**WHEN** un admin envía `POST /periods/{period_id}/reopen` con `reason` de al menos 10 caracteres para un período con `status = CLOSED`

**THEN** el sistema establece `status = REOPENED`, registra `reopened_at`, `reopened_by`, `reopen_reason`, y retorna `200` con el nuevo estado

---

#### Scenario: Reapertura sin motivo o motivo muy corto

**WHEN** se envía la solicitud con `reason` ausente o con menos de 10 caracteres

**THEN** el sistema retorna `400` con código `REASON_REQUIRED` y mensaje "Motivo es obligatorio (mín. 10 caracteres)"

---

#### Scenario: Intentar reabrir un período no cerrado

**WHEN** se envía la solicitud de reapertura para un período con `status = OPEN` o `status = REOPENED`

**THEN** el sistema retorna `400` con código `INVALID_STATE_TRANSITION` y mensaje "Solo períodos cerrados pueden reabrirse"

---

#### Scenario: Reapertura por no-admin

**WHEN** un usuario sin rol `ADMIN` envía la solicitud de reapertura

**THEN** el sistema retorna `403` con código `FORBIDDEN` y mensaje "Solo administradores pueden cerrar períodos"

---

### Req-2: Auditoría de reapertura

**WHEN** un período es reabierto exitosamente

**THEN** el sistema registra el evento `PERIOD_REOPENED` en el servicio de auditoría, incluyendo `user_id`, `period_id`, `reason`, y timestamp UTC

---

### Req-3: Banner de reapertura en UI

**WHEN** el usuario accede a un período con `status = REOPENED`

**THEN** la interfaz muestra un banner visible con el texto "Período reabierto por: {reason}" y el badge del estado muestra color amarillo

---

### Req-4: Múltiples ciclos de cierre/reapertura

**WHEN** un período es cerrado, reabierto y cerrado nuevamente múltiples veces

**THEN** cada ciclo genera sus propios registros de auditoría y snapshots, sin sobrescribir los anteriores
