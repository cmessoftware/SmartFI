# ☁️ Deploy de Contenedores Docker en la Nube (GRATIS)

Ya tienes tu app funcionando con Docker localmente. Ahora vamos a la nube.

## 🎯 Opciones Gratuitas Comparadas

### 1. 🥇 Render (Recomendado para Finly)

**✅ Pros:**
- Soporta Docker nativamente
- PostgreSQL gratis incluido
- Auto-deploy desde GitHub
- SSL/HTTPS automático
- Muy fácil de usar
- No necesitas tarjeta de crédito

**❌ Contras:**
- El plan gratuito "duerme" después de 15 min inactividad
- Primera petición tarda ~30-60 seg en despertar

**Límites gratuitos:**
- 750 horas/mes por servicio
- 100 GB bandwidth/mes
- PostgreSQL: 90 días retención

**Ideal para:** Full-stack apps como Finly

---

### 2. 🚂 Railway

**✅ Pros:**
- Excelente soporte para Docker
- No duerme como Render
- PostgreSQL incluido
- Deploy desde GitHub
- Muy rápido
- Interfaz moderna

**❌ Contras:**
- ⚠️ $5 USD/mes de crédito gratis
- Puede no alcanzar para uso intenso
- Necesita tarjeta de crédito (no cobra, solo verifica)

**Límites gratuitos:**
- $5 crédito mensual
- ~500 horas de uso

**Ideal para:** Apps que necesitas siempre activas

---

### 3. 🪁 Fly.io

**✅ Pros:**
- Soporte completo para Docker
- Puedes usar docker-compose directamente
- 3 máquinas pequeñas gratis
- PostgreSQL incluido
- CDN global (rápido en todo el mundo)

**❌ Contras:**
- Un poco más técnico
- Necesita CLI (línea de comandos)
- Requiere tarjeta de crédito

**Límites gratuitos:**
- 3 shared-cpu VMs
- 160 GB bandwidth/mes
- 3 GB persistent storage

**Ideal para:** Developers con experiencia técnica

---

### 4. ☁️ Google Cloud Run

**✅ Pros:**
- Escala automáticamente
- Solo pagas por uso
- Muy generoso en plan gratuito
- Excelente para APIs

**❌ Contras:**
- No incluye base de datos gratis
- Necesitas Cloud SQL (de pago) o externa
- Más complejo de configurar

**Límites gratuitos:**
- 2 millones requests/mes
- 360,000 GB-segundos/mes
- 180,000 vCPU-segundos/mes

**Ideal para:** APIs sin estado (stateless)

---

### 5. 🔷 Azure Container Apps

**✅ Pros:**
- 180,000 vCPU segundos gratis/mes
- 360,000 GB segundos gratis/mes
- Integración con Azure

**❌ Contras:**
- Base de datos no incluida
- Más complejo que Render
- Necesita tarjeta de crédito

**Ideal para:** Si ya usas Azure

---

### 6. ❌ Otras opciones NO recomendadas para Docker

**Vercel / Netlify:**
- Solo para frontend estático
- No soportan contenedores backend
- No tienen base de datos

**Heroku:**
- Ya no tiene plan gratuito (desde Nov 2022)
- Ahora es de pago

**AWS Free Tier:**
- Muy complejo para principiantes
- 12 meses gratis solo
- Requiere configuración avanzada

---

## 🏆 Recomendación para Finly

### Opción A: TODO EN RENDER (Más Fácil) ⭐

**Por qué:**
- ✅ Frontend + Backend + PostgreSQL todo gratis
- ✅ Super fácil de configurar
- ✅ No necesitas modificar nada del código
- ✅ Auto-deploy desde GitHub

**Limitación:** Duerme después de 15 min (aceptable para proyectos personales)

### Opción B: Railway (Si tienes $5/mes)

**Por qué:**
- ✅ No duerme
- ✅ Más rápido que Render
- ✅ Base de datos incluida

---

## 🚀 Deploy en Render (Paso a Paso)

### Preparación (5 minutos)

#### 1. Sube tu código a GitHub

```powershell
# Si no tienes repo todavía
git init
git add .
git commit -m "Initial commit - Docker deployment ready"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/Finly.git
git push -u origin main
```

#### 2. Crea cuenta en Render

- Ve a https://render.com
- Sign up con GitHub (más fácil)
- Verifica tu email

---

