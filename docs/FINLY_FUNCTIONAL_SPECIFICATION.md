# Finly — Functional Specification & Roadmap

> **⚠️ ESTADO DEL DOCUMENTO:** Especificación funcional completa del sistema Finly.
> 
> **📄 Para ver implementación técnica detallada:** Consulte [SISTEMA_ACTUAL.md](SISTEMA_ACTUAL.md)
> 
> **✅ Implementación Actual (Sprint 3):** Módulos de Transacciones, Presupuesto, Reportes y Administración  
> **📋 Este Documento (Sprint 4+):** Planificación de flujos de caja proyectados y forecast financiero

---

## Objetivo de Este Documento

Esta especificación define el diseño funcional y conceptual completo del sistema Finly, incluyendo:
- **Módulos implementados:** Especificación funcional de características actuales
- **Roadmap de evolución:** Planificación de flujos de caja futuros con proyección de balances

Está destinado a servir como **contexto de entrada para Copilot** al generar código y componentes relacionados.

---

# PARTE I: MÓDULOS IMPLEMENTADOS

## A. Módulo de Transacciones (Gastos e Ingresos)

### Objetivo
Registrar y gestionar todas las transacciones financieras del usuario (ingresos y gastos) con categorización detallada.

### Modelo de Datos

```python
Transaction:
  id: int                    # Identificador único
  marca_temporal: datetime   # Timestamp de creación
  fecha: string              # Fecha de la transacción (DD/MM/YYYY)
  tipo: enum                 # Gasto | Ingreso
  categoria: string          # Categoría (Comida, Transporte, Salud, etc.)
  monto: float               # Monto de la transacción
  necesidad: enum            # Necesario | Superfluo | Importante pero no urgente
  forma_pago: enum           # Débito | Crédito
  partida: string            # Clasificación adicional
  detalle: string            # Descripción detallada
  debt_id: int (nullable)    # FK a item de presupuesto vinculado
  created_at: datetime       # Fecha de creación en sistema
  updated_at: datetime       # Última actualización
```

### Enumeraciones

```python
TipoTransaccion:
  - Gasto
  - Ingreso

Necesidad:
  - Necesario
  - Superfluo
  - Importante pero no urgente

FormaPago:
  - Débito
  - Crédito
```

### Funcionalidades Implementadas

#### 1. CRUD de Transacciones
- **Crear:** Formulario con validación de campos obligatorios
- **Leer:** Lista completa con paginación virtual
- **Actualizar:** Modal de edición inline
- **Eliminar:** Confirmación modal antes de eliminar

#### 2. Vinculación con Presupuesto
- Al crear un gasto, opción de vincular a item de presupuesto
- Dropdown muestra solo items con estado: PENDIENTE, VENCIDA, o Pago parcial
- Actualización automática del `monto_pagado` del item vinculado
- Recálculo automático del estado del presupuesto

#### 3. Importación CSV
- Carga masiva de transacciones desde archivo CSV
- Mapeo flexible de columnas
- Vista previa antes de importar
- Plantilla descargable
- Validación de formato y datos

**Formato CSV:**
```csv
fecha,tipo,categoria,monto,forma_pago,detalle
06/03/2024,Gasto,Comida,15000,Débito,Almuerzo restaurante
```

#### 4. Filtrado y Búsqueda
- Filtro por tipo (Ingreso/Gasto)
- Filtro por categoría
- Búsqueda por texto en detalle

#### 5. Edición Inline
- Modal de edición rápida
- Conversión automática de formato de fechas (DD/MM/YYYY ↔ YYYY-MM-DD)
- Actualización en tiempo real

#### 6. Edición con Vinculación a Presupuesto
- Al editar una transacción de tipo **Gasto**, se puede asociar o desasociar un `debt_id`
- El selector muestra items con saldo pendiente (`monto_pagado < monto_total`) y el item ya vinculado actual
- Si se cambia el tipo a **Ingreso**, se limpia automáticamente la vinculación de presupuesto
- La actualización impacta automáticamente en `monto_pagado` y estado del presupuesto vinculado

### API Endpoints

```
POST   /api/transactions          - Crear transacción
GET    /api/transactions          - Listar todas las transacciones
GET    /api/transactions/{id}     - Obtener transacción específica
PUT    /api/transactions/{id}     - Actualizar transacción
DELETE /api/transactions/{id}     - Eliminar transacción
POST   /api/transactions/import   - Importación masiva CSV
```

### Reglas de Negocio

1. **Vinculación con Presupuesto:**
   - Si `debt_id` presente: `debt.monto_pagado += transaction.monto`
   - Recalcular estado: Si `monto_pagado >= monto_total` → Estado = PAGADA
   - Si `monto_pagado > 0 && < monto_total` → Estado = Pago parcial

2. **Eliminación:**
   - Si transacción vinculada a presupuesto: decrementar `monto_pagado`
   - Recalcular estado del presupuesto
   - Recargar datos completos en frontend

3. **Validación:**
   - Monto > 0
   - Fecha no puede ser futura (opcional)
   - Categoría debe existir en lista predefinida

---

## B. Módulo de Presupuesto

### Objetivo
Gestionar compromisos financieros (préstamos, tarjetas de crédito, servicios recurrentes) con seguimiento de pagos y estados.

### Modelo de Datos

