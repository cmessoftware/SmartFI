# Fase C - UI Budget Model: Implementación de Interfaz

## 📋 Resumen

Implementación de la interfaz de usuario para soportar el Budget Model Refactor, separando conceptualmente **OBLIGATION** (obligaciones/compromisos) vs **VARIABLE** (presupuesto flexible), con autoasignación de transacciones y nuevos indicadores visuales.

## ✅ Estado: COMPLETADA

**Fecha de implementación:** 2026-03-18

---

## 🎯 Objetivos

1. **Separación conceptual visible**: UI que diferencie OBLIGATION vs VARIABLE
2. **Autoasignación opcional**: Selector de presupuesto no obligatorio, con sugerencias automáticas
3. **Nuevos campos**: tipo_presupuesto, tipo_flujo, monto_ejecutado
4. **Compatibilidad**: Mantener monto_pagado (deprecado) durante transición
5. **UX mejorado**: Indicadores visuales claros (badges, colores, emojis)

---

## 🔧 Cambios Implementados

### 1. DebtManager.jsx - Gestión de Presupuesto

#### Formulario actualizado:

```jsx
const [formData, setFormData] = useState({
  fecha: new Date().toISOString().split('T')[0],
  tipo: 'Préstamo',
  categoria: 'Personal',
  monto_total: '',
  monto_pagado: '0',
  detalle: '',
  fecha_vencimiento: '',
  tipo_presupuesto: 'OBLIGATION',  // ← NUEVO
  tipo_flujo: 'Gasto',             // ← NUEVO
  monto_ejecutado: '0'             // ← NUEVO
});
```

#### Campos nuevos en formulario:

**Tipo de Presupuesto:**
```jsx
<select name="tipo_presupuesto" value={formData.tipo_presupuesto} ...>
  <option value="OBLIGATION">Obligación (Deuda/Compromiso)</option>
  <option value="VARIABLE">Variable (Flexible)</option>
</select>
```

**Tipo de Flujo:**
```jsx
<select name="tipo_flujo" value={formData.tipo_flujo} ...>
  <option value="Gasto">Gasto</option>
  <option value="Ingreso">Ingreso</option>
</select>
```

**Monto Ejecutado (Read-only):**
```jsx
<input
  type="number"
  name="monto_ejecutado"
  value={formData.monto_ejecutado}
  readOnly
  disabled
  className="bg-gray-50 cursor-not-allowed"
  title="Se actualiza automáticamente desde las transacciones"
/>
```

**Monto Pagado (Deprecado):**
```jsx
<input
  type="number"
  name="monto_pagado"
  value={formData.monto_pagado}
  readOnly
  disabled
  className="bg-gray-50 cursor-not-allowed text-gray-400"
  title="Campo en desuso - se sincroniza con monto_ejecutado"
/>
```

---

#### Tabla mejorada con nuevas columnas:

**Headers:**
```jsx
<th>Fecha</th>
<th>Tipo</th>
<th>Presupuesto</th>  {/* ← NUEVO */}
<th>Flujo</th>        {/* ← NUEVO */}
<th>Categoría</th>
<th>Detalle</th>
<th>Monto Total</th>
<th>Ejecutado</th>    {/* ← CAMBIADO de "Pagado" */}
<th>Progreso</th>
<th>Estado</th>
<th>Vencimiento</th>
<th>Acciones</th>
```

**Columna Presupuesto (badges):**
```jsx
<td className="px-4 py-3 text-center">
  <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
    tipoPresupuesto === 'OBLIGATION' 
      ? 'bg-purple-100 text-purple-800' 
      : 'bg-cyan-100 text-cyan-800'
  }`}>
    {tipoPresupuesto === 'OBLIGATION' ? 'Obligación' : 'Variable'}
  </span>
</td>
```

**Columna Flujo (badges con emojis):**
```jsx
<td className="px-4 py-3 text-center">
  <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
    tipoFlujo === 'Gasto' 
      ? 'bg-red-100 text-red-800' 
      : 'bg-green-100 text-green-800'
  }`}>
    {tipoFlujo === 'Gasto' ? '💸 Gasto' : '💰 Ingreso'}
  </span>
</td>
```

**Lógica de monto ejecutado:**
```jsx
const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
const percentage = debt.monto_total > 0 
  ? (montoEjecutado / debt.monto_total) * 100 
  : 0;
const remaining = debt.monto_total - montoEjecutado;
```

---

### 2. TransactionForm.jsx - Formulario de Transacciones

#### Selector mejorado con autosugerencias:

