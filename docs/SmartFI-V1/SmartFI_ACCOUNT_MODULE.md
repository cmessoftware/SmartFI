# Módulo: Administración de Cuentas Bancarias y Fintechs

## Estado de implementación (revisión 2026-07-09)

| Área | Progreso | Detalle |
|------|----------|---------|
| **Backend Fase 1** | 🔄 ~70% | Modelo, migración, servicio CRUD y API REST básica operativos |
| **Frontend** | ⏳ 0% | Sin componentes, rutas ni entradas en sidebar |
| **Transferencias (Fase 2)** | ⏳ 0% | Sin tabla `account_transfers`, servicio ni endpoints |
| **Integración gastos (Fase 3–4)** | ⏳ 0% | Sin `source_account_id` en `transactions` ni `budget_items` |
| **Dashboard familiar (Fase 5)** | ⏳ 0% | Sin endpoint `/summary` ni widgets |

**Resumen:** 1 de 7 ítems con avance parcial (solo backend de ACC-FEAT-001). El módulo no es usable desde la UI; la API puede consumirse vía HTTP (Postman, scripts).

### Archivos implementados (Fase 1 backend)

| Archivo | Rol |
|---------|-----|
| `backend/database/database.py` | Modelo `BankAccount`, enum `AccountType` |
| `backend/alembic/versions/ad1636edd0b9_add_bank_accounts_module.py` | Migración tabla `bank_accounts` |
| `backend/services/bank_account_service.py` | CRUD + soft delete + filtro admin/writer |
| `backend/main.py` (≈ líneas 1943–2044) | Endpoints `/api/accounts` |
| `backend/security/seed_data.py` | Permisos `accounts.read`, `accounts.write`, `accounts.delete` |

---

## FEATs y Bugs (IDs sincronizados)

| ID | Tipo | Prioridad | Estado | Resumen |
|---|---|---|---|---|
| ACC-FEAT-001 | FEAT | Alta | 🔄 In Progress | ABM de cuentas bancarias/fintech con ownership por `user_id` y soft delete — **backend listo; falta UI y ajuste dedicado de saldo** |
| ACC-FEAT-002 | FEAT | Alta | ⏳ Todo | Transferencias internas atómicas entre cuentas (`account_transfers`) sin impacto en gasto/ingreso |
| ACC-FEAT-003 | FEAT | Media | ⏳ Todo | Integración de `source_account_id` en transacciones de gastos/ingresos |
| ACC-FEAT-004 | FEAT | Media | ⏳ Todo | Historial y trazabilidad de transferencias con filtros por fecha/titular |
| ACC-FEAT-005 | FEAT | Media | ⏳ Todo | Resumen consolidado familiar de saldos por cuenta y por moneda |
| ACC-BUG-006 | BUG | Baja | ⏳ Todo | Sin bugs registrados aún en este módulo (placeholder para mantener convención de IDs) |
| ACC-FEAT-007 | FEAT | Media | ⏳ Todo | Formulario de transferencias entre cuentas (origen, destino, motivo, fecha/hora) — depende de ACC-FEAT-002 |

### Detalle ACC-FEAT-001 (parcial)

**✅ Implementado**

- Tabla `bank_accounts` con todos los campos documentados
- Enum `AccountType`: `CUENTA_CORRIENTE`, `CAJA_AHORRO`, `BILLETERA_VIRTUAL`, `INVERSION`, `OTRO`
- CRUD en `BankAccountService`: listar, obtener, crear, actualizar, desactivar (`is_active=False`)
- Admin ve todas las cuentas; writer solo las propias (`user_id`)
- Query param `active_only` (default `true`) en listado
- Permisos sembrados y aplicados en endpoints

**❌ Pendiente (Fase 1)**

- UI: `AccountList`, `AccountForm`, entrada en `Sidebar.jsx`, cliente en `api.js`
- Endpoint dedicado `PATCH /{id}/balance` (hoy el saldo se edita vía `PUT /{id}` con campo `balance`)
- Audit log de ajustes manuales de saldo
- Tests automatizados del servicio/API
- Validación Pydantic tipada (hoy el body es `dict` genérico)

