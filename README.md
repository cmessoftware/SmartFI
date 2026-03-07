# Finly - Gestión de Finanzas Personales

Aplicación web SPA para gestión de finanzas personales construida con React + Vite y FastAPI.

## 🏗️ Arquitectura

### Modelo de 3 capas:

- **Frontend**: React + Vite + Tailwind CSS
- **Backend**: FastAPI
- **Datos**: 
  - Sprint 1 y 2: Google Sheets
  - Sprint 3: PostgreSQL

## 📋 Requisitos

### Frontend

- Node.js 18+
- npm o yarn

### Backend

- Python 3.9+
- pip

### Base de Datos

- PostgreSQL (Docker container): `postgresql://admin:admin123@localhost:5432/fin_per_db`

## 🚀 Instalación

### Opción 1: Docker (Recomendado) 🐳

La forma más rápida y sencilla:

```powershell
# Levantar toda la aplicación (frontend + backend + PostgreSQL)
docker-compose up --build
```

Accede a:
- **Aplicación**: http://localhost:3000
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs

Ver guía completa: **[DOCKER_LOCAL.md](DOCKER_LOCAL.md)**

### Opción 2: Instalación Manual

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

## 🔑 Usuarios por Defecto

- **Admin**: admin / admin123
- **Writer**: writer / writer123
- **Reader**: reader / reader123

## 📦 Sprints

### Sprint 1 - ✅ Completado

- ✅ Arquitectura básica
- ✅ Login con JWT
- ✅ Formulario de carga de gastos/ingresos
- ✅ Integración con Google Sheets
- ✅ Reportes con gráficos
- ✅ Administración de categorías y usuarios

### Sprint 2 - ✅ Completado

- ✅ Carga masiva desde CSV
- ✅ Mapeo de columnas
- ✅ Descarga de plantilla CSV

### Sprint 3 - 🔄 En Preparación

- 🔄 Integración con PostgreSQL

## 🎨 Paleta de Colores

- **Fondo**: #F8FAFC (Slate 50)
- **Tarjetas**: #FFFFFF
- **Texto Principal**: #1E293B (Slate 800)
- **Botón Primario**: #4F46E5 (Indigo 600)
- **Ingresos**: #22C55E (Emerald 500)
- **Gastos**: #EF4444 (Red 500)
- **Balance**: #3B82F6 (Blue 500)

## 📚 Documentación

### Docker
- **[🐳 Docker Explicado (Para Novatos)](DOCKER_EXPLICADO.md)** ← Empieza aquí si no conoces Docker
- **[🐳 Docker Local - Guía Completa](DOCKER_LOCAL.md)**
- **[⚡ Quick Start Docker](DOCKER_QUICK_START.md)**

### Instalación y Configuración
- [Guía de Instalación Manual](INSTALLATION.md)
- [Estado de Implementación](IMPLEMENTATION_COMPLETE.md)
- [Inicio Rápido](docs/QUICK_START.md)
- [Configuración de Google Sheets](backend/GOOGLE_SHEETS_SETUP.md)
- [Configuración de PostgreSQL](backend/DATABASE_SETUP.md)

### Deployment en Producción
- **[⚡ Quick Deploy - 15 min](QUICK_DEPLOY.md)** ← Empieza aquí
- [☁️ Deploy Docker a la Nube (Comparativa)](DEPLOY_DOCKER_CLOUD.md)
- [🚀 Guía Completa Render](RENDER_DEPLOY.md)
- [✅ Checklist de Deployment](DEPLOY_CHECKLIST.md)

## 🌐 Deployment en Producción

Finly puede ser deployado **100% GRATIS** en Render con:

- ✅ Frontend (React/Vite) - Static Site
- ✅ Backend (FastAPI) - Web Service  
- ✅ Base de Datos (PostgreSQL) - Free Tier
- ✅ HTTPS automático
- ✅ Auto-deploy desde GitHub

**🚀 Inicio Ultra Rápido (15 minutos):**

```powershell
# 1. Sube a GitHub
.\deploy-to-cloud.ps1

# 2. Render.com → New Blueprint → Conectar repo → Apply
# 3. Configurar FRONTEND_URL
# 4. ¡Listo! 🎉
```

**📖 Guías:**
- **[⚡ Quick Deploy (15 min)](QUICK_DEPLOY.md)** ← Empieza aquí
- [☁️ Comparativa de Plataformas Cloud](DEPLOY_DOCKER_CLOUD.md)
- [🚀 Guía Completa Render](RENDER_DEPLOY.md)
- [✅ Checklist de Deployment](DEPLOY_CHECKLIST.md)

Ver guía completa: **[QUICK_DEPLOY.md](QUICK_DEPLOY.md)**

## 🛠️ Tecnologías Utilizadas

### Frontend

- React
- Vite
- Tailwind CSS
- Chart.js
- PapaParse

### Backend

- FastAPI
- Python 3.9+
- JWT (python-jose)
- bcrypt
- Google Sheets API (gspread)

### Base de Datos

- Google Sheets API (Sprint 1 & 2)
- PostgreSQL (Sprint 3)

### DevOps

- Docker
- Docker Compose
- Conda (Python environment)

## 📄 Licencia

Este proyecto es de código abierto.
