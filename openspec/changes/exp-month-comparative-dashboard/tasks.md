## Backend

- [ ] 1.1 Crear queries/views de agregación mensual (ingresos, gastos, balance por mes)
- [ ] 1.2 Implementar `reports_service.get_comparative_months(start_month, end_month)` con cálculo de desviaciones
- [ ] 1.3 Implementar `reports_service.get_month_categories_breakdown(year_month)`
- [ ] 1.4 Implementar `reports_service.get_category_comparison(category_id, start_month, end_month)` para análisis de tendencias
- [ ] 1.5 Implementar lógica de desviación con umbral configurable (default 20%, severidades GREEN/YELLOW/RED)
- [ ] 1.6 Crear endpoint `GET /reports/comparative-months` con filtros de rango de fechas
- [ ] 1.7 Crear endpoint `GET /reports/comparative-months/{year_month}/categories`
- [ ] 1.8 Crear endpoint `GET /reports/category-comparison/{category_id}`
- [ ] 1.9 Implementar exportación CSV para reporte comparativo
- [ ] 1.10 Implementar exportación JSON para reporte comparativo
- [ ] 1.11 Implementar exportación PDF con datos tabulares (usando ReportLab o similar)

## Frontend

- [ ] 2.1 Crear componente `ComparativeDashboard` (contenedor principal con layout 4 tarjetas + 4 gráficos)
- [ ] 2.2 Crear componente `DateRangePicker` (botones rápidos: 3/6/12 meses + selector personalizado)
- [ ] 2.3 Crear componente `MetricCard` (Ingreso/Gasto/Balance/Ahorro % promedio)
- [ ] 2.4 Crear componente `TrendChart` (barras con Chart.js, color-coding por desviación)
- [ ] 2.5 Crear componente `MonthDetailCard` (al hacer click en barra: resumen + top 10 categorías)
- [ ] 2.6 Crear componente `CategoryComparisonChart` (drill-down a tendencia de categoría)
- [ ] 2.7 Crear componente `ExportModal` (selector de formato CSV/JSON/PDF + botón descargar)
- [ ] 2.8 Integrar indicador visual de meses "en curso" (barra punteada/semitransparente para OPEN)
- [ ] 2.9 Implementar color-coding de barras por severidad de desviación (GREEN/YELLOW/RED)
- [ ] 2.10 Agregar nueva ruta/sección "Reportes Comparativos" en el menú de navegación

## Testing

- [ ] 3.1 Tests unitarios para `get_comparative_months()`, cálculo de desviaciones, `get_month_categories_breakdown()`
- [ ] 3.2 Tests de integración para endpoints de reportes (datos comparativos, categorías, exports)
- [ ] 3.3 Tests de UI para selector de rango, gráficos, modals de drill-down, export
- [ ] 3.4 Test de performance: Dashboard carga en < 2 segundos para 12 meses con 100+ transacciones/mes
- [ ] 3.5 Test end-to-end: Seleccionar rango → Ver tendencias → Click categoría → Verificar detalle → Exportar CSV/PDF → Verificar archivo
- [ ] 3.6 Validar todos los escenarios de error (tabla de 5 errores del spec)
- [ ] 3.7 Documentar uso del dashboard en README (guía de usuario con interpretación de gráficos)