---

## Descripción

Este módulo gestiona las cuentas bancarias y de fintechs de todos los miembros de la familia (ej.: Brubank, Ualá, Mercado Pago, Naranja X, bancos tradicionales). Centraliza el saldo por cuenta, registra ingresos y gastos vinculados a cada una, y maneja correctamente las **transferencias entre cuentas internas** para evitar la doble contabilización en el módulo de gastos.

### Principio fundamental de conciliación

| Movimiento                                   | ¿Es gasto/ingreso? | Impacto en saldo               |
|----------------------------------------------|---------------------|-------------------------------|
| Sueldo acreditado en Brubank                 | ✅ Ingreso           | +saldo Brubank                |
| Pago de Netflix desde Naranja X              | ✅ Gasto             | -saldo Naranja X              |
| Transferencia de Brubank → Naranja X (interna) | ❌ NO es ni gasto ni ingreso | -saldo Brubank, +saldo Naranja X |
| Pago desde Naranja X con fondos recibidos    | ✅ Gasto (se registra cuando se paga, no cuando se transfiere) | -saldo Naranja X |

> **Regla de oro:** una transferencia entre dos cuentas del grupo familiar **nunca se registra como gasto ni ingreso**. Solo cuando el dinero sale o entra del ecosistema familiar (pago a tercero, cobro de sueldo, etc.) se genera una transacción contable.

---

## Contexto Familiar (Multi-usuario)

Las cuentas **no son exclusivamente personales**: varias cuentas pueden pertenecer a distintos miembros de la familia pero todas son visibles y gestionables por el admin (visión familiar consolidada). Un `writer` solo ve y opera sus propias cuentas.

Esto permite:
- Registrar que "la cuenta de Naranja X es de María" y "el Brubank es de Juan".
- El admin (quien gestiona las finanzas familiares) ve el total consolidado de todas las cuentas.
- Las transferencias entre cuentas de distintos miembros se identifican como **internas** y no generan gastos.

**Estado actual:** la lógica admin vs writer está implementada en el backend (`get_accounts`, `get_account`, etc.). La vista consolidada familiar en UI aún no existe.

---

## Roles y Permisos

| Operación                             | `admin` | `writer`           | `viewer` | Estado |
|---------------------------------------|---------|--------------------|----------|--------|
| Ver todas las cuentas del sistema     | ✅       | ❌                  | ❌        | ✅ Backend |
| Ver sus propias cuentas               | ✅       | ✅                  | ✅        | ✅ Backend |
| Crear cuenta                          | ✅       | ✅ (solo propia)    | ❌        | ✅ Backend |
| Editar cuenta                         | ✅       | ✅ (solo propia)    | ❌        | ✅ Backend |
| Desactivar / eliminar cuenta          | ✅       | ✅ (solo propia)    | ❌        | ✅ Backend |
| Ajustar saldo manualmente             | ✅       | ✅ (solo propia)    | ❌        | 🔄 vía PUT (sin UI ni audit) |
| Registrar transferencia interna       | ✅       | ✅ (desde su cuenta)| ❌        | ⏳ No implementado |
| Ver transferencias (propias)          | ✅       | ✅                  | ✅        | ⏳ No implementado |

**Regla de aislamiento para `writer`:** toda consulta y mutación filtra por `user_id = current_user.id`. Un writer nunca accede a cuentas ajenas. El `admin` puede omitir ese filtro (visión familiar consolidada).

### Permisos en código (`seed_data.py`)

Implementación actual — permisos granulares por operación, no separados en `_own` / `_all`:

```
accounts.read    → listar/ver cuentas (admin: todas; writer/reader: propias)
accounts.write   → crear y editar cuentas
accounts.delete  → desactivar cuentas (soft delete)
```

