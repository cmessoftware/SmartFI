# SmartFI v1.2.0 — Release Notes

**Fecha:** 2026-07-30  
**Rama origen:** `fix/cash_advanced_commission_error`  
**Commits clave:** `bc0dff9` → `4453589` → `9b6d82e`  
**Producción:** Render (`smartfi-api`, `smartfi-frontend`) + Neon PostgreSQL

---

## Resumen ejecutivo

Release orientada a **producción** con mejoras en el **módulo Deudas**, **extracciones de efectivo en Tarjetas de Crédito**, **performance de API** y **tooling de base de datos** Neon ↔ local.

---

## Módulos — funcionalidad

### Dashboard
Vista general de finanzas: ingresos, gastos, balance del mes, presupuesto pendiente y balance proyectado si se pagan todos los compromisos. Muestra versión de la app en la UI.

### Gastos e Ingresos (EXP)
Registro, edición y eliminación de transacciones con categorías, filtros por mes/detalle, import/export CSV, vinculación a ítems de presupuesto y **cierre/reapertura de mes** contable (writers solo pueden reabrir meses que cerraron ellos).

### Presupuesto (BUD)
Gestión de compromisos mensuales (obligaciones fijas/variables, ingresos planificados): CRUD, clonado al mes siguiente, filtros, resumen por mes, paginación y sincronización con pagos de gastos vinculados.

### Deudas (DBT)
Módulo de deudas **no tarjeta** (`debt-records` como fuente de verdad): alta con interés anual, cuotas, fuente (banco/fintech/etc.), proyección automática en Presupuesto mes a mes, **pagos parciales/totales** con cuotas fraccionarias, y modo **cuota = % del sueldo** con aumentos periódicos.

### Tarjetas de Crédito (CC)
CRUD de tarjetas, compras en cuotas (amortización francesa), periodos de cierre/vencimiento (no mes calendario), import CSV, resumen por periodo, pagos registrados, compras USD con `billing_date`, y **extracciones en efectivo** (`cash_advance`) con comisión, espejo en Gastos y deuda derivada en periodo siguiente.

### Seguridad y Admin
Login JWT, roles Admin / Writer / Reader, gestión de usuarios, permisos por endpoint y CORS configurado para producción.

### Infraestructura
Backend FastAPI + PostgreSQL (Neon PROD, Docker local puerto 5433), frontend React/Vite, migraciones Alembic, deploy en **Render** (API Docker + frontend static), scripts PowerShell para backup/restore Neon.

---

## Novedades de v1.2.0

### Deudas (DBT-FEAT-003 / DBT-FEAT-004)
- Proyección mensual desde `due_date` (no `start_date`), con reconciliación de filas faltantes.
- Endpoint `POST /api/debt-records/{id}/payments` para pagos parciales/totales.
- Cuotas fraccionarias (ej. 2,5 cuotas pendientes) con 2 decimales.
- Modo `SALARY_PERCENT`: cuota = z% del sueldo, con aumento x% cada n meses.
- Modal "Registrar Pago" en `DebtManager.jsx`.
- Tests en `test_debt_record_projection_service.py`.
- Fix EXP-BUG-015: `monto_total` / `monto_ejecutado` desde deuda real, no proyección.

### Tarjetas de Crédito — extracciones (CC-FEAT-024)
- Tipo `cash_advance` con comisión % obligatoria, siempre 1 cuota.
- Espejo en Gastos (monto + comisión) y deuda derivada en periodo siguiente.
- Import CSV con columnas `Tipo Movimiento` y `Comisión`.
- **Fix comisión (`9b6d82e`):** totales incluyen extracción + comisión en modal, lista del periodo, cronograma, resumen agregado y API (`total_with_fees`, `cash_advance_fee_amount`).

### Gastos / Presupuesto
- EXP-BUG-017: reapertura de mes restringida al writer que cerró (motivo ≥ 10 chars).
- Performance: batch de metadata de cuotas en listado de presupuesto (sin N+1).

### Performance y estabilidad API
- `joinedload` de categorías en transacciones.
- Pool Neon: `pool_recycle`, `connect_timeout`.
- Timeout frontend axios: 15s → 45s (cold start Render + latencia Neon).

### Deploy producción (Render + Neon)
- `render.yaml`: API plan **Starter**, frontend **Static Site** con `build:render`.
- `render-build.mjs`: `VITE_API_URL` en build time vía `env-config.js`.
- Scripts: `backup-neon.ps1`, `import-local-to-neon.ps1`, helpers en `postgres-helpers.ps1`.

### DevOps / repo
- `.gitignore`: carpeta `backups/` excluida.
- Versión dinámica en UI.
- OpenSpec: cambios documentados (cash advance, debt records, payment reconciliation).

---

## Migraciones de base de datos

| Migración | Descripción |
|-----------|-------------|
| `f9a4c2e7b1d3` | `movement_type` / `cash_advance_fee` en compras TC |
| `b2c3d4e5f6a7` | Cuota por % sueldo en `debt_records` |
| Otros Alembic en rama | Campos de cuotas y trazabilidad DBT en budget_items |

Ejecutar en PROD (Render shell o local apuntando a Neon):

```bash
cd backend && alembic upgrade head
```

---

## Checklist de deploy

1. Merge de rama → `main`.
2. Render: deploy **`smartfi-api`** y **`smartfi-frontend`** con tag `v1.2.0`.
3. Verificar env vars: `DATABASE_URL`, `VITE_API_URL`, `FRONTEND_URL`.
4. Hard refresh en browser (Ctrl+Shift+R).
5. Smoke test:
   - Login
   - Presupuesto carga en tiempo razonable
   - TC: extracción $10.000 + 6,99% → total $10.699 en UI y API
   - Deudas: registrar pago parcial
   - API devuelve `total_with_fees` en compras

---

## Known issues / backlog

- EXP-BUG-012: categorías sucias en combo (backlog).
- EXP-BUG-018: duplicados en combo presupuesto (limpieza DB + fix en `clone_budget_items`).
- CC-FEAT-023: proyección automática de pagos al periodo siguiente (pendiente).
- Confirmar en Render que el frontend migró de Docker a **Static Site**.

---

## Contribuidores

SmartFI Team — cmessoftware