```jsx
{formData.tipo === 'Gasto' && debts.length > 0 && (
  <div className="md:col-span-2">
    <label className="block text-sm font-medium text-finly-text mb-2">
      Asociar a Item de Presupuesto (Opcional)
      {formData.categoria && (
        <span className="ml-2 text-xs font-normal text-blue-600">
          💡 Sugerencia: Busque en categoría "{formData.categoria}"
        </span>
      )}
    </label>
    <select name="debt_id" value={formData.debt_id || ''} ...>
      <option value="">-- Sin asignar (se asignará automáticamente) --</option>
      
      <optgroup label="🎯 Sugeridos por categoría">
        {debts
          .filter(debt => debt.categoria === formData.categoria)
          .map(debt => {
            const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
            const remaining = debt.monto_total - montoEjecutado;
            const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
            const tipoBadge = tipoPresupuesto === 'OBLIGATION' ? '🔴' : '🔵';
            return (
              <option key={debt.id} value={debt.id}>
                {tipoBadge} {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: ${remaining.toFixed(2)}
              </option>
            );
          })}
      </optgroup>
      
      <optgroup label="📋 Otros items de presupuesto">
        {debts
          .filter(debt => debt.categoria !== formData.categoria)
          .map(debt => ...)}
      </optgroup>
    </select>
    
    <p className="text-xs text-finly-textSecondary mt-1">
      🔴 Obligación (Deuda/Compromiso) | 🔵 Variable (Flexible) | 
      Si no selecciona, se asignará automáticamente
    </p>
  </div>
)}
```

---

## 🎨 Diseño Visual

### Badges implementados:

| Campo | Valor | Color | Icono |
|-------|-------|-------|-------|
| **Tipo Presupuesto** | OBLIGATION | 🟣 Púrpura | - |
| **Tipo Presupuesto** | VARIABLE | 🔵 Cyan | - |
| **Tipo Flujo** | Gasto | 🔴 Rojo | 💸 |
| **Tipo Flujo** | Ingreso | 🟢 Verde | 💰 |
| **Selector** | OBLIGATION | - | 🔴 |
| **Selector** | VARIABLE | - | 🔵 |

### Colores Tailwind:

```css
/* OBLIGATION - Púrpura */
bg-purple-100 text-purple-800

/* VARIABLE - Cyan */
bg-cyan-100 text-cyan-800

/* Gasto - Rojo */
bg-red-100 text-red-800

/* Ingreso - Verde */
bg-green-100 text-green-800
```

---

## 📊 Flujo de Usuario

### Crear Item de Presupuesto:

1. Usuario abre formulario "Nuevo Item"
2. Selecciona **Tipo de Presupuesto**: OBLIGATION o VARIABLE
3. Selecciona **Tipo de Flujo**: Gasto o Ingreso
4. Completa monto_total, categoría, detalle, etc.
5. Sistema inicializa monto_ejecutado = 0
6. Backend sincroniza monto_pagado = monto_ejecutado (compatibilidad)

### Crear Transacción (con autosugerencias):

1. Usuario carga gasto en TransactionForm
2. Selecciona categoría (ej: "Vivienda")
3. Sistema muestra sugerencias:
   - **🎯 Sugeridos por categoría**: Items con categoría "Vivienda"
   - **📋 Otros items**: Resto de presupuestos activos
4. Usuario puede:
   - **Seleccionar manualmente** un item → estado: ASIGNADA_MANUAL
   - **No seleccionar** → Backend asignará automáticamente → estado: ASIGNADA_AUTOMATICA
5. Badges 🔴/🔵 indican si es OBLIGATION o VARIABLE

---

## 🔍 Reglas de Negocio Implementadas

### 1. Monto Ejecutado como Fuente de Verdad

```javascript
// En tabla DebtManager
const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
const remaining = debt.monto_total - montoEjecutado;
```

### 2. Compatibilidad con monto_pagado

- Formulario muestra ambos campos
- `monto_ejecutado` es editable (desde backend)
- `monto_pagado` es readonly y deprecado
- Se sincronizan automáticamente en backend

### 3. Autoasignación por Categoría

```javascript
// Prioriza matches por categoría
debts.filter(debt => debt.categoria === formData.categoria)
```

### 4. Indicadores Visuales

- **Obligación (🔴)**: Compromiso fijo, debe pagarse
- **Variable (🔵)**: Presupuesto flexible, puede ajustarse
- **Gasto (💸)**: Salida de dinero
- **Ingreso (💰)**: Entrada de dinero

---

## 📦 Estructura de Datos

### Debt Model (Frontend):

```typescript
interface Debt {
  id: number;
  fecha: string;
  tipo: string;
  categoria: string;
  monto_total: number;
  monto_pagado: number;          // ← Deprecado
  detalle: string;
  fecha_vencimiento: string;
  status: string;
  tipo_presupuesto: 'OBLIGATION' | 'VARIABLE';  // ← NUEVO
  tipo_flujo: 'Gasto' | 'Ingreso';              // ← NUEVO
  monto_ejecutado: number;                      // ← NUEVO
}
```

### Transaction Model (FormData):

```typescript
interface TransactionFormData {
  fecha: string;
  tipo: 'Gasto' | 'Ingreso';
  categoria: string;
  monto: string;
  necesidad: string;
  forma_pago: string;
  detalle: string;
  debt_id: number | null;  // Opcional - autoasignación si es null
}
```

---

## 🧪 Casos de Prueba

### Caso 1: Crear Obligación

