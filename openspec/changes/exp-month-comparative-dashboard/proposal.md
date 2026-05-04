## Why

El módulo de gastos no ofrece ninguna vista integrada para comparar gastos entre meses. Los usuarios deben cambiar manualmente de mes en mes para detectar tendencias, y no existe identificación visual de anomalías ni resumen de desviaciones por categoría. Esto dificulta la toma de decisiones sobre ajustes de presupuesto y la detección de meses con gasto inusual.

## What Changes

- Crear un dashboard de análisis comparativo con gráficos de barras para ingresos, gastos, balance y % ahorro por rango de meses.
- Selector de rango temporal (últimos 3, 6, 12 meses o rango personalizado).
- Alertas visuales codificadas por color (GREEN/YELLOW/RED) para desviaciones configurables.
- Drill-down por mes → categorías → transacciones.
- Exportación de reportes comparativos en CSV, JSON y PDF.

## Capabilities

### New Capabilities

- `monthly-comparison-dashboard`: Dashboard de análisis comparativo multi-mes con gráficos de tendencias, detección automática de desviaciones, drill-down por categoría y exportación de reportes.

### Modified Capabilities

<!-- No hay specs existentes que modificar -->

## Impact

- **Backend** (`backend/main.py`): Nuevos endpoints `/reports/comparative-months`, `/reports/comparative-months/{year_month}/categories`, `/reports/category-comparison/{category_id}`, `/reports/comparative-months/export`.
- **Backend**: Nuevo `reports_service` con lógica de agregación mensual y cálculo de desviaciones.
- **Frontend**: Nueva vista/sección "Reportes Comparativos" con componentes `ComparativeDashboard`, `DateRangePicker`, `MetricCard`, `TrendChart`, `MonthDetailCard`, `CategoryComparisonChart`, `ExportModal`.
- **No hay cambios de schema** (usa snapshots de `monthly_period_snapshots` ya definidos en `exp-month-close`).
