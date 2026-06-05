# Generar Issues en Gitea para EXP-FEAT-014

## Opción 1: Script automático (requiere token)

Si tenés un token de Gitea, ejecutá:

```powershell
pwsh ./scripts/create-issues-exp-feat-014.ps1 -Token "tu-token-aqui"
```

O con variable de entorno:
```powershell
$env:GITEA_TOKEN = "tu-token-aqui"
pwsh ./scripts/create-issues-exp-feat-014.ps1
```

---

## Opción 2: Generar token manualmente (recomendado)

1. Abrí Gitea: http://localhost:3001
2. Iniciá sesión como **admin**
3. Hacé clic en tu avatar (arriba a la derecha) → **Settings**
4. Ve a **Applications** en el menú izquierdo
5. En "Manage Access Tokens", completá:
   - **Token Name**: `SmartFI-Issues-Bot`
   - **Scopes**: Elige `repository` y marca los checkboxes que te aparezcan
6. Hacé clic en **Generate Token**
7. **Copia el token** (cadena larga, no se volverá a mostrar)
8. Ejecutá:
   ```powershell
   pwsh ./scripts/create-issues-exp-feat-014.ps1 -Token "token-que-copiaste"
   ```

---

## Opción 3: Generar un token vía curl (headless)

Si querés generar el token desde la línea de comandos (reemplazá `CONTRASEÑA_ADMIN`):

```powershell
# 1. Generar token
$auth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("admin:CONTRASEÑA_ADMIN"))
$response = Invoke-WebRequest `
  -Uri "http://localhost:3001/api/v1/user/tokens" `
  -Method POST `
  -Headers @{"Authorization" = "Basic $auth"; "Content-Type" = "application/json"} `
  -Body (@{name = "SmartFI-Bot"; scopes = @("repo")} | ConvertTo-Json)

$token = ($response.Content | ConvertFrom-Json).sha1
Write-Host "Token generado: $token"

# 2. Usar el token para crear issues
pwsh ./scripts/create-issues-exp-feat-014.ps1 -Token $token
```

---

## Opción 4: Crear issues manualmente

Si preferís no ejecutar scripts, copiá y pegá en Gitea (Issues → New Issue):

### Issue #1: Backend Functions
**Título**: `[EXP-FEAT-014] Backend: Funciones de comparativa de meses`
**Labels**: `EXP-FEAT-014`, `exp`, `backend`, `month-management`
[Ver contenido en GITEA_ISSUES.md]

### Issue #2-7
[Ver GITEA_ISSUES.md para detalles de cada issue]

---

## Verificación

Después de crear los issues, verificá en:
http://localhost:3001/admin/SmartFI/issues?labels=EXP-FEAT-014

Deberías ver 7 issues listados.
