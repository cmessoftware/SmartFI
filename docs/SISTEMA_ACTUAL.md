# Finly - Documentación del Sistema Actual

## 📊 Estado Actual: Sprint 3 - PostgreSQL + Google Sheets

**Última actualización:** 14 de Marzo de 2026

---

## 🏗️ Arquitectura del Sistema

### Stack Tecnológico

**Backend:**
- FastAPI (Python)
- PostgreSQL como base de datos principal
- Google Sheets como respaldo/sincronización opcional
- SQLAlchemy ORM
- JWT para autenticación

**Frontend:**
- React + Vite
- TailwindCSS
- Axios para API calls
- Chart.js para gráficos

**Deployment:**
- Docker + Docker Compose
- Render.com (producción)
- Soporte para desarrollo local

---

## 📁 Módulos Implementados

### 1. **Gestión de Transacciones**

#### Características:
- ✅ Registro de ingresos y gastos
- ✅ Categorías predefinidas (Comida, Transporte, Salud, etc.)
- ✅ Clasificación por necesidad (Necesario, Superfluo, Importante pero no urgente)
- ✅ Forma de pago (Débito, Crédito)
- ✅ Vinculación con items de presupuesto
- ✅ Importación masiva vía CSV
- ✅ Edición y eliminación de transacciones

#### API Endpoints:
```
POST   /api/transactions          - Crear transacción
GET    /api/transactions          - Listar transacciones
PUT    /api/transactions/{id}     - Actualizar transacción
DELETE /api/transactions/{id}     - Eliminar transacción
POST   /api/transactions/import   - Importar CSV
```

#### Modelo de Datos:
```python
Transaction:
  - id: int
  - marca_temporal: datetime
  - fecha: string
  - tipo: enum (Gasto, Ingreso)
  - categoria: string
  - monto: float
  - necesidad: enum
  - forma_pago: enum (Débito, Crédito)
  - partida: string
  - detalle: string
  - debt_id: int (FK a Presupuesto)
```

---

### 2. **Módulo de Presupuesto** (antes Deudas)

#### Características:
- ✅ Registro de compromisos financieros (préstamos, tarjetas, servicios recurrentes)
- ✅ Seguimiento de pagos realizados vs. total
- ✅ Estados: Pendiente, Pagada, Vencida
- ✅ Barra de progreso visual
- ✅ Vinculación automática con transacciones
- ✅ Alertas de vencimiento
- ✅ Resumen estadístico

#### API Endpoints:
```
POST   /api/debts              - Crear item de presupuesto
GET    /api/debts              - Listar items
GET    /api/debts/summary      - Resumen estadístico
GET    /api/debts/{id}         - Obtener item específico
PUT    /api/debts/{id}         - Actualizar item
DELETE /api/debts/{id}         - Eliminar item
```

#### Modelo de Datos:
```python
Debt (Budget Item):
  - id: int
  - fecha: string
  - tipo: string (Préstamo, Tarjeta, Servicio, Otro)
  - categoria: string
  - monto_total: float
  - monto_pagado: float
  - detalle: string
  - fecha_vencimiento: string
  - status: enum (Pendiente, Pagada, Vencida)
  - created_at: datetime
  - updated_at: datetime
```

#### Funcionalidad de Vinculación:
Cuando se crea un gasto con `debt_id`:
1. El monto se suma automáticamente a `monto_pagado` del item
2. Se actualiza el progreso (%)
3. Si `monto_pagado >= monto_total`, el estado cambia a "Pagada"

---

### 3. **Dashboard y Reportes**

#### Dashboard Overview:
- 📊 Tarjetas de resumen:
  - 💵 **Ingresos**: Total de ingresos del mes
  - 💸 **Gastos**: Total de gastos del mes
  - 💰 **Balance**: Ingresos - Gastos (balance actual)
  - 🎯 **Balance Pendiente**: Proyección si se pagan todos los presupuestos (Ingresos - Gastos - Presupuesto Pendiente)
  - 📝 **Total Transacciones**: Cantidad de transacciones registradas
