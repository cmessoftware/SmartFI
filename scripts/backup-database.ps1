# Script de Backup de Base de Datos Finly
# Genera un archivo SQL dump para migrar a otra base de datos PostgreSQL

param(
    [string]$OutputPath = ".\backups",
    [string]$DbName = "finly_db",
    [string]$DbHost = "localhost",
    [string]$DbPort = "5432",
    [string]$DbUser = "postgres",
    [switch]$IncludeData = $true,
    [switch]$CompressOutput = $false
)

# Colores para mensajes
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }

# Verificar que pg_dump esté instalado
$pgDumpPath = Get-Command pg_dump -ErrorAction SilentlyContinue

if (-not $pgDumpPath) {
    Write-Error "pg_dump no está instalado o no está en el PATH"
    Write-Info "Instale PostgreSQL client tools o agregue pg_dump al PATH"
    exit 1
}

# Crear directorio de backups si no existe
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Info "Creado directorio de backups: $OutputPath"
}

# Generar nombre de archivo con timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $OutputPath "finly_backup_$timestamp.sql"

Write-Info "=== Backup de Base de Datos Finly ==="
Write-Info "Base de datos: $DbName"
Write-Info "Host: ${DbHost}:${DbPort}"
Write-Info "Usuario: $DbUser"
Write-Info "Archivo de salida: $backupFile"
Write-Info ""

# Construir comando pg_dump
$pgDumpArgs = @(
    "-h", $DbHost,
    "-p", $DbPort,
    "-U", $DbUser,
    "-d", $DbName,
    "-f", $backupFile,
    "--clean",              # Incluir comandos DROP antes de CREATE
    "--if-exists",          # Usar IF EXISTS en comandos DROP
    "--create",             # Incluir comando CREATE DATABASE
    "--encoding=UTF8",      # Especificar encoding
    "--verbose"             # Modo verbose
)

if ($IncludeData) {
    Write-Info "Modo: Schema + Datos"
} else {
    $pgDumpArgs += "--schema-only"
    Write-Info "Modo: Solo Schema (sin datos)"
}

Write-Info "Ejecutando backup..."
Write-Info ""

try {
    # Ejecutar pg_dump
    $env:PGPASSWORD = Read-Host "Ingrese la contraseña de PostgreSQL" -AsSecureString
    $env:PGPASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($env:PGPASSWORD)
    )
    
    & pg_dump @pgDumpArgs 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Backup completado exitosamente"
        
        # Obtener tamaño del archivo
        $fileSize = (Get-Item $backupFile).Length / 1KB
        Write-Info "Tamaño del archivo: $([math]::Round($fileSize, 2)) KB"
        
        # Comprimir si se solicitó
        if ($CompressOutput) {
            Write-Info "Comprimiendo backup..."
            $zipFile = "$backupFile.zip"
            Compress-Archive -Path $backupFile -DestinationPath $zipFile -Force
            Remove-Item $backupFile
            
            $zipSize = (Get-Item $zipFile).Length / 1KB
            Write-Success "Backup comprimido: $zipFile"
            Write-Info "Tamaño comprimido: $([math]::Round($zipSize, 2)) KB"
        }
        
        Write-Info ""
        Write-Success "=== Backup Finalizado ==="
        Write-Info "Para restaurar este backup en otra base de datos, ejecute:"
        Write-Info "  psql -h <host> -U <usuario> -f $backupFile"
        
    } else {
        Write-Error "Error al ejecutar pg_dump (código de salida: $LASTEXITCODE)"
        exit 1
    }
    
} catch {
    Write-Error "Error durante el backup: $_"
    exit 1
} finally {
    # Limpiar variable de contraseña
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Info ""
Write-Info "Archivos de backup en: $OutputPath"
Get-ChildItem $OutputPath -Filter "finly_backup_*.sql*" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 5 |
    Format-Table Name, @{Label="Tamaño (KB)"; Expression={[math]::Round($_.Length/1KB, 2)}}, LastWriteTime -AutoSize