```python
Debt (BudgetItem actual):
  id: int                      # Identificador único
  fecha: string                # Fecha de creación (DD/MM/YYYY)
  tipo: string                 # Préstamo | Tarjeta | Servicio | Otro
  categoria: string            # Categoría del commitment
  monto_total: float           # Monto total del compromiso
  monto_pagado: float          # Monto pagado hasta el momento (auto-calculado)
  detalle: string              # Descripción del item
  fecha_vencimiento: string    # Fecha límite de pago
  status: enum                 # Estado actual del item
  created_at: datetime         # Creación en sistema
  updated_at: datetime         # Última modificación
```

### Enumeraciones

```python
DebtStatus:
  PENDIENTE = "PENDIENTE"            # No vencido, sin pagar
  PAGO_PARCIAL = "Pago parcial"      # Pagado parcialmente
  PAGADA = "PAGADA"                  # Pagado completamente
  VENCIDA = "VENCIDA"                # Vencido sin pagar
```

### Funcionalidades Implementadas

#### 1. Dashboard de Resumen
Tarjetas con estadísticas por estado:
- **Pendiente:** Items no vencidos sin pagar (badge gris)
- **Pago Parcial:** Pagos incompletos (badge azul)
- **Vencidas:** Items vencidos (badge rojo)
- **Pagadas:** Completadas (badge verde)

Cada card muestra:
- Cantidad de items
- Monto total pendiente
- Monto total del estado

#### 2. Tabla de Items
Columnas:
- Fecha
- Tipo
- Categoría
- Detalle
- Monto Total
- Pagado
- Progreso (barra visual)
- Estado (badge)
- Vencimiento
- Acciones (Editar/Eliminar)

#### 3. Cálculo Automático de Estado

**Reglas:**
```python
if monto_pagado >= monto_total:
    status = PAGADA
elif monto_pagado > 0:
    status = PAGO_PARCIAL
elif fecha_vencimiento < hoy:
    status = VENCIDA
else:
    status = PENDIENTE
```

#### 4. Progreso Visual
- Barra de progreso: `(monto_pagado / monto_total) * 100%`
- Color:
  - Verde: >= 75%
  - Amarillo: 25-74%
  - Rojo: < 25%

#### 5. Validación de Eliminación
- No permite eliminar si tiene transacciones vinculadas
- Mensaje: "No se puede eliminar: hay X transacción(es) vinculada(s). Elimínelas primero."
- HTTP 400 con detalle

#### 6. Campo monto_pagado
- **Solo lectura** en formulario de edición
- Calculado automáticamente por suma de transacciones vinculadas
- Estilo: `bg-gray-50 cursor-not-allowed`

#### 7. Exportación CSV de Presupuestos
- Botón **Exportar CSV** en el módulo de Presupuesto
- Exporta todos los items visibles en la tabla con columnas:
  - `id`, `fecha`, `tipo`, `categoria`, `detalle`
  - `monto_total`, `monto_pagado`, `monto_pendiente`, `progreso_pct`
  - `status`, `fecha_vencimiento`
- Compatible con Excel (UTF-8 BOM)

### API Endpoints

```
POST   /api/debts              - Crear item de presupuesto
GET    /api/debts              - Listar todos los items
GET    /api/debts/summary      - Resumen con montos por estado
GET    /api/debts/{id}         - Obtener item específico
PUT    /api/debts/{id}         - Actualizar item
DELETE /api/debts/{id}         - Eliminar item (valida transacciones)
```

### Cálculo de Resumen

```python
GET /api/debts/summary:
{
  "pending_count": int,
  "pending_amount": float,      # SUM(monto_total - monto_pagado) WHERE status=PENDIENTE
  "partial_count": int,
  "partial_amount": float,      # SUM(monto_total - monto_pagado) WHERE status=PAGO_PARCIAL
  "overdue_count": int,
  "overdue_amount": float,      # SUM(monto_total - monto_pagado) WHERE status=VENCIDA
  "paid_count": int,
  "total_count": int
}
```

---

## C. Módulo de Reportes

### Objetivo
Visualizar, analizar y filtrar transacciones financieras con gráficos interactivos.

### Funcionalidades Implementadas

#### 1. Tarjetas de Resumen
- **Total Ingresos:** Suma de todos los ingresos
- **Total Gastos:** Suma de todos los gastos
- **Balance:** Ingresos - Gastos (color verde/rojo según signo)

#### 2. Gráficos

**Gráfico de Torta: Gastos por Categoría**
- Muestra distribución de gastos
- Solo gastos (filtra tipo=Gasto)
- Colores diferenciados por categoría
- Interactivo (hover muestra monto y porcentaje)

**Gráfico de Barras: Balance por Fecha**
- Eje X: Fechas únicas
- Eje Y: Balance (ingresos - gastos) para cada fecha
- Barras verdes: balance positivo
- Barras rojas: balance negativo

#### 3. Sistema de Filtros Avanzados

**Grid de 5 columnas:**
1. **Filtro por Tipo:** Todos | Ingresos | Gastos
2. **Filtro por Categoría:** Todas | [lista de categorías únicas]
3. **Filtro por Presupuesto:**
   - Todas
   - 📊 Vinculadas (solo con debt_id)
   - ⭕ No vinculadas (sin debt_id)
   - **[Lista de presupuestos específicos]** (filtrar por debt_id exacto)
4. **Ordenar por:** Fecha | Tipo | Categoría | Monto
5. **Orden:** Ascendente | Descendente

#### 4. Tabla de Transacciones

**Columnas:**
- Fecha (DD/MM/YYYY)
- Tipo (badge Ingreso/Gasto)
- Categoría
- Monto (formato ARS)
- Detalle
- **Presupuesto** (badge 📊 Vinculado si tiene debt_id)
- Acciones (Editar/Eliminar)

