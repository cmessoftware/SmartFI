# Finly - Docker Quick Start Script
# Script para iniciar la aplicación completa con Docker

Write-Host "🐳 === Finly - Docker Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Get current commit hash
try {
    $commitHash = git log -1 --format=%h
    $env:COMMIT_HASH = $commitHash
    Write-Host "📌 Commit Hash: $commitHash" -ForegroundColor Magenta
} catch {
    $env:COMMIT_HASH = "dev"
    Write-Host "⚠️  No se pudo obtener commit hash, usando 'dev'" -ForegroundColor Yellow
}
Write-Host ""

# Check if Docker is running
Write-Host "🔍 Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker no está instalado o no está ejecutándose" -ForegroundColor Red
    Write-Host "   Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Check if Docker Compose is available
try {
    $composeVersion = docker-compose --version
    Write-Host "✅ Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker Compose no está disponible" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 Opciones de Deployment:" -ForegroundColor Cyan
Write-Host "  1. Iniciar todos los servicios (Build + Start)"
Write-Host "  2. Solo iniciar (sin rebuild)"
Write-Host "  3. Detener servicios"
Write-Host "  4. Detener y limpiar todo"
Write-Host "  5. Ver logs"
Write-Host "  6. Ver estado de servicios"
Write-Host "  7. Reconstruir y reiniciar"
Write-Host "  0. Salir"
Write-Host ""

$option = Read-Host "Selecciona una opción"

switch ($option) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Construyendo y levantando servicios..." -ForegroundColor Green
        Write-Host "   Esto puede tardar 2-5 minutos la primera vez..." -ForegroundColor Yellow
        Write-Host ""
        docker-compose up --build
    }
    "2" {
        Write-Host ""
        Write-Host "🚀 Levantando servicios..." -ForegroundColor Green
        docker-compose up
    }
    "3" {
        Write-Host ""
        Write-Host "⏸️  Deteniendo servicios..." -ForegroundColor Yellow
        docker-compose stop
        Write-Host "✅ Servicios detenidos" -ForegroundColor Green
    }
    "4" {
        Write-Host ""
        Write-Host "🗑️  ¿Estás seguro? Esto eliminará todos los contenedores y volúmenes (datos)" -ForegroundColor Red
        $confirm = Read-Host "Escribir 'SI' para confirmar"
        if ($confirm -eq "SI") {
            docker-compose down -v
            Write-Host "✅ Todo limpiado" -ForegroundColor Green
        } else {
            Write-Host "❌ Cancelado" -ForegroundColor Yellow
        }
    }
    "5" {
        Write-Host ""
        Write-Host "📋 Mostrando logs (Ctrl+C para salir)..." -ForegroundColor Cyan
        docker-compose logs -f
    }
    "6" {
        Write-Host ""
        Write-Host "📊 Estado de servicios:" -ForegroundColor Cyan
        docker-compose ps
        Write-Host ""
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    }
    "7" {
        Write-Host ""
        Write-Host "🔄 Reconstruyendo todo..." -ForegroundColor Yellow
        docker-compose down
        docker-compose build --no-cache
        Write-Host ""
        Write-Host "🚀 Levantando servicios..." -ForegroundColor Green
        docker-compose up -d
        Write-Host ""
        Write-Host "✅ Servicios reiniciados" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Ver logs con: docker-compose logs -f" -ForegroundColor Cyan
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
Write-Host "🌐 URLs de Acceso:" -ForegroundColor Cyan
Write-Host "   Aplicación Web: http://localhost:3000" -ForegroundColor Green
Write-Host "   API Backend:    http://localhost:8000" -ForegroundColor Green
Write-Host "   API Docs:       http://localhost:8000/docs" -ForegroundColor Green
Write-Host "   Health Check:   http://localhost:8000/api/health" -ForegroundColor Green
Write-Host ""
Write-Host "👤 Usuarios de Prueba:" -ForegroundColor Cyan
Write-Host "   Admin:  admin / admin123" -ForegroundColor Yellow
Write-Host "   Writer: writer / writer123" -ForegroundColor Yellow
Write-Host "   Reader: reader / reader123" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# If services are running in detached mode, show how to see logs
if ($option -eq "7") {
    Write-Host "💡 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "   Ver logs:       docker-compose logs -f" -ForegroundColor White
    Write-Host "   Detener:        docker-compose stop" -ForegroundColor White
    Write-Host "   Reiniciar:      docker-compose restart" -ForegroundColor White
    Write-Host "   Ver estado:     docker-compose ps" -ForegroundColor White
    Write-Host ""
}
