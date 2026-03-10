# 🔄 Solución: Refresh desde Google Sheets en Render

## 📌 Problema Identificado

El botón "Refrescar desde Google Sheets" no funcionaba porque faltaba un endpoint en el backend para sincronizar datos desde Google Sheets hacia PostgreSQL.

**Arquitectura Actual:**
- **PostgreSQL**: Base de datos principal (fuente de verdad)
- **Google Sheets**: Backup opcional y fuente de datos externa
- **Flujo**: Google Sheets → Sincronización → PostgreSQL → Frontend

## ✅ Solución Implementada

Se agregó un nuevo endpoint `/api/transactions/sync-from-sheets` que:

1. 📥 Obtiene todas las transacciones desde Google Sheets
2. 🔍 Compara con las transacciones existentes en PostgreSQL
3. ✨ Detecta duplicados usando "fingerprint" (fecha + monto + categoría + detalle)
4. 💾 Guarda solo las transacciones nuevas en PostgreSQL
5. 📊 Retorna estadísticas de la sincronización

## 🚀 Cómo Usar

### 1. Configurar Google Sheets en Render

Si aún no lo has hecho:

```bash
# Variables de entorno en Render (Backend):
GOOGLE_SHEET_ID=tu_sheet_id_aqui
GOOGLE_CREDENTIALS_JSON={"type":"service_account","project_id":"...",...}
```

**Pasos detallados:**
1. Crear Google Sheet y copiar el ID de la URL
2. Crear Service Account en Google Cloud Console
3. Descargar `credentials.json`
4. Copiar TODO el contenido del JSON y pegarlo en `GOOGLE_CREDENTIALS_JSON`
5. Compartir la hoja con el email del service account (`xxx@xxx.iam.gserviceaccount.com`)

### 2. Agregar Transacciones en Google Sheets

La hoja debe tener estos headers (en español):

| Marca temporal | Fecha | Tipo | Categoría | Monto | Necesidad | Partida | Detalle |
|----------------|-------|------|-----------|-------|-----------|---------|---------|
| 2024-01-15... | 15/01/2024 | Gasto | Comida | 5000 | Necesidad | Fijo | Almuerzo |

**Formato requerido:**
- **Marca temporal**: ISO 8601 o cualquier formato de fecha/hora
- **Fecha**: DD/MM/YYYY
- **Tipo**: "Ingreso" o "Gasto"
- **Categoría**: Cualquier string (ej: Comida, Transporte, Salud)
- **Monto**: Número (sin símbolos de moneda)
- **Necesidad**: "Necesidad" o "Gustito"
- **Partida**: "Fijo" o "Variable"
- **Detalle**: Descripción opcional

### 3. Sincronizar en la App

1. Ve al Dashboard en tu app deployada
2. Haz clic en el botón **"Sincronizar desde Sheets"** 🔄
3. Espera unos segundos (verás "Sincronizando...")
4. ¡Las transacciones nuevas aparecerán automáticamente!

## 🔧 Deploy de los Cambios

### Opción 1: Git Push (Recomendado)

```bash
# En tu terminal local:
git add .
git commit -m "Fix: Agregar endpoint de sincronización Google Sheets"
git push origin main
```

Render detectará el push y re-desplegará automáticamente.

### Opción 2: Manual Trigger

1. Ir a Render Dashboard
2. Seleccionar el servicio `finly-api`
3. Click en "Manual Deploy" → "Deploy latest commit"

### Opción 3: Forzar Deploy

```bash
git commit --allow-empty -m "Force redeploy"
git push
```

## 📊 Archivos Modificados

### Backend:
- ✅ `backend/main.py` - Nuevo endpoint `/api/transactions/sync-from-sheets`

### Frontend:
- ✅ `frontend/src/services/api.js` - Método `syncFromSheets()`
- ✅ `frontend/src/App.jsx` - Actualizado `loadTransactions()` para sincronizar
- ✅ `frontend/src/components/DashboardOverview.jsx` - Texto del botón actualizado
- ✅ `frontend/src/components/CSVImport.jsx` - Mensajes actualizados