**Acciones:**
- ✏️ Editar: Modal con conversión de fechas
- 🗑️ Eliminar: Dialog de confirmación

#### 5. Botón "Limpiar Filtros"
Resetea todos los filtros a valores por defecto:
- Tipo: all
- Categoría: all
- Presupuesto: all
- Orden: fecha desc

#### 6. Exportación CSV de Reportes
- Botón **Exportar CSV** en la tabla de transacciones del módulo Reportes
- Exporta el resultado **filtrado y ordenado** actual
- Incluye columnas: `fecha`, `tipo`, `categoria`, `monto`, `necesidad`, `forma_pago`, `partida`, `detalle`, `debt_id`, `presupuesto`
- Mantiene formato de fecha legible y compatibilidad con Excel

### Lógica de Filtrado

```javascript
 filtered = transactions

// Filtro por tipo
if (filterType !== 'all')
  filtered = filtered.filter(t => t.tipo === filterType)

// Filtro por categoría
if (filterCategory !== 'all')
  filtered = filtered.filter(t => t.categoria === filterCategory)

// Filtro por presupuesto
if (filterBudget === 'vinculado')
  filtered = filtered.filter(t => t.debt_id !== null)
else if (filterBudget === 'no_vinculado')
  filtered = filtered.filter(t => t.debt_id === null)
else if (filterBudget !== 'all')
  const debtId = parseInt(filterBudget)
  filtered = filtered.filter(t => t.debt_id === debtId)
```

### Dropdown de Presupuestos

```jsx
<select value={filterBudget} onChange={...}>
  <option value="all">Todas</option>
  <option value="vinculado">📊 Vinculadas</option>
  <option value="no_vinculado">⭕ No vinculadas</option>
  {debts.length > 0 && (
    <optgroup label="Por Presupuesto">
      {debts.map(debt => (
        <option key={debt.id} value={debt.id}>
          {debt.detalle} - ${debt.monto_total}
        </option>
      ))}
    </optgroup>
  )}
</select>
```

---

## D. Módulo de Administración

### Objetivo
Gestionar la configuración del sistema, sincronización y seguridad.

### Funcionalidades Implementadas

#### 1. Sistema de Autenticación

**Roles:**
- **Admin:** Acceso completo (CRUD, sincronización, gestión usuarios)
- **Writer:** Crear/editar transacciones propias, ver reportes
- **Reader:** Solo lectura (dashboards y reportes)

**Usuarios por Defecto:**
```
admin / admin123     - Rol: Admin
writer / writer123   - Rol: Writer
reader / reader123   - Rol: Reader
```

**Seguridad:**
- JWT tokens con expiración configurable (default: 30 min)
- Contraseñas hasheadas con bcrypt
- CORS configurado para origen específico
- Middleware de autenticación en todas las rutas protegidas

**API Endpoints:**
```
POST /api/login          - Autenticación
POST /api/logout         - Cierre de sesión
GET  /api/me             - Obtener usuario actual
```

#### 2. Sincronización PostgreSQL ↔ Google Sheets

**Direcciones:**
- **Sheets → PostgreSQL:** Importar desde Google Sheets
- **PostgreSQL → Sheets:** Exportar a Google Sheets

**Modos:**
- **Normal:** Solo agrega transacciones nuevas (sin duplicados)
- **Forzada:** Limpia destino y recarga completamente

**Detección de Duplicados:**
Huella digital: `sha256(fecha + monto + categoria + detalle)`

**Panel de Admin:**
- Selector de dirección y modo
- Botón "Sincronizar ahora"
- Indicadores de estado (última sincronización)
- Estadísticas: agregados, omitidos, totales

**API Endpoint:**
```
POST /api/sync-sheets    - Ejecutar sincronización
  Body: {
    "direction": "sheets_to_postgres" | "postgres_to_sheets",
    "mode": "normal" | "force"
  }
  Response: {
    "added": int,
    "skipped": int,
    "total": int
  }
```

#### 3. Gestión de Categorías

**Categorías Predefinidas:**
- Comida
- Transporte
- Salud
- Educación
- Entretenimiento
- Servicios
- Otro

**API Endpoint:**
```
GET /api/categories      - Listar categorías
```

#### 4. Variables de Configuración

**Backend (.env):**
```env
SECRET_KEY=your-secret-key-min-32-chars
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
DATABASE_URL=postgresql://user:pass@host:port/db
GOOGLE_SHEET_ID=your-sheet-id
GOOGLE_CREDENTIALS_FILE=credentials.json
FRONTEND_URL=http://localhost:3000
```

**Frontend:**
- API URL configurable
- Modo de desarrollo/producción
- Timeouts de petición

---

## E. Utilidades y Componentes Comunes

### 1. Sistema de Notificaciones (Toasts)

**Context Provider:**
```jsx
ToastProvider wraps entire app
Methods: success(), error(), warning(), info()
```

**Características:**
- Posicionamiento fijo (top-right)
- Auto-dismiss (5 segundos)
- Colores según tipo
- Iconos visuales
- Stack de múltiples toasts

**Uso:**
```javascript
const { success, error } = useToast();
success("Transacción creada exitosamente");
error("Error al eliminar el item");
```

### 2. Utilidades de Fechas (dateUtils.js)

```javascript
// Convierte cualquier formato a DD/MM/YYYY
formatDate(dateString): string

// Convierte a YYYY-MM-DD (para inputs HTML)
toISODate(dateString): string
```

