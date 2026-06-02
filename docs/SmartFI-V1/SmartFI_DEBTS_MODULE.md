Modulo de registro de deudas bancarias y no bancarias (no de tarjeta de crédito)

Backlog Estructurado (OpenPEC-ready)

Modelo de ticket
- id: prefijo + numero (`DBT-FEAT-###` o `DBT-BUG-###`)
- tipo: `feature` | `bug`
- prioridad: `alta` | `media` | `baja`
- estado: `⏳ Todo` | `🔄 In progress` | `blocked` | `✅ Done`
- resumen: una linea con impacto de negocio
- alcance: backend | frontend | data
- criterio_aceptacion: resultado verificable
- evidencia: fix aplicado, endpoint, PR, query o captura

Espeficaciones funcioanales de alto nivel 
Crear opción "Carga de Deudas": 
1. Campos: Fecha,Monto, Interes anual (%),Cantidad de cuotas, Fuente de la deuda (banco, fintech, individuos),Número de cuota actual,pendiente de pago incluido cuota actual, Comentarios.
2. Al registrar una deuda cargarla en módulo de Presupuesto como Ingreso (tipo deuda) indicando monto de cuota actual y número de cuota. Por ejemplo 1000 (cuota 2/6). Propagar el item de presupuesto a meses siguientes hasta terminar la cantidad de cuotas. Usar Mes calendario.
3. Cuando el usuario registra un pago de un item tipo deuda actualizar el monto pendiente en item asociado en módulo deudas.
4. Habiitar opción de pago parcial o total de la deuda, actualizando item según punto 3 acorde al monto pagado. Si no es monto múltiplo de valor cuota asignar pendiente de cuotas fraccionaria. 
   Por ejempo:
    Deuda Total:1.000.000, 
    Interes: 20 % anual, 
    Cant de cuotas: 12, ya se pagaron 3 cuotas de 100.000,pendiente:900.000, cuotas pendientes: 9
    Se pagan 250.000: equivalente a 2,5 cuotas , cuotas pendientes: 6,5
En encabezado de pantalla que muestra la tabla de deudas (usando look&feel de Gastos/Ingresos):
5. Mostrar gráfico de torta del total de deuda mostrandoe el agrupamientos de cada fuente de deuda (banco A, banco B, fitexh A, fintech B, individuo A, individuo B, Empresa A, Empresa B etc).
6. Idem 5 pero del mes actual.
7. Gráfico de barras con linea continua que pase por lo pico de cada barra, indicando la variación de la deuda mes a mes, mostrar ventana de 12 meses, centrada en mes actual.

## Decisiones Funcionales Cerradas

1. Sistema fuente de verdad:
   - Se define `debt-records` como modulo fuente de verdad para deudas no tarjeta.
   - El modulo `Presupuesto` queda como proyeccion/impacto mensual de las deudas (no como entidad canonica de deuda).
   - Integracion requerida: cada deuda y su plan de cuotas debe reflejar items de presupuesto por mes calendario, segun cuota vigente.

2. Cuotas fraccionarias:
   - La cantidad de cuotas pendientes fraccionarias se guarda y muestra con 2 decimales.
   - Regla de redondeo: redondeo comercial a 2 decimales para visualizacion y persistencia funcional.
   - Ejemplo: 6.5 -> 6.50; 6.666 -> 6.67.

3. Alcance de integracion:
   - Alta de deuda en `debt-records` crea/actualiza proyeccion mensual en `Presupuesto` como Ingreso tipo deuda (cuota X/Y).
   - Registro de pago contra item asociado debe reconciliar saldo y cuotas pendientes en `debt-records`.
   - Los dashboards del modulo de deudas deben consumir `debt-records` + agregados por fuente y por mes.


## Features Pendientes

