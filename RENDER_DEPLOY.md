# 🚀 Guía de Deployment en Render (Plan Gratuito)

Esta guía explica cómo desplegar **Finly** completo (frontend + backend + PostgreSQL) en Render de forma gratuita.

## 📋 Requisitos Previos

1. Cuenta en GitHub
2. Cuenta en Render (https://render.com - puedes usar tu cuenta de GitHub)
3. Código subido a un repositorio de GitHub

## 🎯 Pasos para el Deployment

### 1. Preparar el Repositorio

Asegúrate de que tu código esté en GitHub:

```bash
git init
git add .
git commit -m "Preparar para deployment en Render"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/Finly.git
git push -u origin main
```

### 2. Crear Servicios en Render

#### Opción A: Deployment Automático (Blueprint)

1. Ve a https://dashboard.render.com/
2. Click en **"New +"** → **"Blueprint"**
3. Conecta tu repositorio de GitHub
4. Render detectará automáticamente el archivo `render.yaml`
5. Click en **"Apply"**

¡Listo! Render creará automáticamente:
- ✅ Base de datos PostgreSQL
- ✅ Backend API (FastAPI)
- ✅ Frontend (React/Vite)

#### Opción B: Deployment Manual

Si prefieres crear cada servicio manualmente:

##### 2.1 Crear la Base de Datos

1. Dashboard → **"New +"** → **"PostgreSQL"**
2. Configuración:
   - **Name**: `finly-db`
   - **Database**: `fin_per_db`
   - **Plan**: Free
   - **Region**: Oregon (o el más cercano)
3. Click **"Create Database"**
4. **Importante**: Guarda la **Internal Database URL** (la usaremos después)

##### 2.2 Crear el Backend

1. Dashboard → **"New +"** → **"Web Service"**
2. Conecta tu repositorio de GitHub
3. Configuración:
   - **Name**: `finly-api`
   - **Region**: Oregon
   - **Root Directory**: `backend`
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Plan**: Free

4. **Variables de Entorno**:
   Agrega estas variables en "Environment":
   ```
   SECRET_KEY = (auto-generar un valor seguro de 32+ caracteres)
   ALGORITHM = HS256
   ACCESS_TOKEN_EXPIRE_MINUTES = 30
   DATABASE_URL = (pega la Internal Database URL de tu PostgreSQL)
   GOOGLE_SHEET_ID = (opcional - tu ID de Google Sheet)
   PYTHON_VERSION = 3.11.0
   ```

5. Click **"Create Web Service"**

##### 2.3 Crear el Frontend

1. Dashboard → **"New +"** → **"Static Site"**
2. Conecta tu repositorio de GitHub
3. Configuración:
   - **Name**: `finly-frontend`
   - **Region**: Oregon
   - **Root Directory**: `frontend`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`
   - **Plan**: Free

4. **Variables de Entorno**:
   ```
   VITE_API_URL = https://finly-api.onrender.com
   ```
   (reemplaza `finly-api` con el nombre real de tu servicio backend)

5. **Rewrite Rules**:
   - Click en "Redirects/Rewrites"
   - Agrega:
     - **Source**: `/*`
     - **Destination**: `/index.html`
     - **Type**: Rewrite

6. Click **"Create Static Site"**

## 🔧 Configuración Post-Deployment

### Actualizar CORS en el Backend

Después de que se despliegue el frontend, necesitas actualizar la URL de CORS:

1. Ve a tu servicio backend en Render
2. Environment → Agrega:
   ```
   FRONTEND_URL = https://finly-frontend.onrender.com
   ```
3. El código ya está preparado para esto (ver `main.py`)

### Configurar Google Sheets (Opcional)

Si usas Google Sheets:

1. Sube tu archivo `credentials.json` como variable de entorno:
   - En el backend service → Environment
   - Crea: `GOOGLE_CREDENTIALS_JSON` con el contenido del archivo
   
2. O modifica el código para leerlo de la variable de entorno

## 🌐 URLs de Acceso

Después del deployment:

- **Frontend**: `https://finly-frontend.onrender.com`
- **Backend API**: `https://finly-api.onrender.com`
- **API Docs**: `https://finly-api.onrender.com/docs`
- **Health Check**: `https://finly-api.onrender.com/api/health`

## ⚠️ Limitaciones del Plan Gratuito

- **Backend se "duerme"** después de 15 minutos de inactividad
- Primera solicitud después de dormir tarda ~30-60 segundos
- Base de datos PostgreSQL: 
  - 90 días de retención
  - Expira después de 90 días sin actividad
- 750 horas/mes (suficiente para un servicio)
- 100GB bandwidth/mes

## 🔄 Actualizar la Aplicación

Cualquier push a tu rama `main` en GitHub activará un auto-deploy:

```bash
git add .
git commit -m "Actualización"
git push
```

Render detectará los cambios y redesplegará automáticamente.

## 🐛 Troubleshooting

### El backend no inicia
- Revisa los logs en Render Dashboard
- Verifica que todas las variables de entorno estén configuradas
- Asegúrate de que `requirements.txt` tenga todas las dependencias

### Error de CORS
- Verifica que `VITE_API_URL` en el frontend apunte al backend correcto
- Asegúrate de que el backend permita la URL del frontend en CORS

### Base de datos no conecta
- Usa la **Internal Database URL**, no la External
- Verifica que esté en el formato: `postgresql://user:pass@host/dbname`

### El frontend muestra página en blanco
- Revisa la consola del navegador (F12)
- Verifica que los rewrite rules estén configurados
- Asegúrate de que `VITE_API_URL` esté correcta

## 📊 Monitoreo

En Render Dashboard puedes ver:
- Logs en tiempo real
- Uso de recursos
- Estado de deployment
- Métricas de tráfico

## 💰 Upgrade a Plan Pago (Opcional)

Si necesitas más recursos:
- **Starter ($7/mes)**: Sin sleeping, más recursos
- **PostgreSQL Starter ($7/mes)**: Base de datos permanente

## 🔐 Seguridad

Antes de producción:
- ✅ Cambia `SECRET_KEY` a un valor único y seguro
- ✅ No subas archivos `.env` al repositorio
- ✅ Usa variables de entorno en Render
- ✅ Revisa las credenciales de Google Sheets

---

¿Necesitas ayuda? Revisa:
- [Documentación de Render](https://render.com/docs)
- [Render Community](https://community.render.com/)