**Lógica:**
- Detección automática de formato con regex
- Maneja: DD/MM/YYYY, YYYY-MM-DD, ISO timestamps
- Previene errores en inputs de tipo date

### 3. Componentes Reutilizables

**ConfirmDialog:**
- Modal de confirmación genérico
- Props: isOpen, message, onConfirm, onCancel
- Usado en eliminaciones

**Modal:**
- Overlay con blur
- Animaciones de entrada/salida
- Click outside para cerrar

**Toast:**
- Notificación individual
- Auto-remove con timer
- Iconos por tipo

### 4. Formateo de Datos

**Moneda (ARS):**
```javascript
monto.toLocaleString('es-AR', { minimumFractionDigits: 2 })
// Output: 1.500,00
```

**Fechas:**
```javascript
formatDate("2024-03-15")  // Output: 15/03/2024
```

**Porcentajes:**
```javascript
`${((monto_pagado / monto_total) * 100).toFixed(1)}%`
```

### 5. Exportación CSV Reutilizable (csvExport.js)

Utilidad compartida para generar descargas CSV desde múltiples módulos:

```javascript
exportToCsv({ filename, headers, rows })
```

**Características:**
- Escapado de comillas, comas y saltos de línea
- UTF-8 BOM para correcta apertura en Excel
- Reutilizada en:
  - Módulo de Reportes
  - Módulo de Presupuesto

---

## F. Widget de Forecast Balance (Balance Pendiente)

### Objetivo
Mostrar proyección financiera considerando presupuestos pendientes. Responde la pregunta: **"¿Cuánto dinero me quedaría si pago todos mis compromisos presupuestados?"**

### Ubicación
Dashboard principal (DashboardOverview.jsx) - 4to widget en grid de 5 columnas.

### Cálculo

```javascript
// Presupuesto Pendiente = suma de todos los items no pagados
presupuestoPendiente = 
  debtSummary.pending_amount +     // Items PENDIENTE
  debtSummary.partial_amount +     // Items PAGO_PARCIAL
  debtSummary.overdue_amount       // Items VENCIDA

// Balance Pendiente = lo que quedaría si pago todo
balancePendiente = ingresos - (gastos + presupuestoPendiente)
```

### Implementación Técnica

**Estado:**
```javascript
const [debtSummary, setDebtSummary] = useState(null);
```

**Carga de Datos:**
```javascript
useEffect(() => {
  const loadDebtSummary = async () => {
    const response = await debtsAPI.getDebtSummary();
    setDebtSummary(response.data);
  };
  loadDebtSummary();
}, [transactions]);
```

**API Endpoint:**
```
GET /api/debts/summary
Response: {
  "pending_amount": float,    // Suma de items PENDIENTE
  "partial_amount": float,    // Suma de items PAGO_PARCIAL
  "overdue_amount": float,    // Suma de items VENCIDA
  "paid_amount": float        // Suma de items PAGADA
}
```

### UI/UX

**Card Widget:**
- **Título:** "Balance Pendiente"
- **Valor:** Monto formateado con color condicional
  - Verde (text-finly-income) si ≥ 0
  - Rojo (text-finly-expense) si < 0
- **Subtítulo:** "Si se paga todo el presupuesto"
- **Icono:** 🎯
- **Background:** 
  - purple-100 si balance positivo
  - yellow-100 si balance negativo

**Formato de Monto:**
```javascript
balancePendiente.toLocaleString('es-AR', { minimumFractionDigits: 2 })
// Output: $150.000,50
```

### Ejemplo de Uso

```
Ingresos del mes:      $200.000
Gastos independientes:  $50.000
Gastos vinculados:      $20.000 (pagos parciales a presupuestos)

Gastos totales:         $70.000

Presupuestos pendientes:
  - Alquiler (PENDIENTE):     $40.000
  - Tarjeta (PAGO_PARCIAL):   $30.000 (falta pagar)
  - Seguro (VENCIDA):         $10.000

Presupuesto Pendiente: $80.000

Balance actual:    200.000 - 70.000 = $130.000  (lo que tengo hoy)
Balance Pendiente: 200.000 - (70.000 + 80.000) = $50.000  (lo que me quedaría)
```

### Actualización Automática

El widget se recalcula automáticamente cuando:
- Se crea/edita/elimina una transacción
- Se modifica un item de presupuesto
- Se vincula/desvincula una transacción a presupuesto

**Trigger:** Dependency en `useEffect` sobre `[transactions]`

### Beneficios

- **Visibilidad:** Usuario ve su situación financiera real considerando compromisos
- **Alertas tempranas:** Si Balance Pendiente es negativo, hay riesgo de insolvencia
- **Planificación:** Ayuda a decidir si puede asumir nuevos compromisos
- **Forecast simple:** Proyección básica sin necesidad de configuración compleja

---

# PARTE II: ROADMAP DE EVOLUCIÓN

## Diferencia: Sistema Actual vs. Roadmap

**Sistema Actual (Implementado):**
- Rastrea compromisos financieros existentes
- Registra pagos realizados
- Calcula progreso sobre deudas reales

**Roadmap (Planificado):**
- Planifica flujos de caja futuros
- Proyecta balances esperados
- Forecast financiero con escenarios

---

# 1. Conceptual Model

A **BudgetItem** represents an **expected future cash flow**.

It can represent either:

- money that **will be paid** (expense)
- money that **will be received** (income)

Examples:

| Description | Amount | Flow Type |
|---|---|---|
Salary | 2500 | Income |
Rent | 500 | Expense |
Internet | 40 | Expense |
Freelance payment | 200 | Income |

