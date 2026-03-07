# 🚀 INICIO RÁPIDO - De Local a la Nube en 15 minutos

Tu app funciona local con Docker. Ahora vamos a la nube.

## ✅ Prerrequisitos

- [x] Docker funcionando localmente (ya lo tienes ✅)
- [ ] Cuenta en GitHub
- [ ] Elegir plataforma cloud (recomendado: Render)

## 🎯 Ruta Más Rápida: Render

### Paso 1: Sube a GitHub (5 min)

**Opción A: Script interactivo**
```powershell
.\deploy-to-cloud.ps1
```
Sigue el menú → Opción 4 (configurar remote) → Opción 1 (push)

**Opción B: Manual**
```powershell
# Primera vez
git init
git add .
git commit -m "Deploy ready"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/Finly.git
git push -u origin main

# Actualizaciones
git add .
git commit -m "Update"
git push
```

### Paso 2: Deploy en Render (5 min)

1. **Ir a https://render.com**
   - Sign up con GitHub (más rápido)

2. **New + → Blueprint**
   - Conectar tu repositorio "Finly"
   - Render detecta `render.yaml` automáticamente
   - **Variables de entorno requeridas:**
     - `GOOGLE_SHEET_ID`: (Pega tu ID de Google Sheet)
     - `VITE_API_URL`: **Dejar vacío por ahora** ⚠️
     - `FRONTEND_URL`: **Dejar vacío por ahora** ⚠️
   - Click **"Apply"**

3. **Esperar 5-10 min** ☕
   - Render construye todo automáticamente
   - ⚠️ El frontend fallará inicialmente (esperado)
   - Toma nota de las URLs cuando terminen

4. **Configurar URLs (CRÍTICO)** ⚠️
   
   Una vez que los servicios estén creados:
   
   **A. Configurar VITE_API_URL en el Frontend:**
   1. Ve al servicio **finly-frontend**
   2. Environment → Add/Edit:
      ```
      VITE_API_URL = https://finly-api-XXXX.onrender.com
      ```
      (Reemplaza con TU URL del backend, incluyendo `/api` al final si es necesario)
   3. Guarda → Manual Deploy → Clear build cache & deploy
   
   **B. Configurar FRONTEND_URL en el Backend:**
   1. Ve al servicio **finly-api**
   2. Environment → Add/Edit:
      ```
      FRONTEND_URL = https://finly-frontend-XXXX.onrender.com
      ```
      (Sin barra `/` al final)
   3. Guarda → El servicio se reiniciará automáticamente

5. **¡Listo! 🎉**
   ```
   App: https://finly-frontend-XXXX.onrender.com
   API: https://finly-api-XXXX.onrender.com/docs
   ```

### Paso 3: Verificar

- [ ] Frontend carga
- [ ] Login: admin / admin123
- [ ] Crear transacción
- [ ] Refrescar → datos persisten

## 📊 Comparativa Rápida

| Plataforma | Gratis | Duerme | Setup | Recomendado |
|------------|--------|---------|-------|-------------|
| **Render** | ✅ | Sí (15min) | ⭐ Fácil | ✅ **SÍ** |
| **Railway** | $5/mes | No | ⭐⭐ Media | Si pagas |
| **Fly.io** | ✅ | No | ⭐⭐⭐ CLI | Avanzado |

## 🔄 Workflow después del Deploy

```
Cambias código local
     ↓
git add . && git commit -m "Update" && git push
     ↓
Render detecta cambios
     ↓
Auto-deploy (5-10 min)
     ↓
App actualizada en la nube ✅
```

## 🐛 Problemas Comunes

**App muy lenta al inicio**
- Normal en Render gratuito (despierta de "sleep")
- Primera carga: 30-60 seg
- Después rápido

**Error 503 / No responde**
- Espera 2-3 min más (todavía desplegando)
- Revisa logs en Render dashboard

**Error de CORS**
- Verifica `FRONTEND_URL` en backend
- Debe ser la URL real de Render (sin barra final)

## 💡 Tips

1. **Monitoreo:** Usa UptimeRobot (gratis) para ping cada 5 min
2. **Logs:** Render Dashboard → Tu servicio → Logs
3. **Dominio:** Puedes usar dominio custom gratis
4. **SSL:** HTTPS automático, no hacer nada

## 📚 Más Info

- **Comparativa completa:** [DEPLOY_DOCKER_CLOUD.md](DEPLOY_DOCKER_CLOUD.md)
- **Guía detallada Render:** [RENDER_DEPLOY.md](RENDER_DEPLOY.md)
- **Checklist completo:** [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md)

## 🎯 TL;DR

```powershell
# 1. Push a GitHub
.\deploy-to-cloud.ps1

# 2. Render.com
New Blueprint → Conectar repo → Apply

# 3. Configurar FRONTEND_URL
# 4. ¡Listo! 🎉
```

**Tiempo total:** ~15 minutos
**Costo:** $0

---

¿Dudas? Revisa [DEPLOY_DOCKER_CLOUD.md](DEPLOY_DOCKER_CLOUD.md) para más opciones y detalles.