Estado sincronizado con Gitea (2026-06-01):
- Issues `#135` a `#152`: `open`.
- Avance real de implementacion: `DBT-FEAT-001 [BE]` en progreso avanzado (codigo + migracion + smoke test OK), pendiente cierre formal de issue.
- Avance real de implementacion: `DBT-FEAT-002 [FE]` en progreso avanzado (formulario de alta/edicion con campos completos implementado), pendiente smoke test manual y cierre formal de issue.

| ID | Tipo | Prioridad |Issue Padre|Issue Gitea| Estado | Resumen |
|---|---|---|---|---|---|---|
| DBT-FEAT-001 | feature | alta | DEBTS-MVP | #135 (BE), #136 (FE) | ✅ Done | Definir `debt-records` como fuente de verdad e integrar contratos API con Presupuesto (BE validado, FE integrado en vista de Deudas). |
| DBT-FEAT-002 | feature | alta | DBT-FEAT-001 | #137 (BE), #138 (FE) | 🔄 In progress | Implementar alta de deuda no tarjeta con campos completos: interes anual, cuotas, cuota actual, cuotas pendientes, fuente y comentarios (BE completo, FE implementado y pendiente smoke test). |
| DBT-FEAT-003 | feature | alta | DBT-FEAT-001 | #139 (BE), #140 (FE) | ⏳ Todo | Generar proyeccion automatica en Presupuesto por mes calendario (cuota X/Y) al crear deuda. |
| DBT-FEAT-004 | feature | alta | DBT-FEAT-001 | #141 (BE), #142 (FE) | ⏳ Todo | Registrar pago parcial/total y reconciliar saldo + cuotas pendientes fraccionarias en `debt-records`. |
| DBT-FEAT-005 | feature | alta | DBT-FEAT-004 | #143 (BE), #144 (FE) | ⏳ Todo | Aplicar regla de cuotas fraccionarias con precision fija de 2 decimales en backend y frontend. |
| DBT-FEAT-006 | feature | media | DBT-FEAT-001 | #145 (BE), #146 (FE) | ⏳ Todo | Exponer dashboard de deudas por fuente (total historico) con grafico de torta. |
| DBT-FEAT-007 | feature | media | DBT-FEAT-001 | #147 (BE), #148 (FE) | ⏳ Todo | Exponer dashboard de deudas por fuente del mes actual con grafico de torta. |
| DBT-FEAT-008 | feature | media | DBT-FEAT-001 | #149 (BE), #150 (FE) | ⏳ Todo | Exponer variacion de deuda mes a mes (ventana 12 meses centrada en mes actual) con barras + linea. |

## Bugs Pendientes

| DBT-BUG-001 | bug | media | DBT-FEAT-004 | #151 | ⏳ Todo | Corregir desalineacion entre pago registrado en Presupuesto y saldo pendiente en `debt-records`. |
| DBT-BUG-002 | bug | media | DBT-FEAT-005 | #152 | ⏳ Todo | Corregir inconsistencias de redondeo de cuotas fraccionarias entre vistas y persistencia. |
| DBT-BUG-003 | bug | alta | DBT-FEAT-002 | TDB | ✅ Done | Separado sidebar en dos entradas (`Presupuesto` y `Deudas`) y desacoplado el flujo UI/API por vista: Presupuesto vuelve a modal/edicion clasica (fijo/variable, gasto/ingreso) y Deudas mantiene formulario especifico de deuda. |
| DBT-BUG-004 | bug | alta | DBT-BUG-003 | TDB | 🔄 In progress | Implementado fix backend: las proyecciones ya no se crean solo en mes de vencimiento; ahora se generan por mes calendario desde fecha de inicio hasta completar cuotas. Pendiente smoke test funcional en UI. |
| DBT-BUG-005 | bug | media | DBT-BUG-003 | TDB | 🔄 In progress | Implementado fix frontend: estado de cuotas ahora usa cuota actual/total (ej. 1/12) en lugar de 0/12 por campo inexistente. Pendiente smoke test funcional. |
| DBT-BUG-006 | bug | alta | DBT-BUG-003 | TDB | 🔄 In progress | Implementado fix estructural en proyección mensual para evitar duplicación en mes de vencimiento y desalineación tabla/gráfico en Presupuesto. Pendiente validación con datos reales. |

