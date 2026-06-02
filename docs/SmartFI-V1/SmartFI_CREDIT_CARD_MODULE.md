Modulo de tarjeta de crédito

Backlog Estructurado (OpenPEC-ready)

Modelo de ticket
- id: prefijo + numero (`CC-FEAT-###` o `CC-BUG-###`)
- tipo: `feature` | `bug`
- prioridad: `alta` | `media` | `baja`
- estado: `todo` | `in_progress` | `blocked` | `done`
- resumen: una linea con impacto de negocio
- alcance: backend | frontend | data
- criterio_aceptacion: resultado verificable
- evidencia: fix aplicado, endpoint, PR, query o captura

## Features Pendientes

| ID | Tipo | Prioridad |Issue Padre|Issue Gitea| Estado | Resumen |
|---|---|---|---|---|---|---|
| CC-FEAT-001 | Feature | Alta ||| ✅ Done | Registrar gastos del periodo actual de forma consistente con periodo de tarjeta (no mes calendario) |
| CC-FEAT-002 | Feature | Alta ||| ⏳ Todo | Registrar monto total como item de presupuesto del mes siguiente al cierre |
| CC-FEAT-003 | Feature | Alta ||| ✅ Done | Calculo de cuotas futuras para compras en cuotas |
| CC-FEAT-004 | Feature | Media ||| ⏳ Todo | Calculo de montos ARS para compras en USD segun tipo de cambio |
| CC-FEAT-005 | Feature | Media ||| ✅ Done | Implementar funcionalidad del punto 3 de FINLY_BUDGET_MODULE.md en pagina Presupuesto |
| CC-FEAT-006 | Feature | Alta ||| ✅ Done | Registrar pago en Resumen de Tarjeta indicando monto e item de presupuesto |
| CC-FEAT-007 | Feature | Media ||| ⏳ Todo | Opcion para registrar gasto de nuevo periodo y revisar regresion de visibilidad de botones |
| CC-FEAT-008 | Feature | Alta ||| ✅ Done | Agregar opcion para editar pago registrado desde Resumen del Periodo |
| CC-FEAT-009 | Feature | Baja ||| ⏳ Todo | Paginacion de compras del periodo (5 lineas) |
| CC-FEAT-010 | Feature | Alta ||| ✅ Done | Los periodos no son meses calendario; agregar opcion de definir rango de fechas del periodo |
| CC-FEAT-011 | Feature | Alta ||| ✅ Done | Visualizacion y manejo de periodos de tarjeta (period_start, period_end, closing_date, due_date) |
| CC-FEAT-012 | Feature | Alta ||| ⏳ Todo | Validar pagos fuera de periodo, sugerir periodo correcto y confirmar movimiento |
| CC-FEAT-013 | Feature | Alta ||| ⏳ Todo | En importacion CSV, fecha de cierre debe imputar al periodo cuyo cierre coincide |
| CC-FEAT-014 | Feature | Media ||| ⏳ Todo | Ordenar y filtrar compras del periodo por monto |
| CC-FEAT-015 | Feature | Media ||| ⏳ Todo | Agrupar lista por compras en cuotas y luego compras 1 cuota |
| CC-FEAT-016 | Feature | Baja ||| ⏳ Todo | Icono tooltip para detalle de item |
| CC-FEAT-017 | Feature | Alta ||| ⏳ Todo | Bloquear cargas manual/csv fuera de ventana cierre-vencimiento, con override por rol |
| CC-FEAT-018 | Feature | Alta ||| ⏳ Todo | Si CSV contiene items fuera de politica del periodo, rechazar lote completo |
| CC-FEAT-020 | Feature | Baja ||| ⏳ Todo | Ocultar combo tipo de plan en Nueva Compra |
| CC-FEAT-021 | Feature | Baja ||| ⏳ Todo | Agregar textbox detalle (20 caracteres) en Nueva Compra |
| CC-FEAT-022 | Feature | Alta ||| ✅ Done | USD al periodo siguiente con campo `billing_date` (propuesta Opcion A) |
| CC-FEAT-023 | Feature | Alta ||| ⏳ Todo | Al registrar pagos del resumen actual, proyectarlos automaticamente en el periodo siguiente como movimientos negativos tipo "SU PAGO EN PESOS" para estimar el proximo resumen |
|CC-FEAT-024|Feature|Alta||#125|✅ Done |Extracciones de tarjeta con impacto dual: gasto actual + deuda |   

**Resumen:** 23 features, 11 completadas (48%), 12 pendientes (52%)

## Bugs Pendientes

| ID | Prioridad |Issue Padre|Issue Gitea| Estado | Resumen |
|---|---|---|---|---|---|
| CC-BUG-001 | Alta ||| ✅ Done | Editar gasto a monto USD no actualiza la lista de pagos registrados |
| CC-BUG-002 | Alta ||| ✅ Done | Cuotas calculadas con formula incorrecta; debe usar amortizacion francesa |
| CC-BUG-003 | Alta ||| ✅ Done | Registrar pago en presupuesto debia ser el total del periodo, no item por item |
| CC-BUG-004 | Alta ||| ✅ Done | Pago minimo no es porcentaje fijo; debe ser configurable por periodo |
| CC-BUG-005 | Media ||| ✅ Done | Descripcion de item de presupuesto no incluia monto minimo del periodo |
| CC-BUG-006 | Alta ||| ✅ Done | Error al eliminar item generado desde Registrar en Presupuesto (clase Debt inexistente) |
| CC-BUG-007 | Alta ||| ✅ Done | Resumen del periodo no sumaba todas las compras; standalone aparecia en mes siguiente |
| CC-BUG-008 | Alta ||| ✅ Done | Error 500 al crear tarjeta por conexiones stale (faltaba pool_pre_ping) |
| CC-BUG-008-R1 | Alta ||| ✅ Done | Datos huerfanos de InstallmentPlan/Schedule para compras 1-cuota causaban errores en Resumen |
| CC-BUG-009 | Alta ||| ✅ Done | Gasto en cuotas propagaba todos los gastos del periodo a meses futuros en lugar de solo la cuota |
| CC-BUG-010 | Baja ||| ✅ Done | Navegacion de periodos desaparece al llegar a extremos; debe mantenerse en ultimo valido |
| CC-BUG-011 | Baja ||| ⏳ Todo | Paginacion de compras del periodo a 10 por pagina |
| CC-BUG-012 | Baja ||| ⏳ Todo | Paginacion de cronograma de cuotas a 5 por pagina |
| CC-BUG-013 | Alta ||| ✅ Done | Cambiar label del boton Resumen a Resumen Total |
| CC-BUG-015 | Alta ||| ✅ Done | Fecha invalida al importar CSV con formato dd.MM.yy |
| CC-BUG-016 | Alta ||| ✅ Done | Nueva tarjeta sin funcionalidad: sin Resumen del Periodo ni botones de registro |
| CC-BUG-017 | Alta ||| ✅ Done | Pago registrado en una tarjeta figuraba en ambas tarjetas del mismo mes |
| CC-BUG-018 | Alta ||| ✅ Done | Registrar Pago Minimo usaba porcentaje fijo en lugar del valor personalizado del campo |
| CC-BUG-019 | Alta ||| ✅ Done | Tarjeta ICBC no registraba suma de montos en toast y mantenia mismos gastos en marzo y abril |
| CC-BUG-019-R1 | Alta ||| ✅ Done | Revision bug 19, marzo sin gastos visibles tras fix |
| CC-BUG-020 | Alta ||| ✅ Done | Proximo Pago con formula incorrecta; debe ser saldo impago periodo anterior + total periodo actual |
| CC-BUG-021 | Alta ||| ✅ Done | Luego de registrar pago no aparecia el item de presupuesto ni el registro en Gastos |
| CC-BUG-022 | Alta ||| ✅ Done | No habia forma visible de registrar fecha de cierre y vencimiento del periodo |
| CC-BUG-023 | Media ||| ✅ Done | No se podian borrar tarjetas inactivas (ahora soft delete en activas, inactivas sin boton) |
| CC-BUG-024 | Alta ||| ✅ Done | Pago registrado no se restaba de Pendiente de Gastos en modulo de tarjetas |
| CC-BUG-025 | Baja ||| ⏳ Todo | Editar moneda ARS->USD no refresca cabecera Total Pendiente sin reload |
| CC-BUG-026 | Alta ||| ⏳ Todo | Editar fecha de gasto no mueve de periodo; debe validar y mover con confirmacion |
| CC-BUG-027 | Alta ||| ✅ Done | Gasto en cuotas propagaba hasta diciembre copiando todos los gastos del periodo |
| CC-BUG-028 | Baja ||| ⏳ Todo | UX: Al cambiar fecha de item en cuotas no se actualiza el panel de Cronograma de Cuotas |
| CC-BUG-029 | Alta |CC-FEAT-024|#133| ✅ Done | Nueva Compra muestra opción visible de extracción en efectivo, con comisión obligatoria y 1 cuota (Issue Gitea #133) |
| CC-BUG-030| Alta | CC-FEAT-024 |#133| ✅ Done | Comisión de extracción expresada en % (no valor absoluto) y aplicada al gasto total en módulo Gastos (monto extracción + comisión) |