The Budget module therefore supports **financial forecasting** and feeds data to the system dashboards.

---

# 2. BudgetItem Data Model

All budget items are stored in **a single table**.

```text
BudgetItem
-----------
id
description
amount
flow_type
category_id
due_date
estimated
status
linked_expense_id
linked_income_id
source_budget_id
created_at
updated_at

Field description
Field	Description
id	Unique identifier
description	Text description
amount	Monetary value
flow_type	Direction of money flow (Income or Expense)
category_id	Category reference
due_date	Optional expected payment/receipt date
estimated	Boolean indicating forecast estimate
status	Budget status
linked_expense_id	Expense created from this budget item
linked_income_id	Income created from this budget item
source_budget_id	Reference when cloned from another item
created_at	Creation timestamp
updated_at	Update timestamp
3. Cash Flow Type

The direction of the money flow is modeled using an enum.

enum CashFlowType
{
    Income,
    Expense
}

Meaning:

Value	Meaning
Income	Money expected to be received
Expense	Money expected to be paid
4. Budget Status

Budget items can move through several lifecycle states.

enum BudgetStatus
{
    Pending,
    Completed,
    Expired,
    Cancelled
}

Meaning:

Status	Description
Pending	Planned but not yet executed
Completed	Converted into real expense or income
Expired	Past due date and not executed
Cancelled	Manually cancelled

5. Budget Forecast Balance

The system must compute a financial forecast balance.

Definition:

BalanceForecast =
    RealIncomes
    + PendingIncomeBudgets
    - RealExpenses
    - PendingExpenseBudgets

This value represents:

The expected financial balance if all planned budgets occur.

A dashboard widget called Budget Forecast Balance must display this value.

Example:

Concept	Amount
Real incomes	2500
Real expenses	900
Pending income budgets	200
Pending expense budgets	800

Forecast balance:

2500 + 200 - 900 - 800 = 1000

6. Budget Visual Status Indicators

The UI should highlight budget items based on their status.

Condition	Color
Pending and not expired	Gray
Expired and not completed	Red
Completed	Green

Expiration rule:

if due_date < today AND status == Pending
    status = Expired
7. Monthly Budget Cloning

- The Budget module must support cloning budgets to the next month.
- Two operations are required.

7.1 Clone entire monthly budget

The user may clone all budget items to the next month.

Rules:

- new items are created
- due_date moves to next month
- source_budget_id references original item
- status resets to Pending

Date rule:

new_day = min(original_day, last_day_of_next_month)

Example:

31 Jan → 28 Feb
7.2 Move individual items to next month

Users may postpone specific budget items to the next month.

Use cases:

- delayed payment
- postponed purchase
- invoice paid later

Rules:

- selected items are copied to next month
- original item may be marked Cancelled or remain as historical record
- due_date adjusted to next month

8. Budget Import via CSV

The Budget module must reuse the existing bulk CSV import component used for Expenses.

Implementation requirements:

- reuse the same UI component
- create a mapping layer to transform CSV rows into BudgetItem records

Example CSV:

description,amount,flow_type,category,due_date
Rent,500,Expense,Housing,2026-04-05
Salary,2500,Income,Work,2026-04-01

9. Advanced Financial Planning Features

The Budget module must support future financial planning capabilities.

9.1 Automatic monthly planning

Users should be able to generate monthly budgets automatically based on:

- previous months
- recurring patterns
- cloned budgets

9.2 Daily balance projection

The system should be able to compute expected daily balance evolution.

Concept:

daily_balance = current_balance
              + incomes_until_date
              - expenses_until_date
              - pending_budget_until_date

Example output:

Date	Forecast Balance
1	1200
10	900
15	1500
30	800
9.3 Financial alerts

The system should support alerts such as:

- budget expiring soon
- overdue budgets
- forecast balance turning negative

Example rule:

if due_date - today <= 3 days
    trigger alert
9.4 Budget deviation analysis

The system must allow comparison between planned vs real spending.

Formula:

variance = real_amount - budget_amount

Example:

Budget	Actual	Variance
100	120	+20

Positive values indicate overspending.

Summary

The Budget module provides:

- planning of future expenses and incomes
- forecast financial balance
- cloning and postponing budget items

CSV import

- financial alerts
- deviation analysis
- daily balance projections
- monthly financial planning

This design enables Finly to function as a financial planning system, not only a transaction tracker.

---

# ROADMAP DE IMPLEMENTACIÓN

## Fase 1: Migración del Modelo de Datos + Forecast Balance (Sprint 4.1)

### Tareas Backend:
- [ ] Crear tabla `budget_items` con campos especificados
- [ ] Migrar datos existentes de tabla `debts` a `budget_items`
- [ ] Agregar campos: `flow_type`, `estimated`, `linked_expense_id`, `linked_income_id`, `source_budget_id`
- [ ] Crear enums: `CashFlowType` (Income/Expense), `BudgetStatus` (Pending/Completed/Expired/Cancelled)
- [ ] Actualizar endpoints API para usar nuevo modelo
- [ ] Mantener compatibilidad con endpoints existentes `/api/debts`

### Tareas Frontend:
- [ ] Actualizar DTOs/interfaces TypeScript
- [ ] Modificar componente `DebtManager` → `BudgetPlanner`
- [ ] Agregar selector de tipo de flujo (Ingreso/Gasto)
- [ ] Nueva UI para items estimados vs confirmados

### ✅ Forecast Balance Dashboard (COMPLETADO)
- [x] Widget "Balance Pendiente" en Dashboard
- [x] Fórmula: `Balance Pendiente = Ingresos - (Gastos + Presupuesto Pendiente)`
- [x] Integración con `debtsAPI.getDebtSummary()`
- [x] UI: Grid de 5 columnas, icono 🎯, colores condicionales
- [x] Actualización automática con cambios en transacciones
- [x] **Ver detalles:** PARTE I - Sección F. Widget de Forecast Balance

**Estimación:** 5 días (3-5 migración + forecast ya completado)  
**Criterio de éxito:** Migración sin pérdida de datos, endpoints funcionando, forecast balance operativo ✅

---

## Fase 2: Importación CSV de Presupuestos (Sprint 4.2) ✅ COMPLETADO

### Funcionalidad:
Cargar presupuestos masivamente desde CSV, reutilizando componente similar a importación de transacciones.

### ✅ Implementación Completada:
- [x] **Back end:** Endpoint `POST /api/debts/import-csv`
  - Valida y procesa lista de items de presupuesto
  - Importación en batch con manejo de errores individual
  - Retorna estadísticas: `{added, total, errors[]}`
  - Requiere autenticación (roles: admin, writer)
  - Maneja errores por fila sin detener importación completa

- [x] **Frontend:** Componente `BudgetCSVImport.jsx`
  - Drag & drop o selección de archivo CSV
  - Mapeo flexible de columnas con preview
  - Campos requeridos: detalle, monto_total, fecha_vencimiento
  - Campos opcionales: tipo, categoría
  - Plantilla descargable con ejemplos
  - Vista previa de primeros 5 items
  - Formateo automático de montos (AR y US)
  - Integrado en DebtManager con botón "📥 Importar CSV"

### Plantilla CSV Incluida:
```csv
detalle,monto_total,tipo,categoria,fecha_vencimiento
Alquiler,50000,Vivienda,Alquiler,2024-04-05
Tarjeta Visa,120000,Tarjeta,Crédito,2024-04-10
Internet,4000,Servicio,Servicios,2024-04-15
Salario,250000,Ingreso,Trabajo,2024-04-30
```

### Validaciones Implementadas:
- Monto: Parseo de formatos argentino (12.981,50) y americano (12,981.50)
- Monto > 0 (valida por fila)
- Campos requeridos: detalle, monto_total, fecha_vencimiento
- Estado inicial: PENDIENTE
- Monto pagado inicial: 0.0

**Estimación:** 2 días  
**Tiempo real:** ~3 horas ⚡  
**Criterio de éxito:** ✅ Importación masiva funcional, errores manejados individualmente, UI intuitiva

---

## Fase 3: Clonación Mensual de Presupuestos (Sprint 4.3)

### Funcionalidad:
Copiar presupuestos mensuales recurrentes (salario, alquiler, servicios) al mes siguiente.

### Implementación:
- [ ] Backend: Endpoint `POST /api/budget/clone-month`
  - Parámetros: `source_month`, `target_month`
  - Copiar items con `estimated=true` del mes origen
  - Actualizar `due_date` al nuevo mes (preservar día)
  - Establecer `source_budget_id` apuntando al original
  - Resetear status a `Pending`
  - Limpiar `linked_expense_id` y `linked_income_id`
- [ ] Frontend: Botón "Clonar presupuesto del mes anterior"
  - Selector de mes origen/destino
  - Tabla de preview con items a clonar
  - Confirmación antes de ejecutar
  - Indicador de progreso

### Regla de Ajuste de Fechas:
```python
new_day = min(original_day, last_day_of_target_month)
# Ejemplo: 31 Ene → 28 Feb (o 29 si bisiesto)
```

### Preview de Clonación:
```
Items a clonar del mes 03/2024 al mes 04/2024:

