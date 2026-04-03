# Guía de Testing Manual - Módulo de Tarjetas de Crédito

## 🚀 Acceso a la Aplicación

**URL:** http://localhost:5173

**Credenciales:** Usa las credenciales de tu usuario existente en la base de datos

---

## 📋 Checklist de Pruebas

### 1️⃣ Acceso al Módulo

- [ ] Iniciar sesión en la aplicación
- [ ] Verificar que aparece el menú "💳 Tarjetas de Crédito" en el sidebar
- [ ] Hacer clic en "Tarjetas de Crédito"
- [ ] Verificar que se carga la vista principal (vacía o con tarjetas existentes)

---

### 2️⃣ Crear Nueva Tarjeta de Crédito

**Flujo:**
1. Clic en botón "➕ Nueva Tarjeta"
2. Completar formulario con datos de prueba

**Datos de Prueba Sugeridos:**

```
Banco: Banco Santander
Últimos 4 dígitos: 1234
Límite de crédito: 50000.00
Fecha de corte: 15 (día del mes)
Fecha de vencimiento: 25 (día del mes)
Tasa de interés anual: 45.0 (%)
```

**Verificaciones:**
- [ ] El modal se abre correctamente
- [ ] Validación: No permite días menores a 1 o mayores a 31
- [ ] Validación: No permite límites negativos
- [ ] Validación: Tasa de interés no puede ser negativa
- [ ] Al guardar, aparece toast de éxito
- [ ] La nueva tarjeta aparece en la grilla
- [ ] La tarjeta muestra fondo degradado indigo
- [ ] Muestra saldo disponible = límite de crédito (si no hay compras)

---

### 3️⃣ Ver Resumen de Tarjeta

**Flujo:**
1. Hacer clic en cualquier tarjeta de la grilla

**Verificaciones:**
- [ ] Se expande y muestra información adicional:
  - Deuda actual
  - Crédito disponible
  - Cuotas pendientes
  - Barra de progreso de utilización
- [ ] Los colores de la barra cambian según el % de utilización:
  - Verde: < 50%
  - Amarillo: 50-80%
  - Rojo: > 80%
- [ ] Al hacer clic nuevamente, se contrae

---

### 4️⃣ Editar Tarjeta

**Flujo:**
1. Clic en botón "✏️ Editar" de una tarjeta

**Verificaciones:**
- [ ] El modal se abre con datos precargados
- [ ] Puedes modificar el límite de crédito (ej: 60000)
- [ ] Puedes cambiar la tasa de interés (ej: 40.0)
- [ ] No puedes modificar los últimos 4 dígitos (campo deshabilitado)
- [ ] Al guardar, se actualiza la tarjeta en la grilla
- [ ] Aparece toast de éxito

---

### 5️⃣ Registrar Compra con Cuotas

**Flujo:**
1. Clic en botón "🛒 Compra" de una tarjeta

**Datos de Prueba - Caso 1 (3 cuotas):**

```
Descripción: Smart TV 55"
Monto: 15000.00
Cuotas: 3
Tasa de interés: 0 (sin interés)
Fecha de compra: [fecha actual]
```

**Datos de Prueba - Caso 2 (12 cuotas con interés):**

```
Descripción: Notebook Lenovo
Monto: 30000.00
Cuotas: 12
Tasa de interés: 45 (CFT anual)
Fecha de compra: [fecha actual]
```

**Verificaciones:**
- [ ] El modal muestra calculadora en tiempo real
- [ ] Para el Caso 1 (sin interés):
  - Cuota mensual: $5,000.00
  - Total a pagar: $15,000.00
  - Intereses: $0.00
- [ ] Para el Caso 2 (con interés 45% anual):
  - Cuota mensual: ~$2,929.42
  - Total a pagar: ~$35,153.04
  - Intereses totales: ~$5,153.04
- [ ] Al guardar, aparece toast de éxito
- [ ] La deuda actual de la tarjeta aumenta
- [ ] El crédito disponible disminuye

---

### 6️⃣ Ver Cronograma de Cuotas

**Flujo:**
1. Clic en botón "📅 Cronograma" de una tarjeta
2. Seleccionar un plan de cuotas de la lista

**Verificaciones:**
- [ ] El modal muestra lista de planes activos
- [ ] Al seleccionar un plan, se muestra tabla con todas las cuotas:
  - Número de cuota
  - Fecha de vencimiento
  - Capital
  - Interés
  - Total
  - Estado (PENDING/PAID/OVERDUE)
  - Botón "Pagar" (solo para cuotas pendientes)
- [ ] Barra de progreso muestra cuotas pagadas/total
- [ ] Badges de estado tienen colores correctos:
  - PENDING: amarillo
  - PAID: verde
  - OVERDUE: rojo

---

### 7️⃣ Pagar Cuota

**Flujo:**
1. En el cronograma, clic en "💰 Pagar" de una cuota pendiente
2. Confirmar pago

**Verificaciones:**
- [ ] Aparece confirmación antes de pagar
- [ ] Al confirmar, la cuota cambia a estado PAID (verde)
- [ ] El botón "Pagar" desaparece
- [ ] La barra de progreso se actualiza
- [ ] Al cerrar el modal y volver a la vista principal:
  - La deuda actual de la tarjeta disminuye
  - El crédito disponible aumenta
  - Las cuotas pendientes disminuyen en 1

---

