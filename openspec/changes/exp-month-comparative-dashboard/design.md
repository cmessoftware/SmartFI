## Context

El dashboard necesita:
- Agregar snapshots mensuales para queries eficientes (evitar recalcular sobre transacciones)
- Soportar rangos de fechas personalizados (meses seleccionados por el usuario)
- Resaltar anomalías sin saturar al usuario
- Permitir drill-down desde agregado → categoría → transacción individual
- Mantener precisión histórica incluso si meses fueron reabiertos/modificados

Depende de `exp-month-close` para existencia de `MonthlyPeriodSnapshot` como fuente de datos.

## Goals / Non-Goals

**Goals:**
- Comparar ingresos, gastos, balance y % ahorro entre meses en un mismo gráfico
- Detectar y visualizar desviaciones con umbral configurable (default 20%)
- Permitir drill-down: mes → top categorías → transacciones
- Exportar datos comparativos en CSV, JSON y PDF
- Dashboard debe cargar en < 2 segundos para 12 meses con 100+ transacciones/mes

**Non-Goals:**
- Predicción o proyección de gastos futuros
- Comparación entre tarjetas de crédito y gastos (cross-module)
- Alertas automáticas push/email al detectar desviaciones

## Decisions

**D1 — Usar `MonthlyPeriodSnapshot` como fuente principal:**
Los snapshots capturados al cierre de mes son la fuente más eficiente y consistente. Para meses abiertos (sin snapshot), calcular en tiempo real sobre transacciones. Esto evita recalcular totales históricos en cada request.

**D2 — Lógica de desviación con umbral configurable:**
El umbral de desviación (default 20%) determina si un mes tiene flag amarillo o rojo. La severidad sigue: >20% → GREEN flag, >30% → YELLOW, >50% → RED. El umbral puede ser configurable por usuario en el futuro.

**D3 — Drill-down en frontend (no endpoint separado para cada nivel):**
El drill-down desde barra de gráfico → modal de detalle de mes reutiliza el endpoint `GET /reports/comparative-months/{year_month}/categories`. No se requiere un endpoint separado por nivel.

**D4 — Exportación PDF del lado del backend:**
Generar PDF en el backend (con ReportLab o similar) garantiza reproducibilidad y consistencia de formato. Los gráficos en PDF serán representaciones tabulares con datos, no imágenes de los charts del frontend.

**D5 — Rango máximo de 5 años:**
Limitar la query a 5 años (60 meses) previene consultas excesivamente pesadas. Para análisis de períodos más largos, el usuario puede exportar y procesar externamente.

## Risks / Trade-offs

- **Riesgo:** Meses sin snapshot (OPEN) tienen datos en tiempo real que pueden diferir del snapshot final. Indicar visualmente en los charts que esos meses son "en curso" (barra punteada/transparente).
- **Trade-off:** Calcular top categorías en el backend agrega complejidad, pero centralizar esta lógica evita cálculos duplicados en frontend.
- **Riesgo:** Export PDF puede ser lento para rangos grandes. Mitigación: limitar PDF a 24 meses, ofrecer CSV para rangos mayores.

## Migration Plan

1. No requiere cambios de schema (depende de tablas de `exp-month-close`).
2. Crear `reports_service.py` con funciones de agregación y desviación.
3. Agregar endpoints de reportes a `main.py`.
4. Deploy backend con nuevos endpoints.
5. Deploy frontend con nueva sección de reportes comparativos.