- 📈 Transacciones recientes (últimas 5)
- 🔄 Botón de sincronización con Google Sheets
- 📅 Fecha actual
- 🎯 Widget de Balance Pendiente:
  - Muestra proyección financiera considerando presupuestos pendientes
  - Actualización automática con cambios en transacciones o presupuestos
  - Indicador visual: verde para balance positivo, amarillo para negativo

#### Reportes:
- 📊 Gráfico de torta: Gastos por categoría
- 📈 Gráfico de barras: Balance por fecha
- 🔍 Filtros por tipo y categoría
- ⬆️⬇️ Ordenamiento por fecha, monto, categoría
- ✏️ Edición inline de transacciones
- 🗑️ Eliminación con confirmación

---

### 4. **Sincronización PostgreSQL ↔ Google Sheets**

#### Modos de Sincronización:

**📥 Sheets → PostgreSQL:**
- **Normal:** Agrega solo transacciones nuevas desde Sheets
- **Forzada:** Limpia PostgreSQL y recarga todo desde Sheets

**📤 PostgreSQL → Sheets:**
- **Normal:** Agrega solo transacciones nuevas a Sheets
- **Forzada:** Limpia Sheets y recarga todo desde PostgreSQL

#### Características:
- ✅ Detección de duplicados por "huella digital" (fecha + monto + categoría + detalle)
- ✅ Estadísticas de sincronización (agregados, omitidos, totales)
- ✅ Solo disponible para rol Admin
- ✅ Manejo de errores robusto

---

### 5. **Sistema de Autenticación y Roles**

#### Roles Implementados:

| Rol | Permisos |
|-----|----------|
| **Admin** | • Todas las acciones<br>• Sincronización<br>• Gestión de usuarios |
| **Writer** | • Crear transacciones<br>• Editar/eliminar propias<br>• Ver reportes |
| **Reader** | • Solo lectura<br>• Ver dashboards y reportes |

#### Usuarios por Defecto:
```
admin / admin123
writer / writer123
reader / reader123
```

#### Seguridad:
- ✅ JWT tokens con expiración
- ✅ CORS configurado
- ✅ Contraseñas hasheadas con bcrypt
- ✅ Middleware de autenticación en todas las rutas

---

### 6. **Importación CSV**

#### Características:
- ✅ Mapeo flexible de columnas
- ✅ Vista previa antes de importar
- ✅ Descarga de plantilla CSV
- ✅ Validación de datos
- ✅ Importación por lotes

#### Formato de Plantilla:
```csv
fecha,tipo,categoria,monto,forma_pago,detalle
2024-03-06,Gasto,Comida,15000,Débito,Almuerzo en restaurante
```

---

## 🎨 Características de UX/UI

### Formateo de Datos:
- ✅ **Fechas consistentes:** Todas en formato DD/MM/YYYY
- ✅ **Moneda:** Formato argentino (ARS) con separadores de miles
- ✅ **Colores semánticos:**
  - 🟢 Verde: Ingresos, completados
  - 🔴 Rojo: Gastos, vencidos
  - 🟡 Amarillo: Pendientes
  - 🔵 Azul: Balance positivo

### Componentes Reutilizables:
- Toast notifications (éxito, error, advertencia)
- Modales de confirmación
- Diálogos de edición
- Filtros y ordenamiento
- Gráficos interactivos

---

## 🗄️ Almacenamiento de Datos

### Flujo de Datos:

```
Usuario → Frontend → Backend API → PostgreSQL (Principal)
                                       ↓
                                   Google Sheets (Respaldo/Opcional)
```

### Prioridades:
1. **PostgreSQL** es la fuente de verdad
2. **Google Sheets** es respaldo y para compatibilidad
3. Frontend mantiene caché local para performance

---