✓ Salario - $250.000 (Ingreso) → 30/04/2024
✓ Alquiler - $50.000 (Gasto) → 05/04/2024
✓ Internet - $4.000 (Gasto) → 10/04/2024

Total a clonar: 3 items
```

**Estimación:** 2-3 días

---

## Fase 4: Vinculación Automática Presupuesto ↔ Transacciones (Sprint 4.4)

### Funcionalidad:
Al registrar una transacción, marcar el item de presupuesto correspondiente como "Completed" automáticamente.

### Implementación:
- [ ] Backend: Mejorar `POST /api/transactions`
  - Si existe `linked_budget_id` manual:
    - Actualizar `budget_item.status = Completed`
    - Establecer `budget_item.linked_expense_id` o `linked_income_id`
  - **Auto-match por similaridad:**
    - Buscar presupuestos pendientes con descripción similar (fuzzy matching)
    - Umbral: similitud > 80%
    - Cantidad cercana (±10%)
    - Sugerir al usuario antes de vincular
- [ ] Frontend: Selector de "¿Cumplir item de presupuesto?" al crear transacción
  - Dropdown de sugerencias automáticas
  - Mostrar score de similitud
  - Opción de "No vincular"

### Algoritmo de Auto-Match:
```python
from difflib import SequenceMatcher

def find_matching_budget(transaction):
    pending_budgets = get_budgets(status='Pending', flow_type=transaction.tipo)
    
    matches = []
    for budget in pending_budgets:
        similarity = SequenceMatcher(None, 
                                     transaction.detalle.lower(), 
                                     budget.description.lower()).ratio()
        
        amount_diff = abs(transaction.monto - budget.amount) / budget.amount
        
        if similarity > 0.8 and amount_diff < 0.1:
            matches.append({
                'budget': budget,
                'similarity': similarity,
                'confidence': similarity * (1 - amount_diff)
            })
    
    return sorted(matches, key=lambda x: x['confidence'], reverse=True)
