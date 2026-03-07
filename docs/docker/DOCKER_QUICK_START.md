# 🚀 Quick Start - Docker

## Inicio Rápido en 30 segundos

### 1️⃣ Usar el Script Interactivo (Más Fácil)

```powershell
.\docker-start.ps1
```

Selecciona opción `1` para construir y levantar todo.

### 2️⃣ Comando Directo

```powershell
docker-compose up --build
```

## ⏱️ Primera Vez

- Tiempo de construcción: ~3-5 minutos
- Descargas: Node, Python, PostgreSQL, Nginx images
- Build del frontend React
- Instalación de dependencias Python

## ⚡ Siguientes Veces

```powershell
docker-compose up
```

Solo tarda ~30 segundos en levantar.

## 🌐 Acceder

- **App**: http://localhost:3000
- **API**: http://localhost:8000/docs
- **Login**: admin / admin123

## 🛑 Detener

```powershell
# Detener (mantiene datos)
docker-compose stop

# Detener y eliminar (borra todo)
docker-compose down -v
```

## 📋 Ver Logs

```powershell
# Todos
docker-compose logs -f

# Solo uno
docker-compose logs -f backend
```

## 🔧 Troubleshooting

### Puerto ocupado
```powershell
# Ver qué usa el puerto
netstat -ano | findstr :3000

# Cambiar puerto en docker-compose.yml
# "3001:80" en vez de "3000:80"
```

### No levanta
```powershell
# Limpiar y reiniciar
docker-compose down -v
docker-compose up --build
```

### Cambios no se reflejan
```powershell
# Reconstruir sin cache
docker-compose build --no-cache
docker-compose up
```

---

**📖 Documentación completa**: [DOCKER_LOCAL.md](DOCKER_LOCAL.md)
