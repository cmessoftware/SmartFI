## 1. Base de datos — Campo detail

- [ ] 1.1 Agregar `detail = Column(String(500), nullable=True)` al modelo `CreditCardPurchase` en `backend/database/database.py`.
- [ ] 1.2 Crear migración Alembic: `alembic revision --autogenerate -m "add_detail_to_credit_card_purchases"`.
- [ ] 1.3 Aplicar migración: `alembic upgrade head`.

## 2. Backend — Exponer campo detail

- [ ] 2.1 Agregar `detail` a los schemas Pydantic de compra (request y response) en `main.py`.
- [ ] 2.2 En `create_purchase()` y `update_purchase()` de `credit_card_service.py`, incluir el campo `detail`.

## 3. Frontend — Paginación a 5 ítems

- [ ] 3.1 En el componente de tabla de compras, cambiar el page size default de 10 a 5.
- [ ] 3.2 En el componente de cronograma de cuotas, cambiar el page size default a 5.

## 4. Frontend — Ordenamiento por monto

- [ ] 4.1 Agregar click handler al encabezado "Monto" para alternar orden asc/desc.
- [ ] 4.2 Implementar lógica de ordenamiento local (client-side) de las compras por monto.
- [ ] 4.3 Mostrar indicador visual (flechita) del estado de ordenamiento en el encabezado.

## 5. Frontend — Agrupación visual cuotas vs. único

- [ ] 5.1 Agregar badge o indicador en cada fila de la tabla según el tipo de compra (cuotas / único).
- [ ] 5.2 Definir estilo visual diferenciado (colores o iconos) para cada tipo.

## 6. Frontend — Tooltip de detalle

- [ ] 6.1 Implementar tooltip en cada fila de la tabla usando el mecanismo disponible en el proyecto.
- [ ] 6.2 El tooltip debe mostrar: descripción, fecha, monto, moneda, y cuotas si aplica.
- [ ] 6.3 Si el campo `detail` tiene valor, incluirlo en el tooltip.

## 7. Frontend — Ocultar combo tipo de plan

- [ ] 7.1 Identificar condiciones en que el combo tipo de plan no debe mostrarse.
- [ ] 7.2 Agregar lógica condicional para ocultar/deshabilitar el combo cuando no aplica.

## 8. Frontend — Campo detalle en formulario

- [ ] 8.1 Agregar campo de texto `Detalle` (máx. 500 chars) al formulario de creación/edición de compra.
- [ ] 8.2 Incluir el campo en el payload del POST/PUT.
- [ ] 8.3 Mostrar el campo `detail` en la tabla si tiene valor (columna o parte del tooltip).

## 9. Validación

- [ ] 9.1 Verificar: tabla con 6+ compras pagina correctamente de a 5.
- [ ] 9.2 Verificar: cronograma con 6+ cuotas pagina de a 5.
- [ ] 9.3 Verificar: click en "Monto" ordena asc, segundo click ordena desc.
- [ ] 9.4 Verificar: compras en cuotas y únicas tienen indicadores visuales distintos.
- [ ] 9.5 Verificar: hover sobre compra muestra tooltip con datos correctos.
- [ ] 9.6 Verificar: campo `detail` se guarda y muestra correctamente.
- [ ] 9.7 Verificar: compra sin `detail` se guarda sin error.