## Plan Issues Gitea (Padres Front/Back por FEAT)

Regla acordada:
- Para cada `DBT-FEAT-00X` crear 2 issues padre en Gitea: uno Front y uno Back.
- No crear sub-issues.
- Las tareas se cargan como checklist dentro de cada issue padre.

| Key | FEAT | Tipo | Titulo sugerido | Estado |
|---|---|---|---|---|
| DBT-FEAT-001-BE | DBT-FEAT-001 | Back | [DBT-FEAT-001][BE] Fuente de verdad debt-records + contratos API | 🔄 In progress |
| DBT-FEAT-001-FE | DBT-FEAT-001 | Front | [DBT-FEAT-001][FE] Consumo front de debt-records como fuente primaria | ✅ Done |
| DBT-FEAT-002-BE | DBT-FEAT-002 | Back | [DBT-FEAT-002][BE] Alta de deuda con campos completos | ✅ Done |
| DBT-FEAT-002-FE | DBT-FEAT-002 | Front | [DBT-FEAT-002][FE] Formulario alta/edicion con campos completos | 🔄 In progress |
| DBT-FEAT-003-BE | DBT-FEAT-003 | Back | [DBT-FEAT-003][BE] Proyeccion mensual a presupuesto por cuota | ⏳ Todo |
| DBT-FEAT-003-FE | DBT-FEAT-003 | Front | [DBT-FEAT-003][FE] Visualizacion de proyecciones y cuota X/Y | ⏳ Todo |
| DBT-FEAT-004-BE | DBT-FEAT-004 | Back | [DBT-FEAT-004][BE] Reconciliacion de pagos y saldo pendiente | ⏳ Todo |
| DBT-FEAT-004-FE | DBT-FEAT-004 | Front | [DBT-FEAT-004][FE] Flujo de pago parcial/total y estado de deuda | ⏳ Todo |
| DBT-FEAT-005-BE | DBT-FEAT-005 | Back | [DBT-FEAT-005][BE] Precision 2 decimales en cuotas fraccionarias | ⏳ Todo |
| DBT-FEAT-005-FE | DBT-FEAT-005 | Front | [DBT-FEAT-005][FE] Presentacion consistente de 2 decimales | ⏳ Todo |
| DBT-FEAT-006-BE | DBT-FEAT-006 | Back | [DBT-FEAT-006][BE] Agregados historicos por fuente de deuda | ⏳ Todo |
| DBT-FEAT-006-FE | DBT-FEAT-006 | Front | [DBT-FEAT-006][FE] Grafico de torta historico por fuente | ⏳ Todo |
| DBT-FEAT-007-BE | DBT-FEAT-007 | Back | [DBT-FEAT-007][BE] Agregados de mes actual por fuente | ⏳ Todo |
| DBT-FEAT-007-FE | DBT-FEAT-007 | Front | [DBT-FEAT-007][FE] Grafico de torta mes actual por fuente | ⏳ Todo |
| DBT-FEAT-008-BE | DBT-FEAT-008 | Back | [DBT-FEAT-008][BE] Serie 12 meses para variacion de deuda | ⏳ Todo |
| DBT-FEAT-008-FE | DBT-FEAT-008 | Front | [DBT-FEAT-008][FE] Grafico barras + linea (12 meses) | ⏳ Todo |

### Template de checklist para issue Back (usar dentro de cada issue padre BE)

- [ ] Definir/ajustar contrato de endpoint para el FEAT.
- [ ] Implementar logica de negocio en servicio correspondiente.
- [ ] Ajustar persistencia/modelo y migracion Alembic si aplica.
- [ ] Agregar validaciones y manejo de errores.
- [ ] Verificar compatibilidad con datos existentes.
- [ ] Agregar/actualizar pruebas backend.