### Documentación:
- ✅ `docs/deployment/DEPLOY_CHECKLIST.md` - Guía de Google Sheets agregada
- ✅ `docs/deployment/GOOGLE_SHEETS_SYNC_FIX.md` - Este documento

## 🎯 Comportamiento del Sistema

### Cuando agregas transacciones manualmente:
1. Frontend → Backend API → PostgreSQL ✅
2. Backend → Google Sheets (backup automático) ✅

### Cuando sincronizas desde Google Sheets:
1. Usuario hace clic en "Sincronizar desde Sheets" 🔄
2. Backend obtiene datos de Google Sheets 📥
3. Backend elimina duplicados 🔍
4. Backend guarda nuevas en PostgreSQL 💾
5. Frontend recarga y muestra todo 📊

### Detección de Duplicados:
El sistema crea un "fingerprint" único para cada transacción:
```
fingerprint = fecha + monto + categoría + detalle
```

Si dos transacciones tienen el mismo fingerprint, se considera duplicado y no se importa.

## 🐛 Troubleshooting

### Error: "503 Google Sheets not configured"
- Verifica que `GOOGLE_SHEET_ID` esté configurado
- Verifica que `GOOGLE_CREDENTIALS_JSON` esté configurado
- Ambas variables deben estar en el servicio backend de Render

### Error: "401 Unauthorized" o "403 Forbidden"
- Asegúrate de compartir la hoja con el email del service account
- El service account debe tener permisos de "Editor"

### Las transacciones no se sincronizan
- Verifica que los headers de la hoja sean exactamente:
  - `Marca temporal`, `Fecha`, `Tipo`, `Categoría`, `Monto`, `Necesidad`, `Partida`, `Detalle`
- Verifica que el formato de las fechas sea correcto
- Revisa los logs en Render: Dashboard → finly-api → Logs

### El botón no aparece
- Solo usuarios con rol `admin` o `writer` pueden sincronizar
- Usuarios `reader` no ven el botón de sincronización

## 📝 Logs Útiles

### En el Frontend (Consola del Navegador):
```
🔄 Syncing from Google Sheets to PostgreSQL...
✅ Sync completed: { synced_count: 5, skipped_count: 10 }
✅ Loaded 45 transactions from PostgreSQL
```

### En el Backend (Logs de Render):
```
📥 Fetching transactions from Google Sheets...
✅ Found 50 transactions in Google Sheets
📥 Fetching existing transactions from PostgreSQL...
✅ Found 45 existing transactions in PostgreSQL
💾 Saving 5 new transactions to PostgreSQL...
✅ Synced 5 new transactions from Google Sheets to PostgreSQL
```

## 🎉 Resultado Final

Después de hacer el deploy:

✅ El botón "Sincronizar desde Sheets" funciona correctamente
✅ Puedes agregar transacciones directamente en Google Sheets
✅ Al hacer clic en el botón, se importan a PostgreSQL
✅ No se crean duplicados
✅ La UI se actualiza automáticamente

## 💡 Casos de Uso

### Uso 1: Familia Colaborativa
- Comparte tu Google Sheet con tu pareja/familia
- Cada uno agrega gastos directamente en Sheets
- Tú sincronizas periódicamente desde la app
- Todos ven los datos actualizados

### Uso 2: Migración de Datos Históricos
- Tienes datos viejos en una planilla de Excel
- Los copias a tu Google Sheet
- Haces clic en "Sincronizar desde Sheets"
- ¡Todos los datos históricos se importan!

### Uso 3: Backup y Recuperación
- PostgreSQL es la fuente principal
- Google Sheets siempre tiene una copia (backup)
- Si algo falla en la DB, puedes re-sincronizar desde Sheets

## 📚 Referencias

- [DEPLOY_CHECKLIST.md](./DEPLOY_CHECKLIST.md) - Checklist completo de deployment
- [GOOGLE_SHEETS_SETUP.md](../configuration/GOOGLE_SHEETS_SETUP.md) - Guía detallada de configuración
- [RENDER_DEPLOY.md](./RENDER_DEPLOY.md) - Guía completa de deployment en Render
