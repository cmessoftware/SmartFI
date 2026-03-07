# 🐳 Deployment Local con Docker

Guía completa para ejecutar **Finly** con Docker en tu máquina local.

## 📋 Requisitos Previos

- Docker Desktop instalado ([Descargar](https://www.docker.com/products/docker-desktop))
- Docker Compose incluido con Docker Desktop
- Al menos 4GB de RAM disponible
- Puertos disponibles: 3000 (frontend), 8000 (backend), 5432 (PostgreSQL)

## 🚀 Inicio Rápido

### Opción 1: Comando Único (Recomendado)

```powershell
# Construir y levantar todos los servicios
docker-compose up --build
```

### Opción 2: Paso a Paso

```powershell
# 1. Construir las imágenes
docker-compose build

# 2. Levantar los servicios
docker-compose up

# 3. Para ejecutar en background (detached)
docker-compose up -d
```

## 🌐 Acceder a la Aplicación

Después de unos segundos (primera vez puede tardar 2-3 minutos):

- **Aplicación Web**: http://localhost:3000
- **API Backend**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/api/health
- **PostgreSQL**: localhost:5432

### Usuarios de Prueba

- **Admin**: `admin` / `admin123`
- **Writer**: `writer` / `writer123`
- **Reader**: `reader` / `reader123`

## 🔧 Configuración Avanzada

### Variables de Entorno

1. Copia el archivo de ejemplo:
```powershell
Copy-Item .env.docker .env
```

2. Edita `.env` con tus valores:
```env
SECRET_KEY=tu-clave-secreta-super-segura-aqui
GOOGLE_SHEET_ID=tu-google-sheet-id-opcional
```

### Google Sheets (Opcional)

Si quieres usar Google Sheets:

1. Coloca tu archivo `credentials.json` en `backend/credentials.json`
2. Configura `GOOGLE_SHEET_ID` en el archivo `.env`
3. Reinicia los contenedores

## 📊 Comandos Útiles

### Ver logs en tiempo real
```powershell
# Todos los servicios
docker-compose logs -f

# Solo backend
docker-compose logs -f backend

# Solo frontend
docker-compose logs -f frontend

# Solo database
docker-compose logs -f postgres
```

### Detener servicios
```powershell
# Detener (mantiene volúmenes)
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Detener y eliminar TODO (incluyendo volúmenes/datos)
docker-compose down -v
```

### Reiniciar servicios
```powershell
# Reiniciar todos
docker-compose restart

# Reiniciar solo uno
docker-compose restart backend
```

### Ver estado de los contenedores
```powershell
docker-compose ps
```

### Acceder a un contenedor
```powershell
# Backend
docker exec -it finly-backend bash

# Frontend (Alpine Linux - usa sh)
docker exec -it finly-frontend sh

# PostgreSQL
docker exec -it finly-postgres psql -U admin -d fin_per_db
```

### Verificar salud de los servicios
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## 🔄 Reconstruir después de Cambios

### Cambios en el código

```powershell
# Backend
docker-compose up --build backend

# Frontend
docker-compose up --build frontend

# Todo
docker-compose up --build
```

### Limpiar y empezar de cero

```powershell
# Detener todo
docker-compose down -v

# Eliminar imágenes viejas
docker-compose build --no-cache

# Levantar de nuevo
docker-compose up
```

## 🗄️ Gestión de Base de Datos

### Conectar desde herramientas externas

Puedes conectarte a PostgreSQL desde herramientas como pgAdmin, DBeaver, etc:

- **Host**: localhost
- **Port**: 5432
- **Database**: fin_per_db
- **User**: admin
- **Password**: admin123

### Backup de la base de datos

```powershell
# Crear backup
docker exec finly-postgres pg_dump -U admin fin_per_db > backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# Restaurar backup
Get-Content backup_20260307_120000.sql | docker exec -i finly-postgres psql -U admin -d fin_per_db
```

### Ver datos en la base

```powershell
docker exec -it finly-postgres psql -U admin -d fin_per_db -c "SELECT * FROM transactions LIMIT 10;"
```

## 🐛 Troubleshooting

### Puerto ya en uso

Si algún puerto está ocupado:

```powershell
# Ver qué proceso usa el puerto
netstat -ano | findstr :3000
netstat -ano | findstr :8000
netstat -ano | findstr :5432

# Cambiar puerto en docker-compose.yml
# Por ejemplo, cambiar "3000:80" a "3001:80"
```

### Backend no conecta a la base de datos

```powershell
# Verificar que postgres esté healthy
docker-compose ps

# Ver logs del postgres
docker-compose logs postgres

# Reintentar
docker-compose restart backend
```

### Frontend muestra página en blanco

```powershell
# Ver logs del frontend
docker-compose logs frontend

# Verificar que nginx esté funcionando
docker exec finly-frontend ps aux | grep nginx

# Reconstruir frontend
docker-compose up --build frontend
```

### Error de CORS

Verifica que en `docker-compose.yml`:
- `FRONTEND_URL` en backend apunte a `http://localhost:3000`
- El nginx.conf tiene el proxy configurado

### Limpiar espacio en disco

```powershell
# Ver uso de disco
docker system df

# Limpiar contenedores detenidos, imágenes no usadas, etc.
docker system prune

# Limpieza completa (¡cuidado!)
docker system prune -a --volumes
```

## 📈 Monitoreo de Recursos

### Ver uso de recursos
```powershell
docker stats
```

### Limitar recursos (opcional)

Edita `docker-compose.yml` y agrega:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## 🔒 Seguridad

### Producción Local

Si quieres usar esto en una red local:

1. **Cambia las credenciales por defecto**:
   - SECRET_KEY en `.env`
   - POSTGRES_PASSWORD en `docker-compose.yml`

2. **Configura HTTPS** con nginx y certificados

3. **Restringe puertos** solo a los necesarios

## 🚢 Migración a Producción

Una vez probado localmente:

1. Las mismas imágenes Docker pueden usarse en producción
2. Ajusta variables de entorno para producción
3. Usa servicios administrados para la base de datos
4. Configura dominio y HTTPS
5. Revisa [RENDER_DEPLOY.md](RENDER_DEPLOY.md) para deployment en la nube

## 📦 Estructura de Contenedores

```
┌─────────────────────────────────────────┐
│  Frontend (Nginx + React)               │
│  http://localhost:3000                  │
│  Container: finly-frontend              │
└──────────────┬──────────────────────────┘
               │
               │ Proxy /api
               │
┌──────────────▼──────────────────────────┐
│  Backend (FastAPI)                      │
│  http://localhost:8000                  │
│  Container: finly-backend               │
└──────────────┬──────────────────────────┘
               │
               │ SQL Queries
               │
┌──────────────▼──────────────────────────┐
│  PostgreSQL Database                    │
│  localhost:5432                         │
│  Container: finly-postgres              │
└─────────────────────────────────────────┘
```

## ✅ Checklist de Verificación

- [ ] Docker Desktop instalado y funcionando
- [ ] Puertos 3000, 8000, 5432 disponibles
- [ ] Ejecutar `docker-compose up --build`
- [ ] Esperar ~2-3 minutos en primer inicio
- [ ] Abrir http://localhost:3000
- [ ] Login con admin/admin123
- [ ] Crear una transacción de prueba
- [ ] Ver el reporte
- [ ] Verificar que persiste (reiniciar y revisar)

## 🎯 Próximos Pasos

1. ✅ Probar localmente con Docker
2. Hacer cambios y validar
3. Preparar para producción
4. Deploy en Render (ver [RENDER_DEPLOY.md](RENDER_DEPLOY.md))

---

**Tiempo de setup**: ~5 minutos (primera vez puede tardar más por descargas)
**Costo**: $0 (todo local)
