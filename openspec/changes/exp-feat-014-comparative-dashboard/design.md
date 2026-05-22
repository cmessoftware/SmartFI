# Design - EXP-FEAT-014: Panel Comparativo de Cierres

## UI Layout

### Main View: MonthComparativeDashboard

```
┌─ Selector de rango de meses ─────────────────────────────────┐
│ [Mes Inicial: Enero 2026]  [Mes Final: Abril 2026] [Comparar] │
└─────────────────────────────────────────────────────────────┘

┌─ KPIs Comparativos (Cards lado a lado) ──────────────────────┐
│ Enero 2026    │ Feb 2026      │ Marzo 2026    │ Abril 2026    │
│ Ingresos:     │ Ingresos:     │ Ingresos:     │ Ingresos:     │
│ $500,000 ✓    │ $480,000 ⚠️   │ $520,000 ✓    │ $510,000 ✓    │
│               │               │               │               │
│ Gastos:       │ Gastos:       │ Gastos:       │ Gastos:       │
│ $300,000 ✓    │ $380,000 🔴   │ $290,000 ✓    │ $295,000 ✓    │
│               │               │               │               │
│ Balance:      │ Balance:      │ Balance:      │ Balance:      │
│ +$200,000     │ +$100,000     │ +$230,000     │ +$215,000     │
└─────────────────────────────────────────────────────────────┘

┌─ Gráfico de Línea: Balance Acumulado ─────────────────────────┐
│                                                                │
│    +$200K ┤     ╱╲                                             │
│           │    ╱  ╲╱╲                                          │
│    +$100K ┤___╱      ╲                                         │
│           │                                                    │
│        0K ├────────────────────────────────────────────        │
│           ├────┬────┬────┬────┬────                            │
│           Ene  Feb  Mar  Abr  May                              │
│                                                                │
└─────────────────────────────────────────────────────────────┘

┌─ Gráfico de Barras: Ingresos vs Gastos ──────────────────────┐
│                                                                │
│  $500K ┤ ┌─────┐                                               │
│        │ │ Ing │ ┌─────┐  ┌─────┐  ┌─────┐                  │
│  $400K ┤ │     │ │ Ing │  │ Ing │  │ Ing │                  │
│        │ │     │ │     │  │     │  │     │                  │
│  $300K ┤ └─────┘ └─────┘  └─────┘  └─────┘                  │
│        │ ┌─────┐ ┌─────┐  ┌─────┐  ┌─────┐                  │
│  $200K ┤ │ Gto │ │ Gto │  │ Gto │  │ Gto │                  │
│        │ │     │ │     │  │     │  │     │                  │
│  $100K ┤ └─────┘ └─────┘  └─────┘  └─────┘                  │
│        │ ├────┬────┬────┬────┬────                            │
│        │ Ene  Feb  Mar  Abr  May                              │
│                                                                │
└─────────────────────────────────────────────────────────────┘

┌─ Pie Chart: Distribución Gastos por Categoría (mes seleccionado) ─┐
│                                                                    │
│           ╱────────╲                                              │
│        ╱─ Servicios (25%) ──╲                                    │
│      ╱                       ╲                                   │
│    │  Vivienda (40%)          │ Alimentación (15%)            │
│    │                           │                              │
│      ╲                       ╱                                   │
│        ╲─ Transporte (20%) ╱                                    │
│           ╲────────╱                                              │
│                                                                    │
└─────────────────────────────────────────────────────────────────┘

┌─ Tabla: Detalles por Categoría (Deviaciones) ────────────────────┐
│ Categoría      │ Enero    │ Feb      │ Marzo    │ Abril  │ Δ%   │
│────────────────┼──────────┼──────────┼──────────┼────────┼──────│
│ Vivienda       │ $120,000 │ $120,000 │ $115,000 │ $120K  │ ±0%  │
│ Servicios      │ $75,000  │ $95,000  │ $80,000  │ $82K   │ 🔴20%│
│ Alimentación   │ $45,000  │ $50,000  │ $42,000  │ $45K   │ ✓    │
│ Transporte     │ $60,000  │ $115,000 │ $53,000  │ $48K   │ 🔴40%│
└─────────────────────────────────────────────────────────────────┘

[Exportar CSV] [Exportar PDF]
```

### Alert Indicators

- ✓ Verde: Variación ≤ 5% (estable)
- ⚠️ Naranja: Variación 5-20% (moderado)
- 🔴 Rojo: Variación > 20% (crítico)

## Component Hierarchy

```
MonthComparativeDashboard
├── MonthRangeSelector
│   ├── MonthPicker (inicio)
│   └── MonthPicker (fin)
├── KPIComparativeCards
│   └── KPICard (x4 meses)
├── BalanceLineChart
├── IncomesExpensesBarChart
├── CategoryDistributionPie
├── CategoryDeviationTable
└── ExportActions
```

## Data Flow

1. Usuario selecciona rango de meses (ej: Ene-Abr 2026)
2. Frontend solicita `GET /api/months/range/2026-01/2026-04/comparison`
3. Backend retorna JSON con KPIs y detalles por mes y categoría
4. Frontend calcula desviaciones y renderiza gráficos y tablas
5. Usuario puede filtrar por categoría o exportar los datos

## Color Scheme

- Balance positivo: Verde (#10b981)
- Balance neutral: Gris (#6b7280)
- Balance negativo: Rojo (#ef4444)
- Desviación crítica: Rojo (#dc2626)
- Desviación moderada: Naranja (#f59e0b)
- Estable: Verde claro (#d1fae5)

## Responsive Design

- **Desktop**: Layout 4 columnas con gráficos amplios
- **Tablet**: Layout 2 columnas, gráficos adaptados
- **Mobile**: Layout apilado (1 columna), gráficos simplificados (solo tablas)
