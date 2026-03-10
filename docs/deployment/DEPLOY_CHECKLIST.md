# ✅ Checklist de Deployment en Render

## 📝 Pasos Rápidos

### 1. Preparar y Subir a GitHub
```bash
# Si no tienes repositorio todavía:
git init
git add .
git commit -m "Initial commit - Preparar para Render"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/Finly.git
git push -u origin main
```

### 2. Crear Cuenta en Render
- [ ] Ir a https://render.com
- [ ] Registrarse con GitHub (más fácil)
- [ ] Verificar email

### 3. Deployment Automático (Blueprint)
- [ ] Dashboard → **"New +"** → **"Blueprint"**
- [ ] Conectar repositorio Finly
- [ ] Render detecta `render.yaml` automáticamente
- [ ] Click **"Apply"**
- [ ] ¡Esperar 5-10 minutos! ☕

### 4. Configurar Variables de Entorno

#### Backend (finly-api):
- [ ] `SECRET_KEY` → Generar un valor aleatorio largo (32+ chars)
- [ ] `ALGORITHM` → `HS256` (ya configurado)
- [ ] `ACCESS_TOKEN_EXPIRE_MINUTES` → `30` (ya configurado)
- [ ] `DATABASE_URL` → Auto-configurado desde la base de datos
- [ ] `FRONTEND_URL` → Tu URL del frontend (ej: `https://finly-frontend.onrender.com`)
- [ ] `GOOGLE_SHEET_ID` → (opcional) Tu ID de Google Sheet para backup/sync
- [ ] `GOOGLE_CREDENTIALS_JSON` → (opcional) Contenido del archivo credentials.json como string JSON

#### Frontend (finly-frontend):
- [ ] `VITE_API_URL` → URL de tu backend (ej: `https://finly-api.onrender.com`)

### 5. Configurar Google Sheets (Opcional - Backup y Sincronización)

#### ¿Por qué usar Google Sheets?
- 🔄 **Sincronización bidireccional**: Puedes editar en Sheets y sincronizar con el botón "Sincronizar desde Sheets"
- 📊 **Backup automático**: Todas las transacciones se guardan también en Sheets
- 👥 **Colaboración**: Comparte tu hoja con familia para que agreguen gastos directamente

#### Pasos para configurar:
1. **Crear Google Sheet**: 
   - Crea una nueva hoja en Google Sheets
   - Copia el ID de la URL: `https://docs.google.com/spreadsheets/d/TU_SHEET_ID/edit`

2. **Crear Service Account**:
   - Ver guía completa en: [docs/configuration/GOOGLE_SHEETS_SETUP.md](../configuration/GOOGLE_SHEETS_SETUP.md)
   - Descargar archivo `credentials.json`

3. **Configurar en Render**:
   - `GOOGLE_SHEET_ID`: Pegar el ID de tu hoja
   - `GOOGLE_CREDENTIALS_JSON`: Abrir `credentials.json`, copiar TODO el contenido y pegarlo como string

4. **Compartir Sheet con Service Account**:
   - Abre `credentials.json` y busca `"client_email"`
   - En Google Sheets, compartir con ese email con permisos de Editor

#### Funcionamiento del Botón "Sincronizar desde Sheets":
- 📥 Toma todas las transacciones de Google Sheets
- 🔍 Compara con las que ya existen en PostgreSQL (evita duplicados)
- 💾 Guarda solo las transacciones nuevas en PostgreSQL
- ✨ Actualiza la UI con los datos más recientes

### 6. Verificar Deployment
- [ ] Backend: `https://TU-BACKEND.onrender.com/api/health`
- [ ] Frontend: `https://TU-FRONTEND.onrender.com`
- [ ] Probar login con:
  - Admin: `admin` / `admin123`
  - Writer: `writer` / `writer123`
  - Reader: `reader` / `reader123`

### 6. Configurar Redirects en Frontend
- [ ] En el servicio frontend → "Redirects/Rewrites"
- [ ] Source: `/*`
- [ ] Destination: `/index.html`
- [ ] Type: **Rewrite**

### 8. Probar Sincronización con Google Sheets (si está configurado)
- [ ] Agregar una transacción directamente en Google Sheets
- [ ] Ir al dashboard y hacer clic en "Sincronizar desde Sheets"
- [ ] Verificar que aparezca la nueva transacción

## 🎯 URLs Finales

Después del deployment, tendrás:

- **App**: `https://finly-frontend.onrender.com`
- **API**: `https://finly-api.onrender.com`
- **Docs**: `https://finly-api.onrender.com/docs`

## ⚡ Comandos Útiles

### Regenerar SECRET_KEY seguro:
```bash
# Python
python -c "import secrets; print(secrets.token_urlsafe(32))"

# PowerShell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
```

### Ver logs en tiempo real:
En Render Dashboard → Tu Servicio → "Logs"

### Forzar re-deploy:
```bash
git commit --allow-empty -m "Trigger deploy"
git push
```

## 🐛 Troubleshooting Común

### "Application failed to respond"
- ✅ Verifica que el puerto sea `$PORT` en el start command
- ✅ Backend: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Error de CORS
- ✅ Agrega `FRONTEND_URL` en el backend
- ✅ Verifica que `VITE_API_URL` sea correcta en el frontend

### Base de datos no conecta
- ✅ Usa "Internal Database URL" no External
- ✅ Verifica que `DATABASE_URL` esté configurada

### Primera carga muy lenta
- ✅ Normal en plan gratuito (servicios duermen tras 15 min)
- ✅ Primera petición tarda ~30-60 seg en despertar

### Google Sheets no sincroniza
- ✅ Verifica que `GOOGLE_SHEET_ID` esté configurado correctamente
- ✅ Verifica que `GOOGLE_CREDENTIALS_JSON` sea válido (JSON completo)
- ✅ Asegúrate de compartir la hoja con el email del service account
- ✅ Verifica permisos: el service account debe tener acceso de "Editor"
- ✅ Revisa los logs del backend en Render para ver errores específicos
- ✅ El botón "Sincronizar" solo aparece para usuarios admin/writer

### Error "503 Google Sheets not configured"
- ✅ Falta configurar `GOOGLE_SHEET_ID` o `GOOGLE_CREDENTIALS_JSON`
- ✅ Esto es opcional - la app funciona sin Google Sheets usando solo PostgreSQL

### Las transacciones nuevas no aparecen después de sincronizar
- ✅ Verifica que el formato de la hoja sea correcto (headers en español)
- ✅ Headers requeridos: Marca temporal, Fecha, Tipo, Categoría, Monto, Necesidad, Partida, Detalle
- ✅ El sistema detecta duplicados por fecha+monto+categoría+detalle

## 💡 Tips

1. **Monitorea los logs** durante el primer deploy
2. **Usa Health Check** para verificar que el backend funciona
3. **Guarda tus URLs** en un lugar seguro
4. **Plan gratuito**: El backend duerme, pero despierta automáticamente
5. **Auto-deploy**: Cada push a `main` redespliega automáticamente

## 🚀 ¡Listo para Producción!

Una vez completados estos pasos, tu aplicación estará 100% funcional en internet con:
- ✅ Frontend deployado
- ✅ Backend API funcionando
- ✅ Base de datos PostgreSQL
- ✅ HTTPS automático
- ✅ Auto-deploy desde GitHub

---

**Tiempo estimado**: 15-20 minutos 
**Costo**: $0 (Plan gratuito)