## 🔧 Configuración

### Variables de Entorno (Backend):

```env
# JWT
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# PostgreSQL
DATABASE_URL=postgresql://admin:admin123@localhost:5433/fin_per_db

# Google Sheets (Opcional)
GOOGLE_SHEET_ID=your-sheet-id
GOOGLE_CREDENTIALS_FILE=credentials.json

# API
API_HOST=0.0.0.0
API_PORT=8000
```

### Docker Compose:
```yaml
services:
  postgres:    # Puerto 5433
  backend:     # Puerto 8000
  frontend:    # Puerto 3000
```

---

## 📊 Flujo de Trabajo Típico

### 1. Registro de Transacción:
```
Usuario → Agrega Transacción → PostgreSQL → Google Sheets (automático)
                                    ↓
                          Actualiza item de presupuesto (si vinculado)
```

### 2. Gestión de Presupuesto:
```
Usuario → Crea Item de Presupuesto → PostgreSQL
              ↓
      Registra Gastos vinculados → Actualiza progreso automáticamente
              ↓
         Marca como "Pagada" cuando monto_pagado >= monto_total
```

### 3. Sincronización:
```
Admin → Botón "Sincronizar" → Selecciona dirección
                                     ↓
                           PostgreSQL ↔ Google Sheets
                                     ↓
                            Muestra estadísticas
```

---

## 🐛 Problemas Conocidos Resueltos

### ✅ Formato de fechas inconsistente
- **Solución:** Función `formatDate()` centralizada
- **Ubicación:** `frontend/src/utils/dateUtils.js`

### ✅ Sincronización genera duplicados
- **Solución:** Método `clear_all_transactions()` implementado
- **Ubicación:** `backend/services/google_sheets.py`

### ✅ Error "e.map is not a function"
- **Solución:** Acceso correcto a `response.data` en Axios
- **Ubicación:** `frontend/src/components/DebtManager.jsx`

### ✅ Headers de Google Sheets incompletos
- **Solución:** Agregada columna "Forma de Pago"
- **Total columnas:** 9 (Marca temporal, Fecha, Tipo, Categoría, Monto, Necesidad, Forma de Pago, Partida, Detalle)

---

## 🚀 Roadmap Futuro

Ver [FINLY_FUNCTIONAL_SPECIFICATION.md](FINLY_FUNCTIONAL_SPECIFICATION.md) para funcionalidades planificadas:

- [ ] Clonación mensual de presupuestos
- [ ] Proyección de balance diario
- [ ] Alertas financieras automáticas
- [ ] Análisis de desviación presupuestaria
- [ ] Planificación financiera automática
- [ ] Importación CSV de presupuestos
- [ ] Dashboard de forecast balance

---

## 📝 Notas de Desarrollo

### Convenciones de Código:
- Backend: PEP 8 (Python)
- Frontend: ES6+ con React hooks
- Nombres de variables: snake_case (backend), camelCase (frontend)
- Commits: Conventional Commits

### Testing:
```bash
# Backend
cd backend
python test_sheets.py

# Frontend
cd frontend
npm run build
```

### Deployment:
```bash
# Local
docker-compose up

# Producción (Render.com)
git push origin main  # Auto-deploy configurado
```

---

## 👥 Usuarios del Sistema

**Producción:**
- Configurar usuarios reales en base de datos
- Eliminar usuarios de prueba (admin/writer/reader)

**Desarrollo:**
- Usar usuarios predefinidos para testing
- No exponer credenciales en producción

---

## 📞 Soporte y Documentación

- **Documentación completa:** `docs/`
- **Guías de instalación:** `docs/INSTALLATION.md`
- **Deployment:** `docs/deployment/`
- **Roadmap:** `docs/ROADMAP_FINLY_V1.md`

---

**Versión:** Sprint 3 - PostgreSQL Integration
**Fecha:** Marzo 2026
**Status:** ✅ Funcional en producción
