## Why

Usuarios necesitan comparar el desempeño financiero entre meses para detectar tendencias, desviaciones presupuestarias y tomar decisiones informadas. Actualmente no hay forma de visualizar múltiples meses simultáneamente o alertarse sobre variaciones significativas en gastos/ingresos.

## What Changes

- Nuevo panel de **Análisis Comparativo de Cierres**: permite seleccionar 2-4 meses consecutivos y visualizar lado a lado:
  - Ingresos totales
  - Gastos totales
  - Balance neto
  - Gastos por categoría (comparativa con gráficos)
  - Items de presupuesto pendientes vs ejecutados

- **Alertas de desviación**: el sistema resalta en rojo/naranja cuando una categoría o total varía >20% respecto al mes anterior.

- **Gráficos multi-mes**: líneas (balance acumulado), barras (ingresos vs gastos), pie (distribución por categoría).

## Capabilities

### New Capabilities

- `comparative-monthly-dashboard`: Seleccionar rango de 2-4 meses y visualizar KPIs lado a lado (ingresos, gastos, balance).
- `deviation-alerts`: El sistema calcula variación % mes a mes y resalta desviaciones >20%.
- `multi-month-charts`: Gráficos de líneas (balance acumulado), barras (ingresos vs gastos), pie (categorías).
- `export-comparison`: Exportar comparativa a CSV o PDF para reportes.

## Impact

- **Backend** (`backend/services/month_service.py`): Nuevas funciones para cálculo de KPIs multi-mes y detección de desviaciones.
- **Backend** (`backend/main.py`): Endpoints `GET /api/months/range/{start}/{end}/comparison` y `GET /api/months/range/{start}/{end}/deviations`.
- **Frontend**: Nuevo componente `MonthComparativeDashboard.jsx`, gráficos con Chart.js o Recharts, modal de selección de rango de meses.
- **Database**: No requiere cambios de schema (reutiliza tablas existentes).
- **Migrations**: No aplica.

## Timeline

- **Week 1**: Diseño UX/UI, especificación técnica de endpoints y cálculos de deviaciones.
- **Week 2**: Backend: endpoints y lógica de cálculos.
- **Week 3**: Frontend: componentes, gráficos, integración.
- **Week 4**: Testing y refinamiento.
