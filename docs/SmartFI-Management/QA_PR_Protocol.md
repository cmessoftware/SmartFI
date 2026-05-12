# QA PR Protocol (Usuario Unico)

Este protocolo permite ejecutar pruebas funcionales de PR usando un solo usuario QA sin contaminar datos productivos.

## 1. Preparacion

- Usuario fijo de pruebas: `qa_tester`
- Identificador del PR: `PR-XXX`
- Prefijo de datos del ciclo: `QA_PRXXX_YYYYMMDD`

## 2. Aislamiento de datos

- Crear todos los datos de prueba con prefijo obligatorio en `detalle`.
- Usar montos pequenos.
- No mezclar datos de prueba con datos sin prefijo.

## 3. Verificacion de entorno

- Confirmar que `http://localhost:5173` y `http://localhost:3000` muestran los mismos datos para `qa_tester`.
- Si no sincroniza, frenar la prueba y revisar `API_URL`/variables de entorno del frontend.

## 4. Setup del escenario

- Crear datos base del caso (por ejemplo: 2 FIJO + 1 VARIABLE).
- Registrar bitacora minima: fecha, usuario, prefijo e IDs creados.

## 5. Ejecucion funcional

- Ejecutar flujo principal del PR.
- Ejecutar al menos un reintento para validar idempotencia/no-duplicacion.
- Probar caso feliz y un caso borde.

## 6. Validacion

- Verificar resultado esperado en UI y consistencia en reportes.
- Verificar que no impacte meses o entidades fuera del escenario.

## 7. Limpieza

- Borrar/revertir solo registros con prefijo `QA_PRXXX_YYYYMMDD`.
- Confirmar conteo final en cero para ese prefijo.

## 8. Cierre QA del PR

- Resultado: `PASS` o `FAIL`.
- Evidencia minima:
  - que se probo
  - que resultado se obtuvo
  - IDs afectados
  - riesgos remanentes

## Plantilla de bitacora por PR

```text
PR: PR-XXX
Usuario QA: qa_tester
Prefijo: QA_PRXXX_YYYYMMDD
Escenario: (ej. clonado fijo abril->mayo)
Datos creados: (IDs)
Resultado esperado: ...
Resultado real: ...
Estado: PASS/FAIL
Limpieza ejecutada: SI/NO
Observaciones: ...
```

## Caso especifico: Clonado de gastos fijos abril -> mayo

Usar este checklist para validar FEAT-017/018 sin romper datos existentes.

### Datos de prueba sugeridos

- `QA_PRXXX_YYYYMMDD_FIJO_1`
- `QA_PRXXX_YYYYMMDD_FIJO_2`
- `QA_PRXXX_YYYYMMDD_VAR_1`

### Pasos

1. Ingresar como `qa_tester` en 5173 o 3000.
2. Ir a abril 2026.
3. Si abril esta cerrado, reabrir abril para `qa_tester`.
4. Crear 2 items FIJO y 1 item VARIABLE con el prefijo del PR.
5. Cerrar abril nuevamente.
6. Ir a mayo 2026 y ejecutar "Clonar gastos fijos".
7. Verificar en mayo:
	- aparecen los 2 FIJO
	- no aparece el VARIABLE
8. Repetir "Clonar gastos fijos" para verificar idempotencia:
	- no se crean duplicados
9. Registrar resultado en la bitacora del PR.
10. Limpiar datos por prefijo al finalizar.
