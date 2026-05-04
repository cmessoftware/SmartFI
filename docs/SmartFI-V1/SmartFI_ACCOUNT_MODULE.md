# Módulo: Administración de Cuentas Bancarias y Fintechs

## Features y Bugs (IDs sincronizados)

| ID | Tipo | Prioridad | Estado | Resumen |
|---|---|---|---|---|
| ACC-FEAT-001 | Feature | Alta | 📋 Backlog | ABM de cuentas bancarias/fintech con ownership por `user_id` y soft delete |
| ACC-FEAT-002 | Feature | Alta | 📋 Backlog | Transferencias internas atómicas entre cuentas (`account_transfers`) sin impacto en gasto/ingreso |
| ACC-FEAT-003 | Feature | Media | 📋 Backlog | Integración de `source_account_id` en transacciones de gastos/ingresos |
| ACC-FEAT-004 | Feature | Media | 📋 Backlog | Historial y trazabilidad de transferencias con filtros por fecha/titular |
| ACC-FEAT-005 | Feature | Media | 📋 Backlog | Resumen consolidado familiar de saldos por cuenta y por moneda |
| ACC-BUG-001 | Bug | Baja | 📋 Backlog | Sin bugs registrados aún en este módulo (placeholder para mantener convención de IDs) |

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

---

## Roles y Permisos

| Operación                             | `admin` | `writer`           | `viewer` |
|---------------------------------------|---------|--------------------|----------|
| Ver todas las cuentas del sistema     | ✅       | ❌                  | ❌        |
| Ver sus propias cuentas               | ✅       | ✅                  | ✅        |
| Crear cuenta                          | ✅       | ✅ (solo propia)    | ❌        |
| Editar cuenta                         | ✅       | ✅ (solo propia)    | ❌        |
| Desactivar / eliminar cuenta          | ✅       | ✅ (solo propia)    | ❌        |
| Ajustar saldo manualmente             | ✅       | ✅ (solo propia)    | ❌        |
| Registrar transferencia interna       | ✅       | ✅ (desde su cuenta)| ❌        |
| Ver transferencias (propias)          | ✅       | ✅                  | ✅        |

**Regla de aislamiento para `writer`:** toda consulta y mutación filtra por `user_id = current_user.id`. Un writer nunca accede a cuentas ajenas. El `admin` puede omitir ese filtro (visión familiar consolidada).

### Códigos de permiso sugeridos (tabla `permissions`, módulo `accounts`)

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

### Tabla `bank_accounts`

| Columna            | Tipo            | Descripción                                                     |
|--------------------|-----------------|-----------------------------------------------------------------|
| `id`               | Integer PK      | Identificador único                                             |
| `user_id`          | FK → `users.id` | Titular de la cuenta (miembro de la familia)                    |
| `account_name`     | String(100)     | Nombre descriptivo (ej.: "Brubank Principal", "BBVA ARS")       |
| `institution_name` | String(100)     | Nombre del banco o fintech                                      |
| `account_type`     | Enum            | `CUENTA_CORRIENTE`, `CAJA_AHORRO`, `BILLETERA_VIRTUAL`, `INVERSION`, `OTRO` |
| `currency`         | String(3)       | `ARS`, `USD`, `USDT`, etc.                                      |
| `balance`          | Float           | Saldo actual                                                    |
| `is_active`        | Boolean         | Si la cuenta está activa                                        |
| `cbu_cvu`          | String(22)      | CBU / CVU (opcional, solo almacenamiento local)                 |
| `alias`            | String(50)      | Alias de transferencia (opcional)                               |
| `notes`            | Text            | Notas libres                                                    |
| `created_at`       | DateTime        |                                                                 |
| `updated_at`       | DateTime        |                                                                 |

### Tabla `account_transfers` ← nueva, clave para conciliación

Esta tabla registra **únicamente movimientos entre cuentas internas** del grupo familiar. No genera transacciones de gasto/ingreso.

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

### Enums

```python
class AccountType(str, enum.Enum):
    CUENTA_CORRIENTE   = "CUENTA_CORRIENTE"
    CAJA_AHORRO        = "CAJA_AHORRO"
    BILLETERA_VIRTUAL  = "BILLETERA_VIRTUAL"
    INVERSION          = "INVERSION"
    OTRO               = "OTRO"
```

> **Nota de migración:** crear vía Alembic con `alembic revision --autogenerate -m "add_bank_accounts_module"` después de agregar los modelos en `backend/database/database.py`.

---

## Cómo se Actualiza el Saldo