### Deploy Automático con Blueprint (10 minutos)

Ya tienes el archivo `render.yaml` que creamos. Render lo detectará automáticamente.

#### Opción 1: Blueprint (Recomendado - 1 click)

1. **Dashboard de Render** → **"New +"** → **"Blueprint"**

2. **Conectar repositorio:**
   - Autoriza GitHub
   - Selecciona el repo "Finly"
   - Click **"Connect"**

3. **Render detecta `render.yaml`:**
   - Verás: Frontend, Backend, Database
   - Click **"Apply"**

4. **Esperar 5-10 minutos** ☕
   - Render creará todo automáticamente
   - Frontend: building...
   - Backend: building...
   - Database: provisioning...

5. **Configurar variables de entorno después:**

   **Backend Service:**
   - Click en el servicio "finly-api"
   - Environment → Add Environment Variable:
   ```
   FRONTEND_URL = https://finly-frontend.onrender.com
   SECRET_KEY = [genera uno seguro, ver abajo]
   ```

   **Frontend Service:**
   - Click en "finly-frontend"
   - Environment → Verify:
   ```
   VITE_API_URL = https://finly-api.onrender.com
   ```

6. **Verificar:**
   - Frontend: `https://finly-frontend.onrender.com`
   - Backend: `https://finly-api.onrender.com/api/health`
   - Login: admin / admin123

✅ **¡Listo!** Tu app está en la nube.

---

#### Opción 2: Manual (Si prefieres control)

Si no quieres usar Blueprint:

**Paso 1: Base de Datos**
1. New → PostgreSQL
2. Name: `finly-db`
3. Database: `fin_per_db`
4. Plan: Free
5. Create Database
6. **Guardar Internal Database URL**

**Paso 2: Backend**
1. New → Web Service
2. Conectar GitHub repo
3. Settings:
   ```
   Name: finly-api
   Region: Oregon
   Branch: main
   Root Directory: backend
   Runtime: Docker
   Plan: Free
   ```
4. Environment Variables:
   ```
   SECRET_KEY = [tu valor seguro]
   DATABASE_URL = [Internal Database URL del paso 1]
   FRONTEND_URL = https://finly-frontend.onrender.com
   ```
5. Create Web Service

**Paso 3: Frontend**
1. New → Static Site
2. Conectar GitHub repo
3. Settings:
   ```
   Name: finly-frontend
   Region: Oregon
   Branch: main
   Root Directory: frontend
   Build Command: npm install && npm run build
   Publish Directory: dist
   ```
4. Environment Variables:
   ```
   VITE_API_URL = https://finly-api.onrender.com
   ```
5. Redirects/Rewrites:
   - Source: `/*`
   - Destination: `/index.html`
   - Type: Rewrite
6. Create Static Site

---

## 🚂 Deploy en Railway (Alternativa)

### Preparación

1. Cuenta en https://railway.app
2. Conectar GitHub
3. Agregar tarjeta de crédito (no cobra, solo verifica)

### Deploy

1. **New Project** → **Deploy from GitHub repo**
2. Seleccionar "Finly"
3. Railway detecta `docker-compose.yml` automáticamente
4. **Add PostgreSQL:**
   - Click "+ New" → Database → PostgreSQL
5. **Configurar variables:**
   ```
   DATABASE_URL = ${{Postgres.DATABASE_URL}}
   SECRET_KEY = [generar]
   ```
6. Railway asigna URLs automáticamente
7. ✅ Listo

**Costo:** ~$3-4/mes (del crédito de $5)

---

## 🪁 Deploy en Fly.io (Para Avanzados)

### Instalación CLI

```powershell
# Instalar Fly CLI
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

### Deploy

```powershell
# Autenticar
fly auth login

# Crear app
fly launch

# Fly detecta Dockerfile automáticamente
# Responde las preguntas:
# - App name: finly
# - Deploy: yes
# - PostgreSQL: yes

# Deploy
fly deploy
```

---

## 🔑 Generar SECRET_KEY Seguro

### PowerShell
```powershell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
```

### Python
```python
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Online
https://randomkeygen.com/ (CodeIgniter Encryption Keys)

---

## 📊 Comparación Rápida