```

**Estimación:** 3-4 días

---

## Fase 5: Alertas Financieras (Sprint 4.5)

### Funcionalidad:
Notificaciones proactivas cuando:
- Presupuesto cercano a vencimiento (3 días antes)
- Balance proyectado se vuelve negativo
- Gasto real supera presupuesto planificado de una categoría

### Implementación:
- [ ] Backend: Job scheduler (APScheduler)
  - Ejecutar diariamente a medianoche
  - Crear tabla `alerts` (id, user_id, type, message, severity, created_at, read)
  - Tipos: `budget_expiring`, `forecast_negative`, `overspending`
- [ ] Backend: Endpoint `GET /api/alerts`
  - Filtrar por usuario autenticado
  - Ordenar por fecha desc
  - Marcar como leído: `PUT /api/alerts/{id}/read`
- [ ] Frontend: Badge de notificaciones en Navbar
  - Contador de alertas no leídas
  - Panel desplegable con lista
  - Iconos según severidad (⚠️ warning, 🔴 error, ℹ️ info)

### Reglas de Alertas:

**1. Presupuesto próximo a vencer:**
```python
if budget.due_date - today <= 3 days AND budget.status == 'Pending':
    create_alert(
        type='budget_expiring',
        message=f'Presupuesto "{budget.description}" vence en {days_left} días',
        severity='warning'
    )
```

**2. Balance proyectado negativo:**
```python
forecast = calculate_forecast_balance()
if forecast < 0:
    create_alert(
        type='forecast_negative',
        message=f'Balance proyectado negativo: ${forecast}',
        severity='error'
    )
```

**3. Sobre-gasto por categoría:**
```python
for category in categories:
    budgeted = sum(budget where category=cat AND flow_type=Expense)
    spent = sum(transactions where category=cat AND tipo=Gasto)
    
    if spent > budgeted:
        create_alert(
            type='overspending',
            message=f'Sobre-gasto en {category}: ${spent - budgeted}',
            severity='warning'
        )
```

**Estimación:** 4 días

---

## Fase 6: Análisis de Desviación (Sprint 4.6)

### Funcionalidad:
Comparar gasto/ingreso real vs presupuestado por categoría, mostrando varianza y porcentaje de desviación.

### Implementación:
- [ ] Backend: Endpoint `GET /api/budget/deviation-analysis`
  - Parámetros: `start_date`, `end_date`, `category` (opcional)
  - Agrupar por categoría
  - Calcular por categoría:
    - `budgeted`: Suma de budget_items con flow_type
    - `actual`: Suma de transacciones reales
    - `variance`: actual - budgeted
    - `variance_pct`: (variance / budgeted) * 100
  - Retornar JSON con array de categorías
- [ ] Frontend: Página de análisis "Budget vs Real"
  - Tabla comparativa con columnas:
    - Categoría
    - Presupuestado
    - Real
    - Varianza ($)
    - Varianza (%)
    - Estado (badge)
  - Gráfico de barras agrupadas (presupuestado vs real)
  - Filtro por rango de fechas
  - Indicadores de color:
    - 🟢 Verde: dentro del presupuesto (variance ≤ 0%)
    - 🟡 Amarillo: sobre presupuesto 0-10%
    - 🔴 Rojo: sobre presupuesto > 10%

### Ejemplo de Respuesta API:
```json
{
  "period": {
    "start": "2024-03-01",
    "end": "2024-03-31"
  },
  "categories": [
    {
      "name": "Comida",
      "budgeted": 50000,
      "actual": 58000,
      "variance": 8000,
      "variance_pct": 16.0,
      "status": "overspent"
    },
    {
      "name": "Transporte",
      "budgeted": 20000,
      "actual": 18000,
      "variance": -2000,
      "variance_pct": -10.0,
      "status": "underspent"
    }
  ],
  "summary": {
    "total_budgeted": 200000,
    "total_actual": 215000,
    "total_variance": 15000,
    "total_variance_pct": 7.5
  }
}
```

**Estimación:** 3 días

---

## Fase 7: Proyección Diaria de Balance (Sprint 4.7)

### Funcionalidad:
Gráfico de línea mostrando balance proyectado día a día para los próximos 30/60/90 días.

### Implementación:
- [ ] Backend: Endpoint `GET /api/budget/daily-projection`
  - Parámetros: `days_ahead` (default: 30)
  - Para cada día futuro:
    - Balance inicial = balance actual
    - Por cada día: sumar ingresos esperados - gastos esperados donde `due_date = día`
    - Acumular balance
  - Retornar array de objetos: `{ date, projected_balance, incomes, expenses }`
- [ ] Frontend: Gráfico de línea en Dashboard o página dedicada
  - Biblioteca: Chart.js (Line chart)
  - Eje X: Fechas (DD/MM)
  - Eje Y: Balance ($)
  - Líneas:
    - Balance proyectado (azul)
    - Balance actual (punto inicial verde)
    - Línea de referencia en 0 (roja punteada)
  - Tooltip: Mostrar detalles por día (ingresos, gastos, balance)
  - Selector de período: 30, 60, 90 días

### Cálculo:
```python
def calculate_daily_projection(days_ahead=30):
    today = date.today()
    current_balance = get_current_balance()  # incomes - expenses reales
    
    projection = []
    accumulated_balance = current_balance
    
    for i in range(days_ahead + 1):
        target_date = today + timedelta(days=i)
        
        # Ingresos/gastos presupuestados para este día
        daily_incomes = sum(budget where due_date=target_date AND flow_type=Income)
        daily_expenses = sum(budget where due_date=target_date AND flow_type=Expense)
        
        accumulated_balance += daily_incomes - daily_expenses
        
        projection.append({
            'date': target_date,
            'balance': accumulated_balance,
            'incomes': daily_incomes,
            'expenses': daily_expenses
        })
    
    return projection
