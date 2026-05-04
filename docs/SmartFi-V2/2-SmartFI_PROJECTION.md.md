2. Módulo: Proyección Probabilística de Finanzas
2.1. Función

- Generar proyecciones mensuales de:

  - Ingresos
  - Gastos
  - Ahorro neto
  - Déficit/superávit

Para 6–12 meses.

2.2. Inputs

  - Historial de transacciones (mín. 3 meses)
  - Deudas y compromisos futuros

- Supuestos:
  - Inflación mensual esperada
  - Incrementos salariales (porcentaje y frecuencia)
  - Crecimiento esperado de ingresos variables

2.3. Procesamiento

- Separación:
  - Gastos fijos (determinísticos)
  - Gastos variables (probabilísticos)

- Modelado:
  - Distribuciones simples (normal / triangular)
  - Simulación Monte Carlo (N iteraciones)
  - Ajuste por inflación: gasto(t)=gasto(t−1)*(1+inflacion)

3.4. Outputs

- Por mes:
  - Valor esperado (mean)
  - Intervalo de confianza (p10, p50, p90)
  - Probabilidad de: déficit cumplir objetivo de ahorro

- 3.5. KPIs
  - prob_deficit
  - expected_savings
  - cashflow_volatility