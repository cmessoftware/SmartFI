# 💰 SmartFI - Gestión de Finanzas Personales

> Aplicación web full-stack para gestionar tus finanzas personales de forma simple y eficiente

[![Deploy](https://img.shields.io/badge/Deploy-Render-46E3B7?style=flat-square)](https://render.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

**Finly** es una aplicación moderna de finanzas personales que te permite:
- 📊 Registrar ingresos y gastos con categorización
- 📈 Visualizar reportes con gráficos interactivos
- 💳 Gestionar presupuestos y compromisos financieros
- 📁 Importar/exportar transacciones desde CSV
- ☁️ Sincronización con Google Sheets (opcional)
- 🔒 Sistema de autenticación con roles (Admin, Writer, Reader)
- 🐳 Deploy con Docker en minutos

---

## 📚 Documentación

### 🎯 Guías Esenciales

| Documento | Descripción |
|-----------|-------------|
| **[SISTEMA_ACTUAL.md](docs/SISTEMA_ACTUAL.md)** | 📄 Documentación completa del sistema implementado |
| **[QUICK_START.md](docs/QUICK_START.md)** | ⚡ Inicio rápido para desarrollo |
| **[INSTALLATION.md](docs/INSTALLATION.md)** | 💻 Guía de instalación detallada |
| **[CREDIT_CARD_API.md](docs/CREDIT_CARD_API.md)** | 💳 API de gestión de tarjetas de crédito y cuotas |

### 🚀 Deployment

| Documento | Descripción |
|-----------|-------------|
| **[DOCKER_QUICK_START.md](docs/docker/DOCKER_QUICK_START.md)** | 🐳 Deploy local con Docker |
| **[RENDER_DEPLOY.md](docs/deployment/RENDER_DEPLOY.md)** | ☁️ Deploy en producción (Render) |
| **[DEPLOY_CHECKLIST.md](docs/deployment/DEPLOY_CHECKLIST.md)** | ✅ Checklist pre-deploy |

### 📋 Roadmap & Planificación

| Documento | Descripción |
|-----------|-------------|
| **[FINLY_FUNCTIONAL_SPECIFICATION.md](docs/FINLY_FUNCTIONAL_SPECIFICATION.md)** | 📋 Funcionalidades planificadas (Sprints 4+) |
| **[ROADMAP_FINLY_V1.md](docs/ROADMAP_FINLY_V1.md)** | 🗺️ Hoja de ruta del proyecto |

---

## ✨ Features Implementadas

### 🎯 Para Usuarios
- ✅ **Dashboard intuitivo** - Vista general de tus finanzas
- ✅ **Balance Pendiente** - Proyección financiera si se pagan todos los presupuestos
- ✅ **Registro de transacciones** - Ingresa gastos/ingresos fácilmente
- ✅ **Gestión de presupuesto** - Rastrea compromisos (préstamos, tarjetas, servicios)
- ✅ **Gestión de tarjetas de crédito** - Administra tarjetas, compras a cuotas e intereses
- ✅ **Categorías y formas de pago** - Organiza tus transacciones
- ✅ **Reportes visuales** - Gráficos de torta y barras
- ✅ **Filtros avanzados** - Por fecha, categoría, tipo
- ✅ **Importación CSV** - Carga masiva de transacciones
- ✅ **Sincronización Google Sheets** - Backup automático

### 🔐 Para Administradores
- ✅ **Gestión de usuarios** - Crear, editar, eliminar usuarios
- ✅ **Control de roles** - Admin, Writer, Reader
- ✅ **Panel de sincronización** - PostgreSQL ↔ Google Sheets
- ✅ **Auditoría** - Registro de todas las operaciones

### 🚀 Técnicas
- ✅ **API REST completa** - Documentación automática con Swagger
- ✅ **Autenticación JWT** - Segura y escalable
- ✅ **Dockerizado** - Deploy consistente en cualquier plataforma
- ✅ **PostgreSQL** - Base de datos principal robusta
- ✅ **Alembic Migrations** - Control de versiones de esquema de base de datos
- ✅ **Google Sheets** - Respaldo y sincronización opcional
- ✅ **Responsive design** - Funciona en móvil, tablet y desktop
- ✅ **Gestión de tarjetas de crédito** - Módulo completo con cálculo de intereses y cuotas

---

## 🚀 Quick Start

### Opción 1: Docker (Recomendado)

```bash
# 1. Clonar repositorio
git clone https://github.com/cmessoftware/finly.git
cd finly

# 2. Configurar variables de entorno
cp backend/.env.example backend/.env

# 3. Levantar servicios
docker-compose up --build

# 4. Abrir en navegador
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# Swagger Docs: http://localhost:8000/docs
```

### Opción 2: Manual

```bash
# Backend
cd backend
python -m venv venv
venv\Scripts\activate     # Windows
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Frontend (nueva terminal)
cd frontend
npm install
npm run dev
```

**Ver guía completa:** [INSTALLATION.md](docs/INSTALLATION.md)

---

## 👥 Usuarios de Prueba

Una vez iniciada la aplicación, puedes acceder con estos usuarios predefinidos:

| Usuario | Contraseña | Rol | Permisos |
|---------|------------|-----|----------|
| `admin` | `admin123` | Admin | ✅ Todos los permisos + sincronización + gestión de usuarios |
| `writer` | `writer123` | Writer | ✏️ Crear, editar, eliminar transacciones y presupuestos |
| `reader` | `reader123` | Reader | 👁️ Solo visualizar dashboards y reportes |

⚠️ **Importante:** Cambiar estas credenciales antes de deploy en producción.

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    Cliente (Browser)                     │
└───────────────────┬─────────────────────────────────────┘
                    │
                    │ HTTPS
                    ▼
┌─────────────────────────────────────────────────────────┐
│              Frontend (React + Vite)                     │
│  - UI Components (Tailwind CSS)                          │
│  - State Management                                      │
│  - Chart.js Visualizations                              │
│  Served by: Nginx (Docker) / Render (Cloud)            │
└───────────────────┬─────────────────────────────────────┘
                    │
                    │ REST API (Axios)
                    ▼
┌─────────────────────────────────────────────────────────┐
│              Backend (FastAPI)                           │
│  - JWT Authentication                                    │
│  - Business Logic                                        │
│  - Data Validation (Pydantic)                           │
│  Runtime: Uvicorn (Docker) / Render (Cloud)            │
└───────────┬──────────────────────────┬──────────────────┘
            │                          │
            │ SQLAlchemy              │ gspread API
            ▼                          ▼
┌─────────────────────┐    ┌──────────────────────────┐
│   PostgreSQL 15     │    │    Google Sheets         │
│  - Transacciones    │    │  - Backup/Sync           │
│  - Usuarios         │    │  - Import/Export         │
│  - Categorías       │    │  (Opcional)              │
└─────────────────────┘    └──────────────────────────┘
```

### 🔄 Flujo de Deployment

```
Desarrollo Local          →    GitHub         →    Producción
┌────────────────┐       ┌────────────┐      ┌──────────────┐
│ docker-compose │  git  │            │ auto │              │
│ up --build     │ push → │ Repository │ ──→  │ Render.com   │
│                │       │            │deploy│ (Blueprint)  │
└────────────────┘       └────────────┘      └──────────────┘
 localhost:3000           cmessoftware/       *.onrender.com
                          finly

## 🚀 Quick Start

### Opción 1: Docker (Recomendado) 🐳

**Requisitos:** Docker Desktop instalado

```powershell
# Clonar repositorio
git clone https://github.com/cmessoftware/finly.git
cd finly

# Levantar con Docker (todo incluido: frontend + backend + PostgreSQL)
docker-compose up --build
```

**¡Listo!** Accede a:
- 🌐 **Aplicación**: http://localhost:3000
- 🔌 **API**: http://localhost:8000/api/health
- 📚 **Docs API**: http://localhost:8000/docs

**Primera vez tarda ~3 minutos** (descarga imágenes). Siguientes veces: ~30 segundos.

👉 **Guía detallada:** [DOCKER_LOCAL.md](docs/docker/DOCKER_LOCAL.md) | **¿Nuevo en Docker?** [DOCKER_EXPLICADO.md](docs/docker/DOCKER_EXPLICADO.md)

---

### Opción 2: Instalación Manual (Sin Docker)

<details>
<summary>Click para ver instrucciones de instalación manual</summary>

**Requisitos:**
- Node.js 18+
- Python 3.9+
- PostgreSQL

**Frontend:**
```bash
cd frontend
npm install
npm run dev
# Abre http://localhost:5173
```

**Backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
# Abre http://localhost:8000
```

**Base de datos:**
```bash
# Levantar PostgreSQL con Docker
docker-compose up postgres
```

</details>

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

### Sprint 3 - ✅ Completado (Actual)

- ✅ Integración con PostgreSQL como base de datos principal
- ✅ Módulo de Presupuesto (seguimiento de compromisos financieros)
- ✅ Sincronización bidireccional PostgreSQL ↔ Google Sheets
- ✅ Formateo consistente de fechas (DD/MM/YYYY)
- ✅ Sistema de forma de pago (Débito/Crédito)
- ✅ Vinculación transacciones ↔ items de presupuesto
- ✅ Panel de administración con estadísticas

### Sprint 4 - 📋 Planificado (Roadmap)

- 📋 Planificación de flujos de caja proyectados
- 📋 Dashboard de forecast balance
- 📋 Clonación mensual de presupuestos
- 📋 Alertas financieras automáticas
- 📋 Análisis de desviación presupuestaria
- 📋 Proyección diaria de balance

**Ver roadmap completo:** [FINLY_FUNCTIONAL_SPECIFICATION.md](docs/FINLY_FUNCTIONAL_SPECIFICATION.md)

---

- **Fondo**: #F8FAFC (Slate 50)
- **Tarjetas**: #FFFFFF
- **Texto Principal**: #1E293B (Slate 800)
- **Botón Primario**: #4F46E5 (Indigo 600)
- *☁️ Deploy a la Nube (GRATIS)

Despliega Finly en **Render** 100% gratis en **15 minutos**:

### 🎯 Tutorial Completo

####🐳 Docker
- **[Docker Explicado (Para Novatos)](docs/docker/DOCKER_EXPLICADO.md)** - ¿Qué es Docker? Conceptos básicos
- **[Docker Local - Guía Completa](docs/docker/DOCKER_LOCAL.md)** - Desarrollo con Docker, comandos, troubleshooting
- **[Quick Start Docker](docs/docker/DOCKER_QUICK_START.md)** - Inicio en 30 segundos
- **[Google Sheets en Docker](docs/docker/GOOGLE_SHEETS_DOCKER.md)** - Configurar Google Sheets en contenedores

### ☁️ Deployment en Producción
- **[Quick Deploy (15 min)](docs/deployment/QUICK_DEPLOY.md)** - Tutorial completo de deployment
- **[Comparativa Cloud](docs/deployment/DEPLOY_DOCKER_CLOUD.md)** - Render vs Railway vs Fly.io
- **[Guía Render](docs/deployment/RENDER_DEPLOY.md)** - Deployment detallado en Render
- **[Checklist](docs/deployment/DEPLOY_CHECKLIST.md)** - Verificación paso a paso

### ⚙️ Configuración
- **[Instalación Manual](docs/INSTALLATION.md)** - Sin Docker
- [Configuración Google Sheets](docs/configuration/GOOGLE_SHEETS_SETUP.md) - API de Google
- [Configuración PostgreSQL](docs/configuration/DATABASE_SETUP.md) - Base de datos
- [Estado del Proyecto](docs/IMPLEMENTATION_COMPLETE.md) - Features implementadas
1. Ve a **https://render.com**
2. Click en **"Get Started"**
3. Elige **"Sign in with GitHub"** (más fácil)
4. Autoriza Render
5. ✅ **No necesitas tarjeta de crédito**

#### 3️⃣ Deploy con Blueprint (1-Click)

1. En Render Dashboard → Click **"New +"** → **"Blueprint"**

2. Conectar repositorio:
   - Busca y selecciona **"finly"**
   - Si no aparece → "Configure account" → Autoriza el repo

3. Render detecta `render.yaml` automáticamente:
   - ✅ finly-api (Backend)
   - ✅ finly-frontend (Frontend)
   - ✅ finly-db (PostgreSQL)

4. Click **"Apply"** y **espera 8-10 minutos** ☕

5. Cuando termine, configurar:
   - En servicio **"finly-api"** → Environment → Add:
   ```
   FRONTEND_URL = https://finly-frontend.onrender.com
   ```
   (Reemplaza con tu URL real de Render)

#### 4️⃣ ¡Listo! 🎉

Tu app Stack Tecnológico

### Frontend
- **React 18** - UI Library
- **Vite** - Build tool ultra rápido
- **Tailwind CSS** - Styling
- **Chart.js** - Gráficos interactivos
- **Axios** - HTTP client
- **PapaParse** - Procesamiento CSV

### Backend
- **FastAPI** - Framework web moderno
- **Python 3.11** - Lenguaje
- **JWT** - Autenticación
- **bcrypt** - Hash de contraseñas
- **SQLAlchemy** - ORM
- **Google Sheets API** - Sincronización (opcional)

### Database
- **PostgreSQL 15** - Base de datos principal
- **Google Sheets** - Almacenamiento alternativo (opcional)

### DevOps & Infrastructure
- **Docker** - Contenedores
- **Docker Compose** - Orquestación
- **Nginx** - Web server (frontend)
- **Render** - Hosting cloud
- **GitHub Actions** - CI/CD

## 📁 Estructura del Proyecto

```
Finly/
├── frontend/                # Aplicación React
│   ├── src/
│   │   ├── components/     # Componentes React
│   │   └── services/       # API client
│   ├── Dockerfile          # Container frontend
│   └── nginx.conf          # Configuración Nginx
│
├── backend/                 # API FastAPI
│   ├── services/           # Lógica de negocio
│   ├── database/           # Modelos y conexión DB
│   ├── main.py             # Entry point API
│   ├── Dockerfile          # Container backend
│   └── requirements.txt    # Dependencias Python
│
├── docs/                    # Documentación
│   ├── docker/             # Guías de Docker
│   ├── deployment/         # Guías de deployment
│   └── *.md                # Documentación general
├── scripts/                 # Scripts de utilidad
│   ├── docker-start.ps1    # Iniciar Docker interactivo
│   ├── deploy-to-cloud.ps1 # Deploy a GitHub helper
│   ├── install.ps1         # Instalación inicial
│   └── start.ps1           # Iniciar desarrollo local
├── docker-compose.yml       # Orquestación multi-container
├── render.yaml              # Config deployment Render
├── .env.docker              # Variables de entorno template
└── *.md                     # Guías y documentación
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si deseas mejorar Finly:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 🗺️ Roadmap

- [x] Sistema de autenticación con roles
- [x] CRUD de transacciones
- [x] Reportes y visualizaciones
- [x] Integración Google Sheets
- [x] Importación CSV
- [x] Containerización con Docker
- [x] Deploy en cloud (Render)
- [ ] Integración PostgreSQL completa
- [ ] Dashboard mejorado con más métricas
- [ ] Presupuestos y metas
- [ ] Notificaciones y alertas
- [ ] Export a PDF/Excel
- [ ] App móvil (React Native)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**CMS Software**
- GitHub: [@cmessoftware](https://github.com/cmessoftware)

## 🙏 Agradecimientos

- Documentación completa de Docker para principiantes
- Guías detalladas de deployment en múltiples plataformas
- Configuración lista para producción
- Scripts de ayuda para desarrollo y deployment

---

⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub

📧 ¿Preguntas? Abre un [Issue](https://github.com/cmessoftware/finly/issues)
git push
```

Render detectará el cambio y redesplegará automáticamente en ~5 minutos.

### 📚 Más opciones de deployment:

- **[⚡ Quick Deploy (15 min)](docs/deployment/QUICK_DEPLOY.md)** - Tutorial paso a paso
- **[☁️ Comparativa Cloud](docs/deployment/DEPLOY_DOCKER_CLOUD.md)** - Render vs Railway vs Fly.io
- **[🚀 Guía Completa Render](docs/deployment/RENDER_DEPLOY.md)** - Troubleshooting y avanzado
- **[✅ Checklist](docs/deployment/DEPLOY_CHECKLIST.md)** - Lista de verificación completa
- ✅ Frontend (React/Vite) - Static Site
- ✅ Backend (FastAPI) - Web Service  
- ✅ Backend + Frontend + Google Sheets
- ✅ HTTPS automático
- ✅ Auto-deploy desde GitHub
- ⚠️ PostgreSQL no requerido (Sprint 3)

**🚀 Inicio Ultra Rápido (15 minutos):**

```powershell
# 1. Sube a GitHub
.\scripts\deploy-to-cloud.ps1

# 2. Render.com → New Blueprint → Conectar repo → Apply
# 3. Configurar FRONTEND_URL
# 4. ¡Listo! 🎉
```

**📖 Guías:**
- **[⚡ Quick Deploy (15 min)](docs/deployment/QUICK_DEPLOY.md)** ← Empieza aquí
- [☁️ Comparativa de Plataformas Cloud](docs/deployment/DEPLOY_DOCKER_CLOUD.md)
- [🚀 Guía Completa Render](docs/deployment/RENDER_DEPLOY.md)
- [✅ Checklist de Deployment](docs/deployment/DEPLOY_CHECKLIST.md)

Ver guía completa: **[QUICK_DEPLOY.md](docs/deployment/QUICK_DEPLOY.md)**

## 🛠️ Tecnologías Utilizadas

### Frontend

- **React** - Biblioteca UI
- **Vite** - Build tool ultrarrápido
- **Tailwind CSS** - Framework CSS utility-first
- **Chart.js** - Gráficos interactivos
- **PapaParse** - Parser CSV
- **Axios** - Cliente HTTP

### Backend

- **FastAPI** - Framework web moderno y rápido
- **Python 3.9+** - Lenguaje de programación
- **JWT (python-jose)** - Autenticación segura
- **bcrypt** - Hashing de contraseñas
- **SQLAlchemy** - ORM para Python
- **Alembic** - Gestión de migraciones de DB
- **Google Sheets API (gspread)** - Sincronización y backup

### Base de Datos

- **PostgreSQL 15** - Base de datos principal ✅ Implementado
- **Alembic** - Control de versiones de schema  
- **Google Sheets API** - Backup y sincronización opcional ✅ Implementado

### DevOps

- **Docker** - Containerización
- **Docker Compose** - Orquestación multi-container
- **Conda** - Gestión de entornos Python
- **Render** - Platform de deployment cloud

---

## 🗃️ Gestión de Base de Datos

Finly utiliza **Alembic** para gestionar todas las migraciones de base de datos de forma segura y versionada.

```bash
# Generar migración automática
cd backend
alembic revision --autogenerate -m "descripcion"

# Aplicar migraciones
alembic upgrade head

# Ver estado
alembic current
```

📚 **Documentación completa:** [ALEMBIC_GUIDE.md](backend/ALEMBIC_GUIDE.md)  
📋 **Reglas de desarrollo:** [DEVELOPMENT_GUIDELINES.md](DEVELOPMENT_GUIDELINES.md)

---

## 📄 Licencia

Este proyecto es de código abierto.
