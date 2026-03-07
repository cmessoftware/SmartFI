# 🐳 Docker para Principiantes

Guía rápida y simple para entender Docker sin complicaciones.

## ¿Qué es Docker?

Imagina que tu aplicación es una planta 🌱. Docker es como una maceta que contiene:
- La tierra (sistema operativo base)
- Los nutrientes (librerías y dependencias)
- La planta (tu código)

Todo empaquetado junto. Puedes mover esta "maceta" a cualquier computadora y funcionará igual.

### Problema que resuelve

**Sin Docker:**
- "En mi computadora funciona" 🤷‍♂️
- Tienes que instalar Python, Node, PostgreSQL, etc.
- Puede romperse si actualizas algo
- Difícil compartir con otros

**Con Docker:**
- Funciona igual en todas partes ✅
- Todo viene pre-instalado en el contenedor
- Aislado de tu sistema
- Fácil de compartir y desplegar

## 📦 Conceptos Básicos

### Contenedor
Es tu aplicación ejecutándose en un ambiente aislado.
- Como una mini computadora dentro de tu computadora
- Tiene su propio sistema de archivos
- Ejecuta tu código

**Ejemplo en Finly:**
```
┌─────────────────┐
│  Contenedor 1   │ ← Frontend (React + Nginx)
│  Puerto 3000    │
└─────────────────┘

┌─────────────────┐
│  Contenedor 2   │ ← Backend (Python + FastAPI)
│  Puerto 8000    │
└─────────────────┘

┌─────────────────┐
│  Contenedor 3   │ ← Base de datos (PostgreSQL)
│  Puerto 5433    │
└─────────────────┘
```

### Imagen
Es la "receta" o plantilla para crear contenedores.
- Como una foto instantánea
- Define qué incluir
- Se puede compartir

**Analogía:** 
- Imagen = Receta de pastel 📋
- Contenedor = El pastel cocido 🎂

### Dockerfile
Archivo de texto que define cómo crear una imagen.

**Ejemplo simple:**
```dockerfile
# Usa Python como base
FROM python:3.11-slim

# Copia tu código
COPY . /app

# Instala dependencias
RUN pip install -r requirements.txt

# Ejecuta la aplicación
CMD ["python", "app.py"]
```

Es como escribir instrucciones paso a paso:
1. Empieza con Python
2. Copia mis archivos
3. Instala lo que necesito
4. Corre mi app

## 🔨 docker build

**¿Qué hace?**
Construye una imagen a partir de un Dockerfile.

**Comando:**
```powershell
docker build -t nombre-de-mi-app .
```

**Traducción:**
- `docker build` = "Construye una imagen"
- `-t nombre-de-mi-app` = "Ponle este nombre"
- `.` = "Usa el Dockerfile que está aquí"

**Proceso:**
```
Dockerfile → docker build → Imagen → Guardar
```

**Analogía:**
Es como compilar un programa. Tomas el código fuente (Dockerfile) y creas un ejecutable (Imagen).

**Ejemplo en Finly:**
```powershell
# Construir la imagen del backend
docker build -t finly-backend backend/

# Esto lee backend/Dockerfile y crea la imagen
```

## 🎼 docker-compose

**¿Qué hace?**
Maneja múltiples contenedores al mismo tiempo.

**Problema:**
Si tienes 3 contenedores (frontend, backend, database), sin docker-compose harías:
```powershell
docker run postgres...  # Levantar BD
docker run backend...   # Levantar API
docker run frontend...  # Levantar Web
```
¡3 comandos! Y luego tienes que conectarlos.

**Solución:**
Con docker-compose, un solo comando:
```powershell
docker-compose up
```

### docker-compose.yml

Archivo que define todos tus servicios:

```yaml
services:
  # Servicio 1
  postgres:
    image: postgres:15
    ports:
      - "5433:5432"
  
  # Servicio 2
  backend:
    build: ./backend
    ports:
      - "8000:8000"
  
  # Servicio 3
  frontend:
    build: ./frontend
    ports:
      - "3000:80"
```

**Traducción:**
- "Tengo 3 servicios"
- "Levántalos todos juntos"
- "Conéctalos entre sí"
- "Usa estos puertos"

## 🔄 Flujo Completo en Finly

### 1. docker-compose build
```powershell
docker-compose build
```
**Hace:**
- Lee `docker-compose.yml`
- Ve que hay 2 servicios con Dockerfile (backend y frontend)
- Ejecuta `docker build` para cada uno
- Crea las imágenes

**Resultado:** Imágenes listas para usar

### 2. docker-compose up
```powershell
docker-compose up
```
**Hace:**
- Toma las imágenes
- Crea contenedores
- Los inicia todos
- Los conecta en una red
- Muestra los logs

**Resultado:** Aplicación funcionando

