# Issues a Crear en Gitea para EXP-FEAT-014

## Instrucciones

1. Abrí Gitea: http://localhost:3001/admin/SmartFI/issues
2. Hacé clic en **New Issue**
3. Para cada issue abajo, copia el título, descripción y label, y crealo

---

## Issue #1: Backend - Implementar funciones de comparativa

**Título**: `[EXP-FEAT-014] Backend: Funciones de comparativa de meses`

**Descripción**:
```
Implementar funciones en backend/services/month_service.py:

- get_months_comparison(start_month, end_month, user_id)
- get_category_distribution(start_month, end_month, user_id)
- calculate_deviations(start_month, end_month, user_id)

Ver: openspec/changes/exp-feat-014-comparative-dashboard/tasks.md (Backend Tasks B1-B3)

Dependencias: Ninguna
```

**Labels**: `EXP-FEAT-014`, `backend`, `month-management`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Issue #2: Backend - Endpoints de comparativa

**Título**: `[EXP-FEAT-014] Backend: Endpoints GET /api/months/range/{start}/{end}/comparison y deviations`

**Descripción**:
```
Implementar endpoints en backend/main.py:

- GET /api/months/{start}/{end}/comparison
- GET /api/months/{start}/{end}/deviations

Ver especificación: openspec/changes/exp-feat-014-comparative-dashboard/specs/endpoints.md

Debe retornar:
- KPIs por mes (ingresos, gastos, balance)
- Distribución por categoría
- Deviaciones críticas (>20%)

Dependencias: Issue #1 (Backend functions)
```

**Labels**: `EXP-FEAT-014`, `backend`, `api`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Issue #3: Frontend - Componentes de comparativa

**Título**: `[EXP-FEAT-014] Frontend: Componentes MonthComparativeDashboard`

**Descripción**:
```
Crear componentes React en frontend/src/components/:

- MonthComparativeDashboard.jsx (contenedor principal)
- MonthRangeSelector.jsx (selector de rango)
- KPIComparativeCards.jsx (KPIs lado a lado)
- BalanceLineChart.jsx (gráfico de línea con Recharts)
- IncomesExpensesBarChart.jsx (gráfico de barras)
- CategoryDistributionPie.jsx (gráfico pie)
- CategoryDeviationTable.jsx (tabla de deviaciones)

Ver: openspec/changes/exp-feat-014-comparative-dashboard/design.md

Dependencias: Issue #2 (Backend endpoints)
```

**Labels**: `EXP-FEAT-014`, `frontend`, `ui-components`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Issue #4: Frontend - Integración en Router y API client

**Título**: `[EXP-FEAT-014] Frontend: Integración en Router + API client`

**Descripción**:
```
1. Agregar ruta /dashboard/comparison en App.jsx
2. Agregar link en navbar
3. Implementar en frontend/src/services/api.js:
   - monthsAPI.getComparison(start, end)
   - monthsAPI.getDeviations(start, end)

Dependencias: Issue #3 (Componentes)
```

**Labels**: `EXP-FEAT-014`, `frontend`, `routing`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Issue #5: Frontend - Export a CSV/PDF

**Título**: `[EXP-FEAT-014] Frontend: Exportación a CSV y PDF`

**Descripción**:
```
Implementar botones de exportación en MonthComparativeDashboard:

- Exportar a CSV (datos tabulares)
- Exportar a PDF (con gráficos incrustados usando html2canvas + jsPDF)

Dependencias: Issue #3 (Componentes)
```

**Labels**: `EXP-FEAT-014`, `frontend`, `export`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Issue #6: Testing - Unit tests backend

**Título**: `[EXP-FEAT-014] Testing: Unit tests para funciones de comparativa`

**Descripción**:
```
Crear tests en backend/tests/:

- test_get_months_comparison (casos válidos/inválidos)
- test_calculate_deviations (diferentes magnitudes)
- test_endpoints_comparison (mock data)

Cobertura mínima: 80%

Dependencias: Issue #2 (Endpoints)
```

**Labels**: `EXP-FEAT-014`, `testing`, `backend`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Issue #7: Testing - Integration tests

**Título**: `[EXP-FEAT-014] Testing: E2E tests para dashboard comparativo`

**Descripción**:
```
Crear tests E2E:

- Flujo completo: seleccionar rango → cargar datos → renderizar gráficos
- Validar alertas en rojo para deviaciones >20%
- Verificar exportación CSV/PDF

Dependencias: Issues #4, #5 (Frontend completo)
```

**Labels**: `EXP-FEAT-014`, `testing`, `e2e`

**Milestone**: `exp-feat-014-comparative-dashboard`

---

## Resumen de Dependencias

```
Issue #1 (Backend functions)
  ↓
Issue #2 (Backend endpoints)
  ↓
Issue #3 (Frontend components)
  ├→ Issue #4 (Router + API)
  ├→ Issue #5 (Export CSV/PDF)
  └→ Issue #6 (Unit tests)
      ↓
    Issue #7 (E2E tests)
```

## Timeline Sugerido

| Semana | Tarea | Issues |
|--------|-------|--------|
| Week 1 | Backend | #1, #2 |
| Week 2 | Frontend | #3, #4, #5 |
| Week 3 | Testing | #6, #7 |
| Week 4 | Refinamiento y QA | - |