Asignación por rol:
- **ADMIN:** `accounts.read`, `accounts.write`, `accounts.delete`
- **WRITER:** `accounts.read`, `accounts.write`
- **READER:** `accounts.read`

> **Nota de diseño:** el doc original proponía permisos `_own` / `_all` separados. La implementación simplifica a tres permisos y delega el alcance (propias vs todas) al servicio según rol `ADMIN`. Cuando se implementen transferencias, evaluar agregar `accounts.transfer`.

### Permisos sugeridos (futuro, no implementados)

```
accounts:read_own
accounts:read_all
accounts:write_own
accounts:write_all
accounts:delete_own
accounts:delete_all
accounts:transfer_own
accounts:transfer_all
```

---

## Modelo de Datos

### Tabla `bank_accounts` — ✅ implementada

| Columna            | Tipo            | Descripción                                                     | Estado |
|--------------------|-----------------|-----------------------------------------------------------------|--------|
| `id`               | Integer PK      | Identificador único                                             | ✅ |
| `user_id`          | FK → `users.id` | Titular de la cuenta (miembro de la familia)                    | ✅ |
| `account_name`     | String(100)     | Nombre descriptivo (ej.: "Brubank Principal", "BBVA ARS")       | ✅ |
| `institution_name` | String(100)     | Nombre del banco o fintech                                      | ✅ |
| `account_type`     | Enum            | `CUENTA_CORRIENTE`, `CAJA_AHORRO`, `BILLETERA_VIRTUAL`, `INVERSION`, `OTRO` | ✅ |
| `currency`         | String(3)       | `ARS`, `USD`, `USDT`, etc.                                      | ✅ |
| `balance`          | Float           | Saldo actual                                                    | ✅ |
| `is_active`        | Boolean         | Si la cuenta está activa                                        | ✅ |
| `cbu_cvu`          | String(22)      | CBU / CVU (opcional, solo almacenamiento local)                 | ✅ |
| `alias`            | String(50)      | Alias de transferencia (opcional)                               | ✅ |
| `notes`            | Text            | Notas libres                                                    | ✅ |
| `created_at`       | DateTime        |                                                                 | ✅ |
| `updated_at`       | DateTime        |                                                                 | ✅ |

Migración: `ad1636edd0b9_add_bank_accounts_module.py` (revision `ad1636edd0b9`).

### Tabla `account_transfers` — ⏳ no implementada

Esta tabla registrará **únicamente movimientos entre cuentas internas** del grupo familiar. No generará transacciones de gasto/ingreso.

| Columna              | Tipo                       | Descripción                                                      |
|----------------------|----------------------------|------------------------------------------------------------------|
| `id`                 | Integer PK                 |                                                                  |
| `from_account_id`    | FK → `bank_accounts.id`    | Cuenta origen (resta saldo)                                      |
| `to_account_id`      | FK → `bank_accounts.id`    | Cuenta destino (suma saldo)                                      |
| `amount`             | Float                      | Monto transferido (en la moneda de la cuenta origen)             |
| `transfer_date`      | Date                       | Fecha de la transferencia                                        |
| `reason`             | String(255)                | Motivo (ej.: "para pagar expensas", "cuota del auto")            |
| `related_budget_item_id` | FK → `budget_items.id` | Vínculo opcional con un ítem de presupuesto                    |
| `created_by_user_id` | FK → `users.id`            | Quién registró la transferencia                                  |
| `notes`              | Text                       | Notas adicionales                                                |
| `created_at`         | DateTime                   |                                                                  |

> **Por qué no usar `transactions` para esto:** la tabla `transactions` implica un gasto o ingreso real que afecta el presupuesto. Una transferencia interna tiene efecto neutro en las finanzas familiares totales. Mezclarlos distorsionaría los reportes de gasto mensual.

### Enums — ✅ implementados

```python
class AccountType(str, enum.Enum):
    CUENTA_CORRIENTE   = "CUENTA_CORRIENTE"
    CAJA_AHORRO        = "CAJA_AHORRO"
    BILLETERA_VIRTUAL  = "BILLETERA_VIRTUAL"
    INVERSION          = "INVERSION"
    OTRO               = "OTRO"
```

