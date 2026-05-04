# Conversión de documentos SmartFi a Bugs y Features (Gitea + Markdown)

## Objetivo

Convertir documentos desestructurados con formato:

```text
SmartFi_<nombre_modulo>.md
```

en archivos estructurados:

```text
/bugs/BUG-XXX-<slug>.md
/features/FEAT-XXX-<slug>.md
```

y actualizar el índice:

```text
/bugs/README.md
/features/README.md
```

---

## Input esperado

Documento fuente contiene:

* Sección: `Mejoras`
* Sección: `Bugs`

Cada ítem puede tener:

* descripción libre
* estado implícito:

  * vacío → pendiente
  * `RESUELTO` → cerrado

---

## Reglas de parsing

### 1. Identificación de módulo

Extraer desde nombre archivo:

```text
SmartFi_credit_card.md → módulo = credit_card
SmartFi_budget.md → módulo = budget
```

---

### 2. Clasificación

| Sección origen | Output destino |
| -------------- | -------------- |
| Bugs           | /bugs          |
| Mejoras        | /features      |

---

### 3. Estado

#### Bugs

| Input    | Estado final |
| -------- | ------------ |
| vacío    | OPEN         |
| RESUELTO | CLOSED       |

#### Features

| Input    | Estado final |
| -------- | ------------ |
| vacío    | OPEN         |
| RESUELTO | DONE         |

---

### 4. Generación de ID

Formato:

```text
BUG-XXX
FEAT-XXX
```

Reglas:

* correlativo incremental global
* no reutilizar IDs existentes

---

### 5. Generación de slug

Normalizar descripción:

```text
"Error en cálculo de cuotas"
→ error-calculo-cuotas
```

---

## Output esperado

---

## Template BUG

```markdown
# BUG-XXX

## Estado
OPEN | ANALYZED | IN_PROGRESS | FIXED | VERIFIED | CLOSED

## Prioridad
MEDIUM

## Módulo
<modulo>

## Descripción
<texto original normalizado>

## Reproducción
NO DEFINIDO

## Resultado actual
NO DEFINIDO

## Resultado esperado
NO DEFINIDO

## Causa raíz
NO ANALIZADO

## Fix aplicado
N/A

## Test asociado
N/A

## Impacto financiero
NO EVALUADO

## Spec relacionado
N/A

## Historial
- creado automáticamente desde SmartFi_<modulo>.md
```

---

## Template FEATURE

```markdown
# FEAT-XXX

## Estado
OPEN | IN_PROGRESS | DONE

## Módulo
<modulo>

## Descripción
<texto original normalizado>

## Motivación
Derivado de documento SmartFi

## Especificación
N/A

## Impacto
NO EVALUADO

## Dependencias
N/A

## Bugs relacionados
N/A

## Tests
N/A

## Historial
- creado automáticamente desde SmartFi_<modulo>.md
```

---

## Reglas de limpieza

1. Eliminar:

   * bullets redundantes
   * texto duplicado
   * prefijos tipo "BUG:", "MEJORA:"

2. Mantener:

   * contenido semántico original

3. Normalizar:

   * texto en una sola línea descriptiva

---

## Reglas de deduplicación

Antes de crear:

* buscar coincidencias semánticas en `/bugs` o `/features`
* si existe similar:

  * no duplicar
  * agregar referencia en historial

---

## Actualización de índices

### /bugs/README.md

```markdown
# BUG INDEX

| ID      | Módulo      | Estado  | Prioridad |
|--------|------------|--------|----------|
| BUG-001| credit_card| OPEN   | MEDIUM   |
```

---

### /features/README.md

```markdown
# FEATURE INDEX

| ID       | Módulo      | Estado |
|---------|------------|--------|
| FEAT-001| projection | OPEN   |
```

---

## Reglas de commit

Agrupar cambios:

```bash
git add /bugs /features
git commit -m "chore: migrate SmartFi_<modulo> to structured bugs/features"
```

---

## Casos especiales

### 1. Ítems ambiguos

Si no es claro si es bug o feature:

```text
clasificar como BUG
```

---

### 2. Ítems muy grandes

Dividir en múltiples entradas.

---

### 3. Ítems con múltiples problemas

Separar:

```text
1 problema = 1 archivo
```

---

## Ejemplo de transformación

### Input

```text
Bugs:
- Error en cálculo de cuotas
- Proyección incorrecta RESUELTO

Mejoras:
- Agregar límite de tarjeta
```

---

### Output

```text
/bugs/BUG-001-error-calculo-cuotas.md
/bugs/BUG-002-proyeccion-incorrecta.md
/features/FEAT-001-agregar-limite-tarjeta.md
```

---

## Criterio de calidad

* 1 archivo = 1 problema / mejora
* texto claro y atómico
* estado consistente
* módulo correcto
* trazabilidad mantenida

---

## Resultado esperado

* repositorio estructurado
* bugs y features versionados
* tracking consistente con Gitea
* base sólida para análisis posterior