```

### Ejemplo de Gráfico:
```
Balance Proyectado - Próximos 30 días

  $300k ┤                                    ╭─────
  $250k ┤                          ╭─────────╯      
  $200k ┤               ╭──────────╯                
  $150k ┤    ╭──────────╯                           
  $100k ┤────╯                                      
   $50k ┤                                           
    $0  ┼━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ (línea de 0)
        └───────────────────────────────────────────
        HOY  +5   +10  +15  +20  +25  +30

        🟢 = Balance actual
        🔵 = Proyección
        🔴 = Zona crítica (balance < 0)
```

**Estimación:** 3 días

---

## Resumen de Prioridades (Actualizado)

| Fase | Funcionalidad | Prioridad | Estimación | Sprint | Estado |
|------|--------------|-----------|------------|---------|--------|
| 1 | Migración de modelo de datos + Forecast Balance | 🔴 Alta | 5 días | 4.1 | 🟡 **Parcial** (Forecast ✅) |
| **2** | **Importación CSV de Presupuestos** | 🔴 Alta | 2 días | **4.2** | ✅ **Completado** |
| 3 | Clonación mensual | 🟡 Media | 3 días | 4.3 | ⬜ Pendiente |
| 4 | Vinculación automática | 🟡 Media | 3-4 días | 4.4 | ⬜ Pendiente |
| 5 | Alertas financieras | 🟢 Baja | 4 días | 4.5 | ⬜ Pendiente |
| 6 | Análisis de desviación | 🟢 Baja | 3 días | 4.6 | ⬜ Pendiente |
| 7 | Proyección diaria | 🟡 Media | 3 días | 4.7 | ⬜ Pendiente |

**Total estimado:** 24 días de desarrollo (~5 semanas)

**Progreso:**
- 🟡 **Fase 1 (Parcial):** Forecast Balance Dashboard completado ✅
  - Widget "Balance Pendiente" implementado en dashboard
  - Fórmula: `Balance Pendiente = Ingresos - (Gastos + Presupuesto Pendiente)`
  - Integración con `debtsAPI.getDebtSummary()`
  - UI actualizada con 5 columnas en grid
  - **Pendiente:** Migración del modelo de datos a `budget_items`
- ✅ **Fase 2 (Completada):** Importación CSV de Presupuestos operativa
  - Endpoint `POST /api/debts/import-csv` implementado y protegido por roles
  - Componente `BudgetCSVImport.jsx` integrado en Presupuesto
  - Manejo de errores por fila y respuesta con estadísticas de importación
  - Soporte de codificación UTF-8/Windows-1252 para preservar acentos y caracteres especiales

**Siguiente paso:**
- 🎯 **Fase 3: Clonación mensual de presupuestos** - Reutilizar presupuestos recurrentes para acelerar la planificación

---

## Notas de Implementación

### Compatibilidad:
- Mantener endpoints actuales `/api/debts` funcionando durante migración
- Crear alias: `/api/debts` → `/api/budget` (deprecar `/debts` en v2.0)
- Migración debe ser transparente para usuarios existentes
- Preservar datos históricos en `debts` como tabla legacy

### Testing:
- Crear datos de prueba para cada fase
- Validar cálculos de forecast en diferentes escenarios:
  - Solo ingresos presupuestados
  - Solo gastos presupuestados
  - Mix de ingresos/gastos/transacciones reales
  - Presupuestos vencidos vs pendientes
- Tests de regresión para endpoints existentes

### Migración de Datos:
```sql
-- Script de migración debts → budget_items
INSERT INTO budget_items (
  description, amount, flow_type, category_id, due_date, 
  status, created_at, updated_at
)
SELECT 
  detalle as description,
  monto_total as amount,
  'Expense' as flow_type,  -- Actual modelo solo maneja gastos
  categoria as category_id,
  fecha_vencimiento as due_date,
  CASE 
    WHEN status = 'PAGADA' THEN 'Completed'
    WHEN status = 'VENCIDA' THEN 'Expired'
    ELSE 'Pending'
  END as status,
  created_at,
  updated_at
FROM debts;
```

### Documentación:
- Actualizar `SISTEMA_ACTUAL.md` después de cada sprint
- Agregar ejemplos de uso a README.md
- Crear guías de usuario para:
  - Importación CSV de presupuestos
  - Interpretación de forecast balance
  - Uso de alertas financieras
- Actualizar diagrama de arquitectura con nuevos endpoints

### Performance:
- Índices en `budget_items`:
  - `(user_id, due_date)` para proyecciones
  - `(flow_type, status)` para cálculos de forecast
  - `(category_id)` para análisis de desviación
- Cache de forecast balance (TTL: 1 hora)
- Paginación en lista de presupuestos (limit: 50 items)

---

**Última actualización:** 17 de Marzo de 2026  
**Estado:** 🚧 Roadmap en ejecución (Fase 2 completada, Fase 1 parcial)  
**Próximo Sprint:** 4.3 - Clonación Mensual de Presupuestos