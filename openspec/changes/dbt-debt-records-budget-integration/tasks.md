## 1. Fundacion DBT (fuente de verdad)

- [ ] 1.1 Backend: formalizar endpoints `debt-records` como API primaria de deudas no tarjeta.
- [ ] 1.2 Backend: definir trazabilidad entre `DebtRecord` y proyeccion `BudgetItem`.
- [ ] 1.3 Frontend: redirigir flujo de Deudas para consumir `debt-records` como fuente primaria.

## 2. Alta de deuda con datos completos

- [ ] 2.1 Backend: validar contrato de entrada (interes anual, cuotas, cuota actual, cuotas pendientes, fuente, comentarios).
- [ ] 2.2 Frontend: formulario de alta/edicion con campos funcionales completos.
- [ ] 2.3 Backend/Data: persistir campos y valores por defecto consistentes.

## 3. Proyeccion mensual a Presupuesto

- [ ] 3.1 Backend: generar items de presupuesto por mes calendario (cuota X/Y).
- [ ] 3.2 Backend: garantizar idempotencia al recalcular proyecciones.
- [ ] 3.3 Frontend: visualizar y filtrar proyecciones asociadas a DBT.

## 4. Pago parcial/total y reconciliacion

- [ ] 4.1 Backend: aplicar pagos desde presupuesto al saldo pendiente en `DebtRecord`.
- [ ] 4.2 Backend: recalcular cuotas pendientes tras cada pago.
- [ ] 4.3 Frontend: mostrar estado de saldo y avance actualizado sin recarga manual.

## 5. Regla de cuotas fraccionarias

- [ ] 5.1 Backend: aplicar precision de 2 decimales en cuotas pendientes.
- [ ] 5.2 Frontend: mostrar 2 decimales de forma consistente en tabla, resumen y detalle.
- [ ] 5.3 Validacion: casos de borde de redondeo (ej. 6.666 -> 6.67).

## 6. Analitica y visualizaciones

- [ ] 6.1 Frontend/Backend: pie historico por fuente de deuda.
- [ ] 6.2 Frontend/Backend: pie de mes actual por fuente de deuda.
- [ ] 6.3 Frontend/Backend: barras + linea en ventana de 12 meses centrada en el mes actual.

## 7. Ejecucion en Gitea (modelo de issues)

- [ ] 7.1 Crear 2 issues padre por cada FEAT: uno Front y uno Back.
- [ ] 7.2 Cargar tareas internas como checklist dentro de cada issue (sin sub-issues).
- [ ] 7.3 Vincular ambos issues padre al ID funcional DBT-FEAT correspondiente.
