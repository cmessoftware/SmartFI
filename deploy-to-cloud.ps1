# 🚀 Script Quick Deploy to GitHub
# Sube tus cambios a GitHub para deployment automático

Write-Host "🚀 === Finly - Deploy to Cloud ===" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path .git)) {
    Write-Host "📦 Inicializando repositorio Git..." -ForegroundColor Yellow
    git init
    git branch -M main
}

# Check git status
Write-Host "📋 Estado actual:" -ForegroundColor Cyan
git status --short

Write-Host ""
Write-Host "¿Qué deseas hacer?" -ForegroundColor Cyan
Write-Host "  1. Commit y Push a GitHub"
Write-Host "  2. Solo Commit (local)"
Write-Host "  3. Ver cambios en detalle"
Write-Host "  4. Configurar remote (primera vez)"
Write-Host "  0. Salir"
Write-Host ""

$option = Read-Host "Selecciona una opción"

switch ($option) {
    "1" {
        Write-Host ""
        $message = Read-Host "Mensaje del commit (Enter para usar default)"
        if ([string]::IsNullOrWhiteSpace($message)) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
            $message = "Update: $timestamp"
        }
        
        Write-Host ""
        Write-Host "📦 Agregando archivos..." -ForegroundColor Yellow
        git add .
        
        Write-Host "💾 Haciendo commit..." -ForegroundColor Yellow
        git commit -m "$message"
        
        Write-Host "🚀 Pushing a GitHub..." -ForegroundColor Green
        try {
            git push origin main
            Write-Host ""
            Write-Host "✅ ¡Push exitoso!" -ForegroundColor Green
            Write-Host ""
            Write-Host "🔄 Si tienes auto-deploy configurado:" -ForegroundColor Cyan
            Write-Host "   • Render: Deployment iniciará automáticamente" -ForegroundColor White
            Write-Host "   • Railway: Build empezará en unos segundos" -ForegroundColor White
            Write-Host ""
            Write-Host "📊 Monitorea el deployment en tu dashboard" -ForegroundColor Yellow
        } catch {
            Write-Host ""
            Write-Host "❌ Error al hacer push:" -ForegroundColor Red
            Write-Host $_.Exception.Message
            Write-Host ""
            Write-Host "💡 ¿Primera vez? Usa la opción 4 para configurar remote" -ForegroundColor Yellow
        }
    }
    "2" {
        Write-Host ""
        $message = Read-Host "Mensaje del commit"
        if ([string]::IsNullOrWhiteSpace($message)) {
            $message = "Local update"
        }
        
        git add .
        git commit -m "$message"
        Write-Host "✅ Commit guardado localmente" -ForegroundColor Green
    }
    "3" {
        Write-Host ""
        Write-Host "📝 Cambios en detalle:" -ForegroundColor Cyan
        git diff
        Write-Host ""
        Write-Host "📋 Archivos modificados:" -ForegroundColor Cyan
        git status
    }
    "4" {
        Write-Host ""
        Write-Host "🔗 Configurar Remote Repository" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Pasos:" -ForegroundColor Yellow
        Write-Host "1. Ve a GitHub.com y crea un nuevo repositorio"
        Write-Host "2. Copia la URL (https o SSH)"
        Write-Host ""
        
        $remote = Read-Host "Pega la URL de tu repositorio"
        
        if (-not [string]::IsNullOrWhiteSpace($remote)) {
            try {
                # Check if remote already exists
                $existingRemote = git remote get-url origin 2>$null
                if ($existingRemote) {
                    Write-Host "⚠️ Remote 'origin' ya existe: $existingRemote" -ForegroundColor Yellow
                    $replace = Read-Host "¿Reemplazar? (S/N)"
                    if ($replace -eq "S" -or $replace -eq "s") {
                        git remote remove origin
                        git remote add origin $remote
                        Write-Host "✅ Remote actualizado" -ForegroundColor Green
                    }
                } else {
                    git remote add origin $remote
                    Write-Host "✅ Remote agregado" -ForegroundColor Green
                }
                
                Write-Host ""
                Write-Host "📤 ¿Hacer push ahora? (S/N)" -ForegroundColor Cyan
                $push = Read-Host
                
                if ($push -eq "S" -or $push -eq "s") {
                    git push -u origin main
                    Write-Host "✅ ¡Código subido a GitHub!" -ForegroundColor Green
                }
            } catch {
                Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    "0" {
        Write-Host "👋 ¡Hasta luego!" -ForegroundColor Cyan
        exit 0
    }
    default {
        Write-Host "❌ Opción inválida" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📚 Próximos Pasos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Código en GitHub ✅" -ForegroundColor Green
Write-Host "2. Deploy en la nube:" -ForegroundColor Yellow
Write-Host "   • Ver: DEPLOY_DOCKER_CLOUD.md" -ForegroundColor White
Write-Host "   • Render: render.com (más fácil)" -ForegroundColor White
Write-Host "   • Railway: railway.app (más rápido)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: Cada push a 'main' redesplegará automáticamente" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
