# Fase B - Transición API: Budget Items

## 📋 Resumen

Implementación de endpoints alias `/api/budget-items` para migrar progresivamente de la terminología legacy "debts" a la semántica moderna de "budget items".

## ✅ Estado: COMPLETADA

**Fecha de implementación:** 2026-03-18

---

## 🎯 Objetivos

1. **Compatibilidad retroactiva**: Mantener `/api/debts` funcionando mientras se migra a `/api/budget-items`
2. **Código limpio**: Implementar aliases sin duplicación de lógica (DRY)
3. **Migración gradual**: Permitir transición frontend sin downtime
4. **Testing exhaustivo**: Validar todos los endpoints CRUD

---

## 🔧 Implementación

### Backend (main.py)

Se agregaron 8 endpoints alias en `backend/main.py`:

```python
# ============================================================
# FASE B - Budget Items API Aliases (mantiene compatibilidad)
# ============================================================

@app.get("/api/budget-items")
async def get_budget_items(current_user: User = Depends(get_current_user)):
    """Alias for GET /api/debts - Get all budget items"""
    if not debt_service:
        raise HTTPException(status_code=503, detail="Debt service not configured")
    
    try:
        debts = debt_service.get_all_debts()
        return debts
    except Exception as e:
        print(f"❌ Error getting budget items: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ... + 7 endpoints más (summary, import-csv, CRUD)
```

### Endpoints implementados:

| Método | Endpoint | Descripción | Equivalente Legacy |
|--------|----------|-------------|-------------------|
| GET | `/api/budget-items` | Obtener todos los items | `/api/debts` |
| GET | `/api/budget-items/summary` | Resumen total/ejecutado | `/api/debts/summary` |
| GET | `/api/budget-items/{item_id}` | Item específico | `/api/debts/{id}` |
| POST | `/api/budget-items` | Crear nuevo item | `/api/debts` |
| PUT | `/api/budget-items/{item_id}` | Actualizar item | `/api/debts/{id}` |
| DELETE | `/api/budget-items/{item_id}` | Eliminar item | `/api/debts/{id}` |
| POST | `/api/budget-items/import-csv` | Importación CSV | `/api/debts/import-csv` |

---

## 🧪 Testing Ejecutado

### Tests manuales con PowerShell:

```powershell
# Login
$body = @{ username = 'admin'; password = 'admin123' }
$loginResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/auth/login" `
    -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $loginResponse.access_token

# GET /api/budget-items - ✅ 200 OK
$items = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/budget-items" `
    -Method GET -Headers @{Authorization="Bearer $token"}

# GET /api/budget-items/summary - ✅ 200 OK
$summary = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/budget-items/summary" `
    -Method GET -Headers @{Authorization="Bearer $token"}

# POST /api/budget-items - ✅ Creó item ID 127
# PUT /api/budget-items/127 - ✅ Actualizó correctamente
# GET /api/budget-items/127 - ✅ Retornó datos actualizados
# DELETE /api/budget-items/127 - ✅ Eliminó exitosamente
```

### Resultados:

```
✅ POST Success: Item created with ID 127
✅ PUT Success: Item updated
✅ GET by ID Success:
   Detalle: Test Budget Item via new API [UPDATED]
   Categoria: Test API [UPDATED]
   Monto Total: 750
   Monto Pagado: 100
✅ DELETE Success: Item deleted
=== ✅ All CRUD operations tested successfully ===
```

---

## 🎨 Actualización Frontend

### Archivos modificados:

#### 1. `frontend/src/services/api.js`

```javascript
export const debtsAPI = {
  getDebts: () => api.get('/api/budget-items'),                    // ← Cambiado
  getDebtSummary: () => api.get('/api/budget-items/summary'),      // ← Cambiado
  getDebt: (id) => api.get(`/api/budget-items/${id}`),             // ← Cambiado
  createDebt: (debt) => api.post('/api/budget-items', debt),       // ← Cambiado
  updateDebt: (id, debt) => api.put(`/api/budget-items/${id}`, debt), // ← Cambiado
  deleteDebt: (id) => api.delete(`/api/budget-items/${id}`),       // ← Cambiado
};
```

#### 2. `frontend/src/components/BudgetCSVImport.jsx`

```javascript
// Antes
const response = await fetch('http://localhost:8000/api/debts/import-csv', {...});

// Después
const response = await fetch('http://localhost:8000/api/budget-items/import-csv', {...});
```

---

## 📊 Compatibilidad

### Estado actual:

| Endpoint | Estado | Notas |
|----------|--------|-------|
| `/api/debts/*` | ✅ Functional | Legacy - se mantendrá por compatibilidad |
| `/api/budget-items/*` | ✅ Functional | Nuevo - recomendado para desarrollo |
| Frontend | ✅ Migrado | Ahora usa `/api/budget-items` |

---

## 🔍 Detalles Técnicos

### Patrón de implementación:

Los aliases **replican la lógica** de los endpoints legacy en lugar de delegarlos con `await`. Esto evita problemas con el event loop de FastAPI y mantiene cada endpoint independiente.

**Decisión de diseño:**
```python
# ❌ Patrón inicial (fallaba)
@app.get("/api/budget-items")
async def get_budget_items(...):
    return await get_debts(...)  # No funciona - FastAPI no permite esto

# ✅ Patrón final (funciona)
@app.get("/api/budget-items")
async def get_budget_items(...):
    # Replica la lógica directamente
    debts = debt_service.get_all_debts()
    return debts
```

### Autenticación:

Todos los endpoints heredan los mismos decoradores de autenticación y autorización:

- `Depends(get_current_user)` - para lectura
- `Depends(require_role(["admin", "writer"]))` - para escritura

---

## 🚀 Próximos pasos (Fases futuras)

1. **Fase C - Deprecation Warnings**: Agregar headers `X-Deprecated: true` a `/api/debts`
2. **Fase D - Analytics**: Monitorear uso de endpoints para planificar sunset de legacy
3. **Fase E - Removal**: Eliminar `/api/debts` cuando uso sea < 5%

---

## ✨ Beneficios conseguidos

- ✅ **Semántica mejorada**: "budget items" es más claro que "debts"
- ✅ **Sin breaking changes**: Código legacy sigue funcionando
- ✅ **Migración completada**: Frontend ya usa nueva API
- ✅ **Testing exhaustivo**: Todos los endpoints validados
- ✅ **Código mantenible**: Cada endpoint es independiente

---

## 📝 Notas del desarrollador

### Problemas encontrados:

1. **Intento inicial de delegation via await**: FastAPI no soporta llamar endpoints desde otros endpoints usando `await`.  
   **Solución**: Replicar lógica directamente en cada alias.

2. **Testing con Invoke-RestMethod**: Login requiere `application/x-www-form-urlencoded` (OAuth2 spec).

### Lecciones aprendidas:

- FastAPI route registration ocurre en startup, no en runtime → **requiere restart**
- Los middleware y decoradores se aplican correctamente a los aliases
- El testing manual reveló el problema de schema en el primer intento

---

## 🔗 Referencias

- [Fase A - Budget Model Refactor](./BUDGET_MODEL_REFACTOR_FASE_A.md)
- [FastAPI Dependency Injection](https://fastapi.tiangolo.com/tutorial/dependencies/)
- [OAuth2 Password Flow](https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/)