### Template de checklist para issue Front (usar dentro de cada issue padre FE)

- [ ] Ajustar cliente API y mapeo de payload/response.
- [ ] Implementar/ajustar componentes y estados de UI.
- [ ] Manejar mensajes de validacion y error.
- [ ] Verificar consistencia visual de tabla, resumen y graficos.
- [ ] Probar flujo end-to-end con backend actualizado.

## Avance Implementacion DBT-FEAT-001 (Backend)

Fecha: 2026-06-01

Implementado en codigo:
- Contratos tipados para API `debt-records` (create/update/payment) en `backend/main.py`.
- Endpoint consolidado para frontend: `GET /api/debt-records/projected`.
- Reglas de trazabilidad `DebtRecord -> BudgetItem` en `backend/services/debt_record_service.py`.
- Sincronizacion de proyeccion en create/update/payment/delete de deuda.
- Migracion Alembic para trazabilidad DBT en `budget_items`:
   - `debt_record_id`
   - `debt_quota_number`
   - `debt_total_quotas`
   - `debt_source`
   - archivo: `backend/alembic/versions/f1c2d3e4b5a6_add_dbt_traceability_to_budget_items.py`

Validado localmente:
- Migracion aplicada en BD local: `alembic_version = f1c2d3e4b5a6`.
- Columnas DBT en `budget_items` presentes: `debt_record_id`, `debt_quota_number`, `debt_total_quotas`, `debt_source`.
- API backend levantada y endpoint proyectado operativo: `GET /api/debt-records/projected` (401 sin token, esperado por autenticacion).
- Endpoint visible en OpenAPI (`/openapi.json`).

Pendiente de este FEAT:
- Ajuste de reglas de proyeccion por cuota `X/Y` para DBT-FEAT-003.

Avance Frontend #136 (2026-06-01):
- `DebtManager` consume `GET /api/debt-records/projected` como fuente primaria de datos.
- Se agrego `debtRecordsAPI` en frontend con mapeo a la forma de datos esperada por la UI actual.
- Alta/edicion/baja desde la vista de Deudas ahora usa endpoints de `debt-records`.

## Avance Implementacion DBT-FEAT-002 (Backend)

Fecha: 2026-06-01

Implementado en codigo:
- Campos nuevos en `DebtRecord` para alta completa:
   - `debt_source`
   - `total_installments`
   - `current_installment`
   - `pending_installments`
- Contratos API actualizados para create/update en `backend/main.py`.
- Persistencia y serializacion actualizadas en `backend/services/debt_record_service.py`.
- Regla backend para cuotas: si no se envia `pending_installments` y existen `total_installments` + `current_installment`, se calcula automaticamente.
- Detalle de proyeccion mensual ahora incluye cuota `X/Y` cuando corresponde.

Migracion Alembic:
- `backend/alembic/versions/c7d8e9f0a1b2_add_installment_fields_to_debt_records.py`
- Estado local validado: `alembic_version = c7d8e9f0a1b2`.

Pendiente para cerrar FEAT-002 completo:
- Integracion frontend del formulario con campos explicitos de tasa, cuota actual y total de cuotas (`#138`).


OpenPEC CLI (plantilla de carga)
- Nota: `openpec` no esta instalado actualmente en el entorno local. Se deja plantilla para ejecutar cuando este disponible.
- Ejemplo de alta de bug:
   `openpec issue create --id DBT-BUG-001 --type bug --priority alta --status todo --title "Editar fecha de gasto no mueve de periodo" --scope "backend,frontend"`
- Ejemplo de alta de feature:
   `openpec issue create --id DBT-FEAT-001 --type feature --priority alta --status todo --title "Alta de deuda no tarjeta con proyeccion a presupuesto" --scope "backend,frontend,data"`
- Ejemplo de transicion de estado:
   `openpec issue update --id DBT-BUG-001 --status in_progress`
   `openpec issue update --id DBT-BUG-001 --status done`