---

## Cómo se Actualiza el Saldo

> **Estado:** solo el ajuste manual vía API está disponible hoy. El resto es diseño objetivo para Fases 2–3.

### Ajuste manual (Fase 1 — parcial)
1. El usuario envía `PUT /api/accounts/{id}` con campo `balance`.
2. El servicio persiste el nuevo saldo.
3. ⏳ Falta: nota obligatoria, audit log y UI (`BalanceAdjustModal`).

### Ingreso acreditado en una cuenta (Fase 3 — ⏳)
1. El usuario registra una `Transaction` de tipo `Ingreso` y asigna `source_account_id` = su cuenta.
2. El servicio suma el monto al `balance` de la cuenta.
3. La transacción aparece en el módulo de gastos/ingresos del mes.

### Gasto pagado desde una cuenta (Fase 3 — ⏳)
1. El usuario registra una `Transaction` de tipo `Gasto` y asigna `source_account_id` = su cuenta.
2. El servicio resta el monto del `balance` de la cuenta.
3. La transacción aparece en el módulo de gastos del mes y se puede vincular a un `budget_item`.

### Transferencia entre cuentas familiares (Fase 2 — ⏳)
1. El usuario registra un `AccountTransfer` (from → to, monto, motivo).
2. El servicio **en una sola transacción de BD**:
   - Resta `amount` del `balance` de `from_account`.
   - Suma `amount` al `balance` de `to_account`.
3. **No se crea ninguna `Transaction`** → no aparece en reportes de gastos.
4. El registro queda en `account_transfers` para trazabilidad y conciliación.

```python
def register_transfer(db: Session, from_id: int, to_id: int, amount: float, ...):
    from_acc = db.query(BankAccount).filter_by(id=from_id).with_for_update().first()
    to_acc   = db.query(BankAccount).filter_by(id=to_id).with_for_update().first()
    from_acc.balance -= amount
    to_acc.balance   += amount
    transfer = AccountTransfer(from_account_id=from_id, to_account_id=to_id, amount=amount, ...)
    db.add(transfer)
    db.commit()  # atómico
```

---

## Casos de Uso y Conciliación

> Escenarios de diseño; ninguno es operable end-to-end hasta completar Fases 2–3 y la UI.

### Caso 1: Transferencia para cubrir un gasto personal
> Juan transfiere $50.000 de su Brubank a la Naranja X de María para que ella pague las expensas.

| Paso | Acción                                       | Módulo afectado         |
|------|----------------------------------------------|-------------------------|
| 1    | Juan registra `AccountTransfer` Brubank → Naranja X, $50.000, motivo "expensas" | Cuentas (saldo ajustado) |
| 2    | María paga las expensas con Naranja X         | María registra `Transaction` Gasto, $50.000, cuenta: Naranja X | Cuentas + Gastos/Presupuesto |

**Resultado:** el gasto de $50.000 aparece **una sola vez** en los reportes, vinculado a María. La transferencia es solo movimiento interno.

---

### Caso 2: Pago de gasto compartido desde una sola cuenta
> Juan paga el supermercado ($80.000) con su Brubank, pero el gasto es familiar.

| Paso | Acción                                             |
|------|----------------------------------------------------|
| 1    | Juan registra `Transaction` Gasto, $80.000, cuenta: Brubank, categoría: Supermercado |
| 2    | (Opcional) Se divide el gasto en el módulo de presupuesto como gasto familiar |

Si María quiere reembolsar su parte ($40.000):
- María registra `AccountTransfer` Naranja X → Brubank, $40.000, motivo "reembolso supermercado".
- El gasto original ya está registrado; el reembolso es solo un movimiento de saldo.

---

### Caso 3: Sueldo de María acreditado en Naranja X
> El sueldo de María se acredita en Naranja X.

