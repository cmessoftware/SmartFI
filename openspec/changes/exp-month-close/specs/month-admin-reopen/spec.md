## ADDED Requirements

### Req-1: Reapertura de mes cerrado con motivo obligatorio

Un usuario con rol `ADMIN` DEBE poder reabrir un mes con `status = CLOSED` proporcionando un motivo de al menos 10 caracteres.

#### Scenario: Reapertura exitosa con motivo válido

**WHEN** un admin envía `POST /months/{year_month}/reopen` con `reason` de al menos 10 caracteres para un mes con `status = CLOSED`

**THEN** el sistema establece `status = REOPENED`, registra `reopened_at`, `reopened_by`, `reopen_reason`, y retorna `200` con el nuevo estado

---

#### Scenario: Reapertura sin motivo o motivo muy corto

**WHEN** se envía `POST /months/{year_month}/reopen` con `reason` ausente o con menos de 10 caracteres

**THEN** el sistema retorna `400` con código `REASON_REQUIRED` y mensaje "Motivo es obligatorio (mín. 10 caracteres)"

---

#### Scenario: Intentar reabrir un mes no cerrado

**WHEN** se envía `POST /months/{year_month}/reopen` para un mes con `status = OPEN` o `status = REOPENED`

**THEN** el sistema retorna `400` con código `INVALID_STATE_TRANSITION` y mensaje "Solo meses cerrados pueden reabrirse"

---

#### Scenario: Reapertura por no-admin

**WHEN** un usuario sin rol `ADMIN` envía `POST /months/{year_month}/reopen`

**THEN** el sistema retorna `403` con código `FORBIDDEN` y mensaje "Solo administradores pueden cerrar meses"

---

### Req-2: Auditoría de reapertura

**WHEN** un mes es reabierto exitosamente

**THEN** el sistema registra el evento `MONTH_REOPENED` en el servicio de auditoría, incluyendo `user_id`, `year_month`, `reason`, y timestamp UTC

---

### Req-3: Banner de reapertura en UI

**WHEN** el usuario accede a un mes con `status = REOPENED`

**THEN** la interfaz muestra un banner visible con el texto "Mes reabierto por: {reason}" y el estado del mes se muestra con badge amarillo

---

### Req-4: Múltiples ciclos de cierre/reapertura

**WHEN** un mes es cerrado, reabierto y cerrado nuevamente múltiples veces

**THEN** cada ciclo genera sus propios registros de auditoría y snapshots, sin sobrescribir los anteriores