### 3. docker-compose up --build
```powershell
docker-compose up --build
```
**Hace:** Paso 1 + Paso 2 en un solo comando
- Construye las imágenes
- Levanta los contenedores

**Cuándo usar:** Cuando cambias código y quieres ver los cambios.

## 📝 Comandos Esenciales

### Ver contenedores ejecutándose
```powershell
docker ps
```
Muestra qué está corriendo ahora.

### Ver todos los contenedores
```powershell
docker ps -a
```
Incluye los detenidos.

### Ver logs
```powershell
# Todos los servicios
docker-compose logs -f

# Solo uno
docker-compose logs -f backend
```

### Detener todo
```powershell
docker-compose stop
```
Pausa los contenedores (mantiene datos).

### Detener y eliminar
```powershell
docker-compose down
```
Elimina contenedores (mantiene imágenes y volúmenes).

### Eliminar TODO
```powershell
docker-compose down -v
```
Elimina contenedores, redes Y datos (volúmenes).
⚠️ ¡Cuidado! Pierdes datos de la BD.

### Reiniciar un servicio
```powershell
docker-compose restart backend
```

### Reconstruir sin caché
```powershell
docker-compose build --no-cache
```
Útil cuando algo no se actualiza.

## 🎯 Ejemplo Práctico: Finly

### Primera vez (setup inicial)
```powershell
# Construir y levantar
docker-compose up --build

# Esperar 2-3 minutos
# Abrir http://localhost:3000
```

### Hiciste cambios en el código
```powershell
# Reconstruir y reiniciar
docker-compose up --build

# O si solo cambió backend:
docker-compose up --build backend
```

### Ver qué está pasando
```powershell
# Ver logs en tiempo real
docker-compose logs -f

# Ver estado
docker ps
```

### Terminar el día
```powershell
# Detener (mantiene datos)
docker-compose stop

# Próximo día: reiniciar
docker-compose start
```

### Empezar de cero
```powershell
# Limpiar todo
docker-compose down -v

# Volver a construir
docker-compose up --build
```

## 💡 Ventajas de Docker

### 1. Reproducible
```
Tu PC → Produce misma app → PC de tu amigo
```

### 2. Aislamiento
- No contamina tu sistema
- Puedes tener Python 2 y Python 3 en contenedores diferentes
- Eliminar es fácil: borra el contenedor

### 3. Portabilidad
- Desarrollo local → Funciona igual en producción
- Windows → Linux → Mac (mismo código)

### 4. Eficiencia
```powershell
# Sin Docker:
npm install          # 5 min
pip install          # 3 min
configure postgres   # 10 min
Total: 18 min

# Con Docker:
docker-compose up --build  # 3 min (primera vez)
docker-compose up          # 30 seg (siguiente vez)
```

## 🤔 Preguntas Frecuentes

### ¿Docker es una máquina virtual?
No, es más ligero:
- VM = Computadora completa dentro de tu computadora (pesado)
- Docker = Proceso aislado (ligero)

### ¿Necesito saber Linux?
No para empezar. Docker funciona en Windows, Mac y Linux.

### ¿Es gratis?
Sí, Docker Desktop es gratis para uso personal.

### ¿Consume muchos recursos?
Menos que máquinas virtuales, pero algo sí:
- 2-4 GB RAM recomendado
- Espacio en disco para imágenes

### ¿Qué pasa con mis datos?
- **Volúmenes**: Datos persistentes (bases de datos)
- Se mantienen aunque elimines el contenedor
- Solo se borran con `docker-compose down -v`

## 🎓 Resumen Ultra-Rápido

| Comando | ¿Qué hace? | ¿Cuándo usar? |
|---------|-----------|---------------|
| `docker build` | Crea imagen | Solo con Dockerfile manual |
| `docker run` | Ejecuta contenedor | Contenedores simples |
| `docker ps` | Ver contenedores | Ver qué corre |
| `docker-compose build` | Crea todas las imágenes | Después de cambiar Dockerfile |
| `docker-compose up` | Levanta todo | Iniciar aplicación |
| `docker-compose up --build` | Construye + levanta | Después de cambiar código |
| `docker-compose down` | Detiene + elimina | Terminar y limpiar |
| `docker-compose logs -f` | Ver logs | Debuggear problemas |

## 🚀 Siguientes Pasos

1. ✅ Entiendes qué es Docker
2. ✅ Sabes usar docker-compose
3. 📖 Lee `docker-compose.yml` de Finly (ahora tiene más sentido)
4. 🧪 Experimenta: cambia código, reconstruye, observa
5. 🔍 Explora otros proyectos en Docker Hub

---

**Recursos útiles:**
- [Docker Docs Oficiales](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- Nuestro: [DOCKER_LOCAL.md](DOCKER_LOCAL.md) - Guía específica de Finly

**Pro tip:** No memorices comandos, usa el script `docker-start.ps1` que tiene todo en un menú interactivo.