### Ingreso acreditado en una cuenta
1. El usuario registra una `Transaction` de tipo `Ingreso` y asigna `source_account_id` = su cuenta.
2. El servicio suma el monto al `balance` de la cuenta.
3. La transacción aparece en el módulo de gastos/ingresos del mes.

### Gasto pagado desde una cuenta
1. El usuario registra una `Transaction` de tipo `Gasto` y asigna `source_account_id` = su cuenta.
2. El servicio resta el monto del `balance` de la cuenta.
3. La transacción aparece en el módulo de gastos del mes y se puede vincular a un `budget_item`.

### Transferencia entre cuentas familiares
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

| Método   | Ruta                    | Descripción                               | Permiso requerido         |
|----------|-------------------------|-------------------------------------------|---------------------------|
| `GET`    | `/`                     | Lista cuentas del usuario autenticado     | `accounts:read_own`       |
| `GET`    | `/all`                  | Lista todas las cuentas (admin/familia)   | `accounts:read_all`       |
| `GET`    | `/{id}`                 | Detalle de una cuenta                     | `accounts:read_own`       |
| `POST`   | `/`                     | Crear cuenta                              | `accounts:write_own`      |
| `PUT`    | `/{id}`                 | Editar cuenta                             | `accounts:write_own`      |
| `PATCH`  | `/{id}/balance`         | Ajuste manual de saldo                    | `accounts:write_own`      |
| `DELETE` | `/{id}`                 | Desactivar cuenta (soft delete)           | `accounts:delete_own`     |
| `POST`   | `/transfers`            | Registrar transferencia interna           | `accounts:transfer_own`   |
| `GET`    | `/transfers`            | Historial de transferencias (propias)     | `accounts:read_own`       |
| `GET`    | `/transfers/all`        | Historial completo (admin)                | `accounts:read_all`       |
| `GET`    | `/summary`              | Saldo total consolidado familiar (admin)  | `accounts:read_all`       |

---

## Frontend

### Componentes sugeridos
- `AccountList` — tarjetas con titular, institución, tipo, moneda y saldo actual
- `AccountForm` — alta/edición
- `BalanceAdjustModal` — ajuste manual de saldo con nota obligatoria
- `TransferForm` — formulario para registrar transferencia entre cuentas; muestra saldo disponible en cuenta origen
- `TransferHistory` — listado de transferencias con from/to, monto, fecha y motivo
- `FamilyBalanceSummary` — widget admin: saldo total ARS, total USD, por cuenta y por miembro

### Formato de moneda
```js
new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(balance)
new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'USD' }).format(balance)
```

---

## Integración con Módulo de Gastos y Presupuesto

### Cambio en `transactions`
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

### Cambio en `budget_items`
Agregar columna `source_account_id` (FK → `bank_accounts.id`, nullable):
- Al planificar una obligación (ej.: cuota del préstamo) → se puede indicar desde qué cuenta se pagará.
- Permite proyectar el saldo futuro de cada cuenta.

### Reporte de saldo proyectado (Fase 3)
Dado que el admin conoce:
- Saldo actual de cada cuenta
- Ingresos esperados del mes (`budget_items` tipo Ingreso)
- Gastos planificados del mes (`budget_items` tipo Gasto, con `source_account_id`)

Se puede calcular: `saldo_proyectado = saldo_actual + ingresos_esperados - gastos_planificados` por cuenta.

---

## Plan de Implementación

| Fase | Alcance                                                                 |
|------|-------------------------------------------------------------------------|
| 1    | CRUD de `bank_accounts`, permisos, saldo manual, UI básica              |
| 2    | `account_transfers`: registro atómico, historial, validación de saldo   |
| 3    | `source_account_id` en `transactions`: ajuste automático de saldo       |
| 4    | `source_account_id` en `budget_items`: proyección de saldo por cuenta   |
| 5    | Dashboard familiar: saldo consolidado, proyección, historial de movimientos |

---

## Consideraciones de Seguridad

- **CBU/CVU/alias:** solo exponer en el detalle del propio usuario; nunca en listados generales.
- **Soft delete:** `is_active = False`, preservar historial de transacciones y transferencias vinculadas.
- **Operación atómica en transferencias:** usar `with_for_update()` y commit único para evitar inconsistencias de saldo si hay concurrencia.
- **Audit log:** registrar en `audit_logs` ajustes manuales de saldo, creación/edición/desactivación de cuentas y toda transferencia.
- **Aislamiento por `user_id`:** siempre filtrar en el servicio; el `admin` es el único que puede omitir el filtro.
- **Validación de saldo:** antes de registrar una transferencia, verificar que `from_account.balance >= amount` (o emitir advertencia configurable si se permiten saldos negativos).
