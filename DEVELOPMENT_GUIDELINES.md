# Finly - Instrucciones Globales de Desarrollo

**Última actualización:** 26 de marzo de 2026

Este archivo contiene reglas y convenciones críticas que DEBEN seguirse al desarrollar en el proyecto Finly.

---

## 1. Gestión de Base de Datos

### ⚠️ CRÍTICO: Usar SOLO Alembic para migraciones

**REGLA:** Todas las migraciones de base de datos DEBEN gestionarse con Alembic. **NO** crear archivos SQL manuales en `migrations/`.

#### Proceso Obligatorio para Cambios de DB

1. **Modificar modelos** en `backend/database/database.py`
2. **Generar migración automática:**
   ```bash
   cd backend
   alembic revision --autogenerate -m "descripcion_del_cambio"
   ```
3. **Revisar archivo generado** en `backend/alembic/versions/`
4. **Aplicar migración:**
   ```bash
   alembic upgrade head
   ```
5. **Verificar en PostgreSQL** que los cambios se aplicaron correctamente

#### Comandos Esenciales

```bash
# Ver estado actual
alembic current

# Ver historial
alembic history

# Revertir última migración
alembic downgrade -1

# Aplicar todas las migraciones pendientes
alembic upgrade head
```

#### Casos Especiales

**Modificar ENUMs:**
- Alembic NO puede modificar enums automáticamente
- Crear migración manual: `alembic revision -m "add_enum_value"`
- Usar `ALTER TYPE ... ADD VALUE IF NOT EXISTS` en PostgreSQL
- Ver `backend/ALEMBIC_GUIDE.md` para ejemplos

**Convertir columnas VARCHAR a ENUM:**
- Eliminar DEFAULT antes de cambiar tipo
- Usar `USING column::enumtype` para conversión
- Restaurar DEFAULT después

---

## 2. Terminología y Convenciones

### Tabla `debts` - Propósito Dual

La tabla `debts` sirve para:
1. **Gestión de Deudas** - Tracking de pagos (tarjetas, préstamos)
2. **Planificación Presupuestaria** - Items de presupuesto (OBLIGATION/VARIABLE)

**Columnas clave:**
- `tipo_presupuesto`: BudgetType (OBLIGATION, VARIABLE)
- `tipo_flujo`: FlowType (Gasto, Ingreso)
- `monto_ejecutado`: Ejecutado vs presupuestado
- `monto_pagado`: Pagado vs deuda total

### API Endpoints

**Primarios:** `/api/debts/*`  
**Alias (compatibilidad):** `/api/budget-items/*`

**Frontend:** Usar `/api/budget-items` (ya implementado)  
**Backend nuevo:** Usar `/api/debts` para nuevas integraciones

---

## 3. Arquitectura de Módulos

### Estructura por Módulo

Cada módulo funcional DEBE tener:

```
backend/
  ├── database/database.py         # Modelos SQLAlchemy
  ├── services/{module}_service.py # Lógica de negocio
  ├── alembic/versions/*.py        # Migraciones (generadas)
  └── main.py                      # Rutas API

frontend/
  ├── src/components/{Module}*.jsx # Componentes UI
  ├── src/services/api.js          # Llamadas API
  └── src/utils/*                  # Utilidades

docs/
  └── {Module} - Functional Design.md  # Especificación funcional
```

### Módulos Actuales

- **Transactions** - Movimientos financieros
- **Debts** - Deudas y presupuestos
- **Credit Cards** - Tarjetas de crédito y financiamiento ✨ NUEVO

---

## 4. Flujo de Trabajo Git

### Branches

**main** - Producción estable  
**feature/{descripcion}** - Nuevas funcionalidades  
**fix/{descripcion}** - Correcciones

### Commits

Formato recomendado:
```
{tipo}: {descripción breve}

{descripción detallada opcional}
```

Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