| Paso | Acción                                             |
|------|----------------------------------------------------|
| 1    | María (o admin) registra `Transaction` Ingreso, monto sueldo, cuenta: Naranja X |
| 2    | El saldo de Naranja X sube automáticamente          |
| 3    | Aparece como Ingreso en los reportes del mes        |

---

### Caso 4: Transferencia de ARS a USD (cambio de moneda)
> Se cambian $500.000 ARS de Brubank a USD en Ualá.

Esta operación **no puede ser un `AccountTransfer` estándar** porque las monedas difieren.  
Se registra como:
1. `Transaction` Gasto en Brubank (ARS) — categoría "Cambio de moneda", $500.000 ARS.
2. `Transaction` Ingreso en Ualá (USD) — categoría "Cambio de moneda", monto en USD al tipo de cambio usado.

Esto permite registrar el tipo de cambio aplicado y auditar la operación.

---

## API Endpoints

Prefijo base: `/api/accounts`

### Implementados ✅

| Método   | Ruta                    | Descripción                               | Permiso requerido    |
|----------|-------------------------|-------------------------------------------|----------------------|
| `GET`    | `/`                     | Lista cuentas (admin: todas; writer: propias). Query: `active_only` (default `true`) | `accounts.read` |
| `GET`    | `/{id}`                 | Detalle de una cuenta                     | `accounts.read`      |
| `POST`   | `/`                     | Crear cuenta (asigna `user_id` del token) | `accounts.write`     |
| `PUT`    | `/{id}`                 | Editar cuenta (incluye `balance`)         | `accounts.write`     |
| `DELETE` | `/{id}`                 | Desactivar cuenta (soft delete)           | `accounts.delete`    |

Respuesta típica de cuenta:

```json
{
  "id": 1,
  "user_id": 2,
  "account_name": "Brubank Principal",
  "institution_name": "Brubank",
  "account_type": "BILLETERA_VIRTUAL",
  "currency": "ARS",
  "balance": 150000.0,
  "is_active": true,
  "cbu_cvu": null,
  "alias": "mi.brubank",
  "notes": null,
  "created_at": "2026-04-25T20:00:00",
  "updated_at": "2026-04-25T20:00:00"
}
```

### Planificados ⏳ (no existen en código)

| Método   | Ruta                    | Descripción                               | Permiso sugerido         |
|----------|-------------------------|-------------------------------------------|---------------------------|
| `GET`    | `/all`                  | Alias explícito de listado admin (hoy cubierto por `GET /` con rol admin) | `accounts.read` |
| `PATCH`  | `/{id}/balance`         | Ajuste manual de saldo con nota/audit     | `accounts.write`          |
| `POST`   | `/transfers`            | Registrar transferencia interna           | `accounts.transfer` (nuevo) |
| `GET`    | `/transfers`            | Historial de transferencias (propias)     | `accounts.read`           |
| `GET`    | `/transfers/all`        | Historial completo (admin)                | `accounts.read`           |
| `GET`    | `/summary`              | Saldo total consolidado familiar (admin)  | `accounts.read`           |

---

## Frontend — ⏳ no iniciado

No hay referencias a cuentas en `frontend/` (sin componentes, sin `accountsAPI` en `api.js`, sin ítem en `Sidebar.jsx`).

### Componentes sugeridos (pendientes)

- `AccountList` — tarjetas con titular, institución, tipo, moneda y saldo actual
- `AccountForm` — alta/edición
- `BalanceAdjustModal` — ajuste manual de saldo con nota obligatoria
- `TransferForm` — formulario para registrar transferencia entre cuentas; muestra saldo disponible en cuenta origen (ACC-FEAT-007)
- `TransferHistory` — listado de transferencias con from/to, monto, fecha y motivo
- `FamilyBalanceSummary` — widget admin: saldo total ARS, total USD, por cuenta y por miembro

### Formato de moneda
```js
new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(balance)
new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'USD' }).format(balance)
```

---

## Integración con Módulo de Gastos y Presupuesto — ⏳ no iniciada

