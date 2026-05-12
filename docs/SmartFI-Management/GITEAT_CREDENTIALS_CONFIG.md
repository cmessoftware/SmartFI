# Configurar Credenciales de Gitea para Desarrollo Multi-Usuario

## Problema

Cuando trabajas localmente con git, estás autenticado con tu usuario de GitHub. Para que los commits se atribuyan correctamente a usuarios específicos en Gitea (como `dev1`, `tech_lead`, etc.), necesitas configurar autenticación de Gitea localmente.

## Solución: Dos Opciones

### Opción 1: SSH Key (Recomendado) 🔐

#### Paso 1: Generar SSH key para dev1

```powershell
# Genera una SSH key específica para dev1
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519_dev1" -N "" -C "dev1@smartfi"
```

Esto crea:
- `~/.ssh/id_ed25519_dev1` (clave privada)
- `~/.ssh/id_ed25519_dev1.pub` (clave pública)

#### Paso 2: Agregar la SSH key a dev1 en Gitea

1. Abre Gitea: http://localhost:3001
2. Inicia sesión como **dev1** (username: dev1, password: la que creaste)
3. Ve a **Settings → SSH / GPG Keys**
4. Click **Add Key**
5. Pega el contenido de `~/.ssh/id_ed25519_dev1.pub`:

```powershell
# Copia la clave pública al portapapeles
Get-Content "$env:USERPROFILE\.ssh\id_ed25519_dev1.pub" | Set-Clipboard
```

#### Paso 3: Configurar SSH en tu máquina local

Crea o edita `~/.ssh/config`:

```
Host gitea.local
    HostName localhost
    Port 22
    User git
    IdentityFile ~/.ssh/id_ed25519_dev1
    StrictHostKeyChecking no
```

**En PowerShell:**
```powershell
$sshConfig = @"
Host gitea.local
    HostName localhost
    Port 22
    User git
    IdentityFile ~/.ssh/id_ed25519_dev1
    StrictHostKeyChecking no
"@

Add-Content "$env:USERPROFILE\.ssh\config" $sshConfig
```

#### Paso 4: Cambiar remote gitea a SSH

```powershell
cd c:\Users\sergiosal\source\repos\SmartFI

# Cambia la URL del remote de HTTP a SSH
git remote set-url gitea "ssh://git@localhost:3001/admin/SmartFI.git"

# Verifica
git remote -v
```

Debería mostrar:
```
gitea    ssh://git@localhost:3001/admin/SmartFI.git (fetch)
gitea    ssh://git@localhost:3001/admin/SmartFI.git (push)
origin   https://github.com/cmessoftware/SmartFI.git (fetch)
origin   https://github.com/cmessoftware/SmartFI.git (push)
```

#### Paso 5: Configurar git identity para dev1

```powershell
# Verifica la rama actual
git branch

# Si no estás en feature/exp-month-open-rollover
git fetch gitea
git checkout feature/exp-month-open-rollover

# Configura git identity LOCAL (solo para este repo) como dev1
git config user.name "dev1"
git config user.email "dev1@smartfi.local"

# Verifica
git config user.name
git config user.email
```

#### Paso 6: Prueba la conexión SSH

```powershell
# Test SSH connection to Gitea
ssh -i "$env:USERPROFILE\.ssh\id_ed25519_dev1" git@localhost -v
```

Debería decir algo como `Hi dev1!` o similar.

#### Paso 7: Commit y push

```powershell
# Ahora haz el commit (ya están los cambios en TransactionReport.jsx)
git add frontend/src/components/TransactionReport.jsx
git commit -m "fix(ui): mostrar acciones en Reportes aunque no haya transacciones"

# Push a gitea
git push gitea feature/exp-month-open-rollover
```

Verifica en Gitea que el commit aparece con author **dev1** ✅

---

### Opción 2: Personal Token (Más rápido)

Si SSH no funciona por temas de conectividad SSH a localhost, usa token:

#### Paso 1: Generar token en Gitea

1. Inicia sesión como **dev1** en Gitea
2. **Settings → Applications → New Token**
3. Nombre: `dev1-local-dev`
4. Copia el token

#### Paso 2: Configurar git con el token

```powershell
# Cambia remote a HTTPS
git remote set-url gitea "http://dev1:TOKEN_AQUI@localhost:3001/admin/SmartFI.git"

# Reemplaza TOKEN_AQUI con el token que copiaste

http://dev1:802d08f77baff9bf0201d402f71c152a4cd0e683@localhost:3001/admin/SmartFI.git

# Verifica
git remote -v
```

#### Paso 3: Config identity y commit

```powershell
git config user.name "dev1"
git config user.email "dev1@smartfi.local"

git add frontend/src/components/TransactionReport.jsx
git commit -m "fix(ui): mostrar acciones en Reportes aunque no haya transacciones"

git push gitea feature/exp-month-open-rollover
```

---

## Comparación de Opciones

| Aspecto | SSH | Token |
|--------|-----|-------|
| Seguridad | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Fácil setup | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Funciona en localhost | Requiere SSH en Gitea | ✅ |
| Recommended | ✅ | Si SSH no funciona |

---

## Recomendación

**Intenta SSH primero.** Si falla por conectividad, usa Token.

---

## Verificación Final

Después de completar cualquiera de las opciones, verifica en Gitea:

1. Abre el PR: http://localhost:3001/admin/SmartFI/pulls
2. Ve a **feature/exp-month-open-rollover**
3. En la pestaña **Commits**, debería mostrar:
   - Author: **dev1**
   - Message: "fix(ui): mostrar acciones en Reportes aunque no haya transacciones"

✅ Si ves esto, ¡está configurado correctamente!

---

## Troubleshooting

### SSH no funciona
- Verifica que Gitea tiene SSH habilitado (`Gitea → Admin → Configuration`)
- Comprueba que `~/.ssh/config` está bien formateado
- Intenta con Token como alternativa

### Token expira o no funciona
- Genera un nuevo token en Gitea Settings
- Actualiza el remote URL con el nuevo token
- Prueba con `git push -v gitea` para ver detalles

### Commits siguen apareciendo con usuario antiguo
- Verifica `git config user.name` y `git config user.email`
- Asegúrate de estar en el repo correcto: `cd c:\Users\sergiosal\source\repos\SmartFI`
- El cambio es LOCAL al repo, no global