**Resumen:** 29 bugs, 26 resueltos (90%), 3 pendientes (10%)

## OpenSpec Changes

| Change | Descripción | IDs Relacionados | Estado |
|--------|-------------|-----------------|--------|
| `formalize-credit-card-module` | Formalización del módulo en spec-driven | — | 📋 Backlog |
| `cc-bugs-critical` | Bugs críticos de UX, paginación y cronograma | CC-BUG-010, CC-BUG-011, CC-BUG-012 | 📋 Backlog |
| `cc-period-policy` | Validación de ventanas temporales de períodos | CC-FEAT-012, CC-FEAT-013, CC-FEAT-017, CC-FEAT-018 | 📋 Backlog |
| `cc-ux-improvements` | Mejoras de usabilidad (paginación, orden, agrupado, tooltip) | CC-FEAT-009, CC-FEAT-014, CC-FEAT-015, CC-FEAT-016, CC-FEAT-020, CC-FEAT-021 | 📋 Backlog |
| `cc-period-budget-registration` | Registro automático del total del período en presupuesto | CC-FEAT-002, CC-FEAT-007 | 📋 Backlog |
| `credit-card-usd-billing-date` | Compras USD con `billing_date` correcto al período siguiente | CC-FEAT-004, CC-FEAT-022 | ✅ Done |
| `cc-bug-029-cash-advance-visibility` | Corrección UX para visibilidad de extracción en Nueva Compra | CC-BUG-029 | ✅ Done |
| `cc-bug-030-cash-advance-fee-percent` | Comisión de extracción en porcentaje y suma correcta en Gastos | CC-BUG-030 | ✅ Done |
| `cc-next-statement-estimation` | Proyección automática de pagos al período siguiente | CC-FEAT-023 | 📋 Backlog |
| `cc-period-close` | Cierre de período con lifecycle OPEN/CLOSED/REOPENED y snapshot | — | 📋 Backlog |
| `cc-period-open-rollover` | Apertura de período con carryover de saldo pendiente | — | 📋 Backlog |

OpenPEC CLI (plantilla de carga)
- Nota: `openpec` no esta instalado actualmente en el entorno local. Se deja plantilla para ejecutar cuando este disponible.
- Ejemplo de alta de bug:
   `openpec issue create --id CC-BUG-026 --type bug --priority alta --status todo --title "Editar fecha de gasto no mueve de periodo" --scope "backend,frontend"`
- Ejemplo de alta de feature:
   `openpec issue create --id CC-FEAT-022 --type feature --priority alta --status todo --title "USD al periodo siguiente con billing_date" --scope "backend,data"`
- Ejemplo de transicion de estado:
   `openpec issue update --id CC-BUG-026 --status in_progress`
   `openpec issue update --id CC-BUG-026 --status done`