### Cambio en `transactions` (Fase 3)
Agregar columna `source_account_id` (FK → `bank_accounts.id`, nullable en BD).

**Regla de negocio:** `source_account_id` es **obligatorio en la UI** para todo gasto o ingreso nuevo registrado a partir de la Fase 3. El campo es nullable en la base de datos únicamente para preservar las transacciones históricas que existían antes de este módulo.

| Tipo de transacción | `source_account_id` en UI | Efecto en saldo            |
|---------------------|---------------------------|----------------------------|
| Gasto               | Obligatorio               | `-amount` en la cuenta     |
| Ingreso             | Obligatorio               | `+amount` en la cuenta     |
| Histórico (sin cuenta) | No aplica              | Sin efecto en saldo        |

**Validación en el backend (Fase 3+):**
```python
# En el endpoint POST /api/transactions
if transaction.type in ("Gasto", "Ingreso") and transaction.source_account_id is None:
    raise HTTPException(400, "source_account_id es requerido para gastos e ingresos")
```

**Trazabilidad:** en los reportes de gastos, la cuenta de origen se muestra junto a cada transacción. Esto permite filtrar los gastos del mes por cuenta (ej.: "¿cuánto gasté desde Brubank en mayo?").

### Cambio en `budget_items` (Fase 4)
Agregar columna `source_account_id` (FK → `bank_accounts.id`, nullable):
- Al planificar una obligación (ej.: cuota del préstamo) → se puede indicar desde qué cuenta se pagará.
- Permite proyectar el saldo futuro de cada cuenta.

### Reporte de saldo proyectado (Fase 5)
Dado que el admin conoce:
- Saldo actual de cada cuenta
- Ingresos esperados del mes (`budget_items` tipo Ingreso)
- Gastos planificados del mes (`budget_items` tipo Gasto, con `source_account_id`)

Se puede calcular: `saldo_proyectado = saldo_actual + ingresos_esperados - gastos_planificados` por cuenta.

---

## Plan de Implementación

| Fase | Alcance                                                                 | Estado |
|------|-------------------------------------------------------------------------|--------|
| 1    | CRUD de `bank_accounts`, permisos, saldo manual, UI básica              | 🔄 Backend ~70%; UI 0% |
| 2    | `account_transfers`: registro atómico, historial, validación de saldo   | ⏳ Todo |
| 3    | `source_account_id` en `transactions`: ajuste automático de saldo       | ⏳ Todo |
| 4    | `source_account_id` en `budget_items`: proyección de saldo por cuenta   | ⏳ Todo |
| 5    | Dashboard familiar: saldo consolidado, proyección, historial de movimientos | ⏳ Todo |

### Próximos pasos recomendados

1. **Completar Fase 1:** UI mínima (`AccountList` + `AccountForm`), `accountsAPI` en frontend, entrada en sidebar.
2. **Fase 2:** migración `account_transfers`, servicio atómico, endpoints `/transfers`, `TransferForm` (ACC-FEAT-002, ACC-FEAT-007).
3. **Fase 3:** columna `source_account_id` en `transactions` + hook en creación/edición de gastos (ACC-FEAT-003).

---

## Consideraciones de Seguridad

| Consideración | Estado |
|---------------|--------|
| **CBU/CVU/alias:** solo exponer en detalle del propio usuario; nunca en listados generales | ⏳ Sin UI; API expone en listado (revisar al implementar frontend) |
| **Soft delete:** `is_active = False`, preservar historial | ✅ Implementado |
| **Operación atómica en transferencias:** `with_for_update()` + commit único | ⏳ Pendiente Fase 2 |
| **Audit log:** ajustes manuales, CRUD de cuentas, transferencias | ⏳ No implementado |
| **Aislamiento por `user_id`:** filtrar en servicio; admin omite filtro | ✅ Implementado |
| **Validación de saldo:** antes de transferir, `from_account.balance >= amount` | ⏳ Pendiente Fase 2 |
