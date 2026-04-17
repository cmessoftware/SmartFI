# Arquitectura de Datos - Finly

## 📊 Google Sheets como Fuente de Verdad

La aplicación ahora usa **Google Sheets como única fuente de verdad** para los datos de transacciones.

### 🔄 Flujo de Datos

```
┌─────────────────┐
│   Google Sheets │  ← Fuente de verdad
│   (Online)      │
└────────┬────────┘
         │
         │ Sincroniza
         ↓
┌─────────────────┐
│    Backend      │
│   (FastAPI)     │
└────────┬────────┘
         │
         │ API REST
         ↓
┌─────────────────┐
│    Frontend     │
│   (React)       │
└────────┬────────┘
         │
         │ Cache (solo lectura)
         ↓
┌─────────────────┐
│  localStorage   │  ← Cache temporal para performance
└─────────────────┘
```

### ✅ Características

- **Online-only**: Requiere conexión para todas las operaciones
- **Cache inteligente**: localStorage muestra datos instantáneamente mientras carga
- **Sincronización automática**: Cada operación actualiza Google Sheets
- **Botón refrescar**: Sincroniza manualmente cuando lo necesites
- **Indicador visual**: Muestra que los datos vienen de Google Sheets

### 📝 Operaciones

#### Cargar Transacciones
1. Se muestra cache de localStorage (instantáneo)
2. Se carga desde Google Sheets (actualizado)
3. Se actualiza cache

#### Guardar Transacción
1. Se envía a Google Sheets
2. Se actualiza estado local
3. Se actualiza cache

#### Importar CSV
1. Se envía lote a Google Sheets
2. Se actualiza estado local
3. Se actualiza cache

### 🔧 Configuración

La configuración de Google Sheets está en `backend/.env`:

```env
GOOGLE_SHEET_ID=tu-sheet-id-aqui
GOOGLE_CREDENTIALS_FILE=credentials.json
```

### 🧹 Migración de Datos

Si tenías datos en localStorage anteriormente, puedes migrarlos:

```bash
cd backend
conda activate finly
python migrate_localstorage.py
```

Sigue las instrucciones en pantalla.

### ❌ Gestión de Datos Eliminada

La sección "Gestión de Datos" ha sido eliminada porque:
- Ya no hay distinción entre datos locales y remotos
- Google Sheets es editable directamente
- No hay necesidad de exportar/importar manualmente

### 🎯 Ventajas

✅ **Un solo lugar**: Google Sheets es la fuente de verdad
✅ **Acceso múltiple**: Varios usuarios pueden ver/editar la misma planilla
✅ **Backup automático**: Google Sheets tiene versionado y backup
✅ **Performance**: Cache local hace la UI instantánea
✅ **Simplicidad**: Sin sincronización compleja

### ⚠️ Limitaciones

- Requiere conexión a internet
- Depende de la disponibilidad de Google Sheets API
- Sin modo offline

### 🔍 Debugging

Ver logs en la consola del navegador (F12):
- ⚡ "Loaded from cache" - Datos del cache local
- ✅ "Loaded X transactions from Google Sheets" - Datos sincronizados
- ❌ "Error loading from Google Sheets" - Error de conexión

### 📊 Estructura de Google Sheet

La hoja debe tener estas columnas:

| Marca temporal | Fecha | Tipo | Categoría | Monto | Necesidad | Partida | Detalle |
|---------------|-------|------|-----------|-------|-----------|---------|---------|
| 2024-03-06... | 2024-03-06 | Gasto | Comida | 1500 | Necesario | Comida | Almuerzo |

**Nota**: Se usa siempre la **primera hoja** del documento Google Sheets (puede tener cualquier nombre).