**Input:**
- tipo_presupuesto: OBLIGATION
- tipo_flujo: Gasto
- monto_total: 50000
- categoria: Vivienda
- detalle: Alquiler Marzo

**Expected:**
- Badge púrpura "Obligación"
- Badge rojo "💸 Gasto"
- Monto Ejecutado: 0
- Progreso: 0%

### Caso 2: Crear Variable

**Input:**
- tipo_presupuesto: VARIABLE
- tipo_flujo: Gasto
- monto_total: 15000
- categoria: Entretenimiento
- detalle: Salidas del mes

**Expected:**
- Badge cyan "Variable"
- Badge rojo "💸 Gasto"
- Permite sobregiro (variación positiva)

### Caso 3: Asignar Transacción (Manual)

**Input:**
- Transacción: 5000 ARS, Categoría: Vivienda
- Selecciona manualmente "Alquiler Marzo"

**Expected:**
- Lista muestra "🔴 Alquiler Marzo" en "🎯 Sugeridos"
- Al guardar → backend marca estado_asignacion = ASIGNADA_MANUAL

### Caso 4: Asignar Transacción (Automática)

**Input:**
- Transacción: 5000 ARS, Categoría: Vivienda
- No selecciona item (deja "-- Sin asignar --")

**Expected:**
- Backend busca match por categoría
- Si encuentra → estado_asignacion = ASIGNADA_AUTOMATICA
- Si no encuentra → crea bucket "No Planificado - Vivienda"

---

## 🚀 Próximos Pasos (Fases Futuras)

### Fase D - Backend Autoasignación:

- Implementar lógica de matching automático
- Crear buckets "No Planificado" por mes/categoría
- Agregar campo `estado_asignacion` en Transaction
- Job de reconciliación asíncrona

### Fase E - Analytics:

- Dashboard de OBLIGATION vs VARIABLE
- Forecast mejorado con separación por tipo
- Alertas de sobrepresupuesto en VARIABLE
- Métricas de variación presupuestaria

### Fase F - Deprecation:

- Eliminar campo `monto_pagado` del formulario
- Migrar datos legacy monto_pagado → monto_ejecutado
- Actualizar API para rechazar monto_pagado

---

## ✨ Beneficios Conseguidos

- ✅ **Separación visual clara**: Badges y colores distinguen OBLIGATION vs VARIABLE
- ✅ **UX mejorado**: Autosugerencias por categoría
- ✅ **Menos fricción**: Selector opcional, backend asigna automáticamente
- ✅ **Compatibilidad**: monto_pagado sigue funcionando durante transición
- ✅ **Escalabilidad**: Base para matching ML futuro

---

## 🎓 Reglas de Uso (Documentación para Usuarios)

### ¿Cuándo usar OBLIGATION?

- Deudas reales (préstamos, tarjetas)
- Servicios fijos (alquiler, internet, luz)
- Compromisos ineludibles
- **Métrica clave**: Saldo Pendiente = Monto - Ejecutado

### ¿Cuándo usar VARIABLE?

- Presupuestos flexibles (comida, entretenimiento)
- Gastos discrecionales
- Ingresos variables
- **Métrica clave**: Variación = Ejecutado - Presupuestado

### ¿Debo asignar transacciones manualmente?

**No es necesario**. El sistema:
1. Sugiere automáticamente items por categoría
2. Permite asignación manual si lo desea
3. Si no asigna, el backend busca el mejor match
4. Si no hay match, crea bucket "No Planificado"

---

## 📝 Notas Técnicas

### Cambios en colSpan:

Tabla ahora tiene **13 columnas** (con admin checkbox):
- Checkbox (admin)
- Fecha
- Tipo
- **Presupuesto** (nuevo)
- **Flujo** (nuevo)
- Categoría
- Detalle
- Monto Total
- **Ejecutado** (era "Pagado")
- Progreso
- Estado
- Vencimiento
- Acciones

```jsx
<td colSpan={isAdmin && canEdit ? "13" : canEdit ? "12" : "11"}>
```

### Fallback de datos:

```javascript
const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
const tipoFlujo = debt.tipo_flujo || 'Gasto';
```

Asegura compatibilidad con datos legacy que no tienen los campos nuevos.

---

## 🔗 Referencias

- [Fase A - Budget Model Refactor](./BUDGET_MODEL_REFACTOR_FASE_A.md)
- [Fase B - Transición API](./FASE_B_TRANSICION_API.md)
- [Budget Model Refactor - Documento Original](./Finly%20%E2%80%94%20Budget%20Model%20Refactor.md)
- [Tailwind CSS Utilities](https://tailwindcss.com/docs/utility-first)

---

## 📅 Changelog

### 2026-03-18 - v1.0.0 (Inicial)

- ✅ Agregados campos tipo_presupuesto, tipo_flujo, monto_ejecutado
- ✅ Actualizada tabla con nuevas columnas y badges
- ✅ Mejorado selector de presupuesto con autosugerencias
- ✅ Implementada compatibilidad con monto_pagado (deprecado)
- ✅ Agregados indicadores visuales (colores, emojis)
