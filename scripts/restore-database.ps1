# Script de Restauración de Base de Datos Finly
# Restaura un backup SQL en una base de datos PostgreSQL

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile,
    [string]$DbName = "finly_db",
    [string]$DbHost = "localhost",
    [string]$DbPort = "5432",
    [string]$DbUser = "postgres",
    [switch]$DropExisting = $false
)

# Colores para mensajes
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }

# Verificar que psql esté instalado
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psqlPath) {
    Write-Error "psql no está instalado o no está en el PATH"
    Write-Info "Instale PostgreSQL client tools o agregue psql al PATH"
    exit 1
}

# Verificar que el archivo de backup existe
if (-not (Test-Path $BackupFile)) {
    Write-Error "El archivo de backup no existe: $BackupFile"
    exit 1
}

# Si es un archivo .zip, descomprimirlo primero
if ($BackupFile -match '\.zip$') {
    Write-Info "Descomprimiendo archivo ZIP..."
    $extractPath = [System.IO.Path]::GetDirectoryName($BackupFile)
    Expand-Archive -Path $BackupFile -DestinationPath $extractPath -Force
    $BackupFile = $BackupFile -replace '\.zip$', ''
    Write-Success "Archivo descomprimido: $BackupFile"
}

Write-Info "=== Restauración de Base de Datos Finly ==="
Write-Info "Base de datos: $DbName"
Write-Info "Host: ${DbHost}:${DbPort}"
Write-Info "Usuario: $DbUser"
Write-Info "Archivo de backup: $BackupFile"
Write-Info ""

# Advertencia si se va a eliminar la base de datos existente
if ($DropExisting) {
    Write-Warning "¡ADVERTENCIA! Se eliminará la base de datos existente '$DbName'"
    $confirm = Read-Host "¿Está seguro de continuar? (escriba 'SÍ' para confirmar)"
    
    if ($confirm -ne 'SÍ') {
        Write-Info "Operación cancelada por el usuario"
        exit 0
    }
}

try {
    # Solicitar contraseña
    $env:PGPASSWORD = Read-Host "Ingrese la contraseña de PostgreSQL" -AsSecureString
    $env:PGPASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($env:PGPASSWORD)
    )
    
    # Si se debe eliminar la base de datos existente
    if ($DropExisting) {
        Write-Info "Eliminando base de datos existente..."
        
        # Desconectar usuarios activos
        $disconnectQuery = @"
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = '$DbName'
  AND pid <> pg_backend_pid();
"@
        
        & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -c $disconnectQuery 2>&1 | Out-Null
        
        # Eliminar base de datos
        & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -c "DROP DATABASE IF EXISTS $DbName;" 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Base de datos eliminada"
        }
    }
    
    Write-Info "Restaurando backup..."
    Write-Info ""
    
    # Ejecutar restauración
    & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -f $BackupFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Restauración completada exitosamente"
        
        # Verificar tablas restauradas
        Write-Info ""
        Write-Info "Verificando tablas restauradas..."
        $tablesQuery = "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
        $tables = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -t -c $tablesQuery
        
        Write-Success "Tablas restauradas:"
        $tables | ForEach-Object {
            if ($_.Trim()) {
                Write-Info "  • $($_.Trim())"
            }
        }
        
        Write-Info ""
        Write-Success "=== Restauración Finalizada ==="
        
    } else {
        Write-Error "Error durante la restauración (código de salida: $LASTEXITCODE)"
        exit 1
    }
    
} catch {
    Write-Error "Error durante la restauración: $_"
    exit 1
} finally {
    # Limpiar variable de contraseña
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