| Plataforma | Gratis | Duerme | BD Incluida | Dificultad | Recomendado |
|------------|--------|---------|-------------|------------|-------------|
| **Render** | ✅ | Sí (15min) | ✅ PostgreSQL | ⭐ Fácil | ✅ **SÍ** |
| **Railway** | $5/mes | No | ✅ PostgreSQL | ⭐⭐ Media | ✅ Si pagas |
| **Fly.io** | ✅ | No | ✅ PostgreSQL | ⭐⭐⭐ Difícil | Si sabes CLI |
| **Cloud Run** | ✅ | No | ❌ | ⭐⭐⭐ Difícil | Solo API |
| **Azure** | ✅ Limitado | No | ❌ | ⭐⭐⭐⭐ Muy difícil | No |
| Vercel | N/A | N/A | N/A | N/A | ❌ Solo frontend |
| Heroku | ❌ Pago | - | - | - | ❌ Ya no gratis |

---

## 🎯 Flujo Recomendado

```
1. Desarrollo Local
   ↓
   docker-compose up
   ↓
   Funciona ✅

2. Subir a GitHub
   ↓
   git push

3. Deploy en Render
   ↓
   Blueprint → Apply
   ↓
   Esperar 10 min

4. Configurar URLs
   ↓
   Variables de entorno

5. ¡Producción! 🎉
   ↓
   https://tu-app.onrender.com
```

---

## 🐛 Troubleshooting Común

### "Application failed to respond"
✅ Verifica que el Dockerfile use `$PORT` (Render lo define)
✅ Health check configurado correctamente

### CORS Error
✅ Configura `FRONTEND_URL` en backend
✅ Verifica `VITE_API_URL` en frontend

### Base de datos no conecta
✅ Usa "Internal Database URL" no External
✅ Formato: `postgresql://user:pass@host/db`

### Primera carga muy lenta en Render
✅ Normal, el servicio estaba dormido
✅ Tarda 30-60 seg en despertar
✅ Considera Railway si es problema

---

## 💡 Tips Pro

### 1. Monitoreo
Usa UptimeRobot (gratis) para hacer ping cada 5 min:
- Evita que Render duerma
- Recibes alertas si falla

### 2. Logs
```powershell
# Render: Dashboard → Logs (en tiempo real)
# Railway: Dashboard → Deployments → View Logs
# Fly.io: fly logs
```

### 3. Dominios Personalizados
Todos los servicios permiten dominios custom gratis:
- Compra dominio en Namecheap (~$10/año)
- Configura DNS en Render/Railway
- SSL automático

### 4. Auto-Deploy
Configurado automáticamente:
```powershell
git push origin main
# → Deploy automático en la nube
```

---

## 📈 Escalabilidad Futura

Cuando tu app crezca:

1. **Plan Starter ($7/mes) en Render:**
   - No duerme
   - Más recursos
   - Mejor performance

2. **Railway ($20/mes):**
   - Crédito suficiente para apps medianas

3. **DigitalOcean App Platform:**
   - Desde $5/mes para apps más grandes

---

## ✅ Checklist Final

Antes de deploy:

- [ ] Código en GitHub
- [ ] Cuenta en Render creada
- [ ] `render.yaml` en tu repo (ya lo tienes ✅)
- [ ] Variables de entorno documentadas
- [ ] SECRET_KEY generado
- [ ] `.gitignore` configurado (no subir .env ✅)

Después del deploy:

- [ ] Frontend carga
- [ ] Backend responde (/api/health)
- [ ] Login funciona
- [ ] Crear transacción funciona
- [ ] Datos persisten (refresh y revisar)

---

## 🎓 Resumen Ultra Rápido

**Para Finly (proyecto personal/portafolio):**
```
1. Push a GitHub
2. Render → New Blueprint
3. Conectar repo
4. Apply
5. Configurar FRONTEND_URL
6. ¡Listo! 🎉
```

**Tiempo:** 15-20 minutos
**Costo:** $0
**Resultado:** App en internet con dominio HTTPS

---

## 📚 Documentación Relacionada

- [RENDER_DEPLOY.md](RENDER_DEPLOY.md) - Guía detallada de Render
- [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md) - Checklist paso a paso
- [DOCKER_LOCAL.md](DOCKER_LOCAL.md) - Testing local con Docker
- [DOCKER_EXPLICADO.md](DOCKER_EXPLICADO.md) - Conceptos Docker

---

**¿Listo para hacer deploy?** 🚀

Recomendación: Empieza con **Render** (opción más fácil). Si después necesitas que no duerma, migra a Railway.