### 8️⃣ Verificar Integración con Módulo de Deudas

**Flujo:**
1. Ir al módulo "Deudas" en el sidebar
2. Buscar las deudas creadas por las compras con tarjeta

**Verificaciones:**
- [ ] Cada compra con tarjeta genera 1 deuda
- [ ] El acreedor es el nombre del banco
- [ ] El monto coincide con el total a pagar (capital + intereses)
- [ ] El tipo de deuda es "Tarjeta de Crédito"
- [ ] El estado puede ser:
  - "Pendiente": si no se ha pagado ninguna cuota
  - "Pago Parcial": si se pagaron algunas cuotas
  - "Cancelada": si se pagaron todas las cuotas
- [ ] Al pagar una cuota, el monto ejecutado de la deuda aumenta automáticamente

---

### 9️⃣ Casos Extremos y Validaciones

**Probar:**

- [ ] **Límite de crédito excedido:**
  - Intentar compra por monto > crédito disponible
  - Debería mostrar error (si está implementado) o crear deuda que exceda límite
  
- [ ] **Compra sin cuotas (1 cuota):**
  - Crear compra con installments = 1
  - Verificar que se crea correctamente
  
- [ ] **Múltiples compras en una tarjeta:**
  - Registrar 3 compras diferentes
  - Verificar que el cronograma muestra todos los planes
  - Verificar que la deuda total es la suma de todas las compras
  
- [ ] **Pagar cuotas fuera de orden:**
  - En un plan de 12 cuotas, pagar primero la #3, luego la #1
  - Verificar que permite el pago
  - Verificar que los cálculos sean correctos

- [ ] **Eliminar tarjeta:**
  - Clic en "🗑️ Eliminar" en una tarjeta sin compras
  - Confirmar eliminación
  - Verificar que desaparece de la grilla
  - Intentar eliminar tarjeta con compras activas (debería fallar o pedir confirmación)

---

### 🔟 Filtros y Búsqueda

**Probar:**

- [ ] El toggle "Solo activas" filtra correctamente:
  - Mostrar solo tarjetas con `is_active = true`
  - Al desactivar, mostrar todas las tarjetas
  
- [ ] Si hay muchas tarjetas, la grilla es responsive:
  - 1 columna en móvil
  - 2 columnas en tablet
  - 3 columnas en desktop

---

## ✅ Flujo Completo de Prueba (Caso de Uso Real)

### Escenario: Comprar electrodoméstico y pagar cuotas

1. **Crear tarjeta:**
   - Banco: Banco BBVA
   - Últimos 4: 5678
   - Límite: $80,000
   - Corte: 5, Vencimiento: 15
   - Tasa anual: 50%

2. **Registrar compra:**
   - Electrodoméstico: $24,000
   - 6 cuotas sin interés
   - Fecha: hoy

3. **Verificar:**
   - Deuda actual: $24,000
   - Crédito disponible: $56,000
   - Cuotas pendientes: 6

4. **Ver cronograma:**
   - 6 cuotas de $4,000 cada una
   - Fechas de vencimiento mensuales

5. **Pagar 2 cuotas:**
   - Pagar cuota #1
   - Pagar cuota #2

6. **Verificar después de pagos:**
   - Deuda actual: $16,000
   - Crédito disponible: $64,000
   - Cuotas pendientes: 4
   - En módulo Deudas: monto ejecutado = $8,000

---

## 🐛 Reporte de Bugs

Si encuentras errores durante el testing, anota:

- **URL:** Página donde ocurrió
- **Acción:** Qué estabas haciendo
- **Esperado:** Qué debería pasar
- **Actual:** Qué pasó realmente
- **Console:** Revisar consola del navegador (F12) para errores JS
- **Network:** Revisar tab Network para errores de API (códigos 4xx, 5xx)

---

## 📊 Datos Adicionales para Testing

### Más Tarjetas de Prueba:

```
Tarjeta 2:
- Banco: Banco Galicia
- Últimos 4: 9012
- Límite: 100000
- Corte: 10, Vencimiento: 20
- Tasa: 38.5%

Tarjeta 3:
- Banco: Banco Nación
- Últimos 4: 3456
- Límite: 30000
- Corte: 28, Vencimiento: 8
- Tasa: 42.0%
```

### Compras de Prueba Variadas:

```
Compra 1: Supermercado - $15,000 en 1 cuota (sin interés)
Compra 2: Ropa - $8,500 en 3 cuotas (sin interés)
Compra 3: Celular - $45,000 en 18 cuotas (45% anual)
Compra 4: Viaje - $60,000 en 24 cuotas (50% anual)
```

---

## 🎯 Checklist Final

Antes de dar por terminado el testing:

- [ ] Todas las funciones CRUD funcionan (Create, Read, Update, Delete)
- [ ] Los cálculos de amortización son correctos
- [ ] La integración con el módulo Deudas funciona
- [ ] Los estados de las cuotas se actualizan correctamente
- [ ] Las validaciones de formularios funcionan
- [ ] Los toasts de éxito/error aparecen apropiadamente
- [ ] No hay errores en consola del navegador
- [ ] No hay errores en la terminal del backend
- [ ] La UI es responsive en diferentes tamaños de pantalla
- [ ] Los colores y estilos son consistentes con el resto de la app

---

**¡Listo para empezar el testing!** 🚀

Abre http://localhost:5173 en tu navegador y sigue esta guía paso a paso.
