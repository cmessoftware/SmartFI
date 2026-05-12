# Tasks - EXP-FEAT-014: Panel Comparativo de Cierres

## Backend Tasks

### B1. Implementar función `get_months_comparison` en `month_service.py`

**Descripción**: Calcular KPIs consolidados (ingresos, gastos, balance) para un rango de meses.

**Input**:
- `start_month`: string "YYYY-MM"
- `end_month`: string "YYYY-MM"
- `user_id`: int

**Output**: JSON con estructura:
```json
{
  "months": [
    {
      "year_month": "2026-01",
      "total_income": 500000,
      "total_expenses": 300000,
      "net_balance": 200000,
      "budget_items_count": 15,
      "budget_items_pending": 3
    },
    ...
  ]
}
```

### B2. Implementar función `get_category_distribution` en `month_service.py`

**Descripción**: Desglose de gastos por categoría para cada mes del rango.

**Output**:
```json
{
  "months": [
    {
      "year_month": "2026-01",
      "categories": [
        {
          "category": "Vivienda",
          "amount": 120000,
          "percentage": 40
        },
        ...
      ]
    },
    ...
  ]
}
```

### B3. Implementar función `calculate_deviations` en `month_service.py`

**Descripción**: Detectar desviaciones >20% entre meses en categorías y totales.

**Output**:
```json
{
  "category_deviations": [
    {
      "category": "Transporte",
      "month": "2026-02",
      "previous_amount": 60000,
      "current_amount": 115000,
      "deviation_percent": 91.7,
      "severity": "critical"
    }
  ],
  "total_deviations": [
    {
      "month": "2026-02",
      "income_deviation": -4,
      "expense_deviation": 26.7,
      "severity": "critical"
    }
  ]
}
```

### B4. Endpoint `GET /api/months/range/{start}/{end}/comparison`

**Descripción**: Retorna comparativa completa de un rango de meses.

**Response**: Combina output de B1, B2, B3.

**Status codes**:
- 200: OK
- 400: Rango inválido (start > end, formato incorrecto)
- 403: No autorizado (no es propietario de los datos)
- 404: Ningún mes en el rango existe

### B5. Endpoint `GET /api/months/range/{start}/{end}/deviations`

**Descripción**: Retorna solo deviaciones críticas (>20%) para alertas.

**Response**:
```json
{
  "alert_count": 3,
  "deviations": [...]
}
```

## Frontend Tasks

### F1. Componente `MonthComparativeDashboard.jsx`

**Descripción**: Contenedor principal que orquesta datos y sub-componentes.

**Estado**: 
- `startMonth`, `endMonth`
- `comparisonData`
- `loading`, `error`

**Funciones**:
- `fetchComparison()`: llama endpoint B4
- `handleMonthsChange()`: recargar datos al cambiar rango

### F2. Componente `MonthRangeSelector.jsx`

**Descripción**: Selector de rango de meses (inicio/fin) con botón "Comparar".

**Props**:
- `onCompare(start, end)`: callback cuando usuario presiona Comparar
- `disabled`: bool

### F3. Componente `KPIComparativeCards.jsx`

**Descripción**: 4 cards lado a lado mostrando Ingresos, Gastos, Balance + indicadores de desviación.

**Props**:
- `months[]`: array de meses con KPIs
- `deviations{}`: mapa de desviaciones por mes

### F4. Componente `BalanceLineChart.jsx`

**Descripción**: Gráfico de línea de balance acumulado usando Recharts.

**Props**:
- `data[]`: array de {month, balance}

### F5. Componente `IncomesExpensesBarChart.jsx`

**Descripción**: Gráfico de barras Ingresos vs Gastos usando Recharts.

**Props**:
- `data[]`: array de {month, income, expenses}

### F6. Componente `CategoryDistributionPie.jsx`

**Descripción**: Gráfico pie de distribución de gastos por categoría.

**Props**:
- `data[]`: array de {category, amount}
- `selectedMonth`: mes a visualizar

### F7. Componente `CategoryDeviationTable.jsx`

**Descripción**: Tabla con detalles de gastos por categoría, desviaciones y alertas.

**Props**:
- `categories[]`: array de {category, months[{amount}], deviations{}}
- `months[]`: array de meses para encabezados

**Features**:
- Ordenar por categoría, desviación
- Color-code severidad (rojo/naranja/verde)

### F8. Integración en App.jsx / Router

**Descripción**: Agregar ruta `/dashboard/comparison` y link en navbar.

### F9. Endpoint client en `api.js`

**Descripción**: Agregar funciones:
- `monthsAPI.getComparison(start, end)`
- `monthsAPI.getDeviations(start, end)`

### F10. Export a CSV/PDF

**Descripción**: Botones de exportación que generan archivos descargables.

**Opciones**:
- CSV: datos tabulares
- PDF: con gráficos incrustados (usar jsPDF + html2canvas)

## Testing Tasks

### T1. Unit tests backend

- Test `get_months_comparison` con rango válido/inválido
- Test `calculate_deviations` con diferentes magnitudes
- Test endpoints con mock data

### T2. Integration tests

- E2E: seleccionar rango → recibir comparativa → renderizar gráficos
- Verificar alertas se muestran en rojo para desviaciones >20%

### T3. Manual testing

- Comparar 2-4 meses reales del sistema
- Validar cálculos contra Excel
- Probar exportación CSV/PDF

## Acceptance Criteria

- ✅ Usuario puede seleccionar rango de 2-4 meses
- ✅ Se visualizan KPIs (ingresos, gastos, balance) lado a lado
- ✅ Alertas rojo/naranja para desviaciones >20%
- ✅ Gráficos de línea, barras y pie funcionan correctamente
- ✅ Tabla de categorías con deviaciones es legible y interactiva
- ✅ Exportación a CSV y PDF funciona
- ✅ Responsive design (desktop, tablet, mobile)
- ✅ No hay errores 404/500 con datos válidos