Ejemplo:
```
feat: add credit card management module

- Created 6 tables via Alembic migration
- Implemented credit_card_service.py
- Added purchase tracking with installment plans
```

---

## 5. Testing

### Antes de Commit

```bash
# Backend - Verificar servidor arranca sin errores
cd backend
conda run -n finly python main.py

# Frontend - Verificar compilación
cd frontend
npm run build

# Alembic - Verificar migraciones
cd backend
alembic check
```

### Validación de Base de Datos

```sql
-- Verificar tablas
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Verificar ENUMs
SELECT t.typname, e.enumlabel
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
ORDER BY t.typname, e.enumsortorder;

-- Verificar versión Alembic
SELECT * FROM alembic_version;
```

---

## 6. Configuración de Entorno

### Variables de Entorno Requeridas (`.env`)

```env
# JWT
SECRET_KEY=...
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Google Sheets
GOOGLE_SHEET_ID=...
GOOGLE_CREDENTIALS_FILE=credentials.json

# Database
DATABASE_URL=postgresql://admin:admin123@localhost:5433/fin_per_db
```

### Conda Environment

```bash
# Crear environment
conda create -n finly python=3.11
conda activate finly

# Instalar dependencias
cd backend
pip install -r requirements.txt
```

---

## 7. Despliegue

### Pre-Deployment Checklist

- [ ] Migraciones Alembic aplicadas en staging/production
- [ ] Variables de entorno configuradas
- [ ] Frontend compilado (`npm run build`)
- [ ] Backend testado localmente
- [ ] Credenciales Google Sheets actualizadas
- [ ] Backup de base de datos realizado

### Comandos de Despliegue

Ver `docs/deployment/DEPLOY_CHECKLIST.md` para procedimiento completo.

---

## 8. Documentación

### Archivos de Referencia Clave

- **`backend/ALEMBIC_GUIDE.md`** - Guía completa de migraciones
- **`docs/BUDGET_TO_DEBTS_MIGRATION_IMPACT.md`** - Análisis de terminología
- **`docs/DATA_ARCHITECTURE.md`** - Arquitectura de datos
- **`docs/FINLY_FUNCTIONAL_SPECIFICATION.md`** - Especificación funcional

### Al Crear un Nuevo Módulo

1. Crear `docs/{Module} - Functional Design.md`
2. Documentar modelos en `database/database.py` con docstrings
3. Agregar ejemplos de uso en servicios
4. Actualizar este archivo con nuevas convenciones

---

## 9. Errores Comunes y Soluciones

### Error: "type {enum} already exists"

**Causa:** Migraciones SQL manuales previas crearon el enum  
**Solución:** Usar `CREATE TYPE IF NOT EXISTS` o `DO $$ ... EXCEPTION WHEN duplicate_object`

### Error: "cannot be cast automatically to type {enum}"

**Causa:** PostgreSQL no puede convertir VARCHAR a ENUM directamente  
**Solución:**
```sql
ALTER TABLE tabla ALTER COLUMN columna DROP DEFAULT;
ALTER TABLE tabla ALTER COLUMN columna TYPE enumtype USING columna::enumtype;
ALTER TABLE tabla ALTER COLUMN columna SET DEFAULT 'valor'::enumtype;
```

### Error: "Alembic detects changes but they're already applied"

**Causa:** Discrepancia entre `database.py` y estado real de DB  
**Solución:**
1. Verificar con `alembic check`
2. Inspeccionar DB manualmente
3. Crear migración vacía si necesario: `alembic stamp head`

---

## 10. Contacto y Recursos

**Documentación Alembic:** https://alembic.sqlalchemy.org/  
**SQLAlchemy Docs:** https://docs.sqlalchemy.org/  
**FastAPI Docs:** https://fastapi.tiangolo.com/

---

**NOTA FINAL:** Este archivo debe actualizarse cuando se agreguen nuevas reglas o convenciones críticas al proyecto.
