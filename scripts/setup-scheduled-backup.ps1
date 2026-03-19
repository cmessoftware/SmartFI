# Script para configurar Tarea Programada de Backup Automático
# Crea una tarea en Windows Task Scheduler que ejecuta backup diario

param(
    [string]$TaskName = "Finly Database Backup",
    [string]$BackupTime = "02:00",  # 2:00 AM
    [ValidateSet("Daily", "Weekly", "Monthly")]
    [string]$Frequency = "Daily",
    [string]$BackupPath = ".\backups",
    [string]$DbName = "finly_db",
    [string]$DbHost = "localhost",
    [string]$DbPort = "5432",
    [string]$DbUser = "postgres",
    [switch]$CompressBackups = $true,
    [int]$RetentionDays = 30  # Eliminar backups más antiguos de 30 días
)

# Colores para mensajes
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }

Write-Info "=== Configuración de Backup Automático Finly ==="
Write-Info ""

# Verificar privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Este script requiere privilegios de administrador"
    Write-Info "Ejecute PowerShell como Administrador y vuelva a intentar"
    exit 1
}

# Obtener rutas absolutas
$scriptRoot = Split-Path -Parent $PSScriptRoot
if (-not $scriptRoot) {
    $scriptRoot = (Get-Location).Path
}
$backupScriptPath = Join-Path $scriptRoot "scripts\backup-database.ps1"
$absoluteBackupPath = Join-Path $scriptRoot $BackupPath

# Verificar que el script de backup existe
if (-not (Test-Path $backupScriptPath)) {
    Write-Error "No se encontró el script de backup en: $backupScriptPath"
    exit 1
}

Write-Info "Configuración:"
Write-Info "  Tarea: $TaskName"
Write-Info "  Frecuencia: $Frequency"
Write-Info "  Hora: $BackupTime"
Write-Info "  Script: $backupScriptPath"
Write-Info "  Destino: $absoluteBackupPath"
Write-Info "  Retención: $RetentionDays días"
Write-Info "  Compresión: $($CompressBackups.ToString())"
Write-Info ""

# Solicitar contraseña de PostgreSQL para almacenar en .pgpass
Write-Info "Para automatizar backups sin intervención, se requiere configurar .pgpass"
$pgPassword = Read-Host "Ingrese la contraseña de PostgreSQL (usuario: $DbUser)" -AsSecureString
$pgPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pgPassword)
)

# Configurar .pgpass (almacenamiento seguro de contraseña)
$pgpassPath = Join-Path $env:APPDATA "postgresql\pgpass.conf"
$pgpassDir = Split-Path -Parent $pgpassPath

if (-not (Test-Path $pgpassDir)) {
    New-Item -ItemType Directory -Path $pgpassDir -Force | Out-Null
    Write-Success "Creado directorio .pgpass: $pgpassDir"
}

# Formato: hostname:port:database:username:password
$pgpassEntry = "${DbHost}:${DbPort}:${DbName}:${DbUser}:${pgPasswordPlain}"

# Verificar si ya existe la entrada
$existingContent = if (Test-Path $pgpassPath) { Get-Content $pgpassPath } else { @() }
$entryExists = $existingContent | Where-Object { $_ -like "${DbHost}:${DbPort}:${DbName}:${DbUser}:*" }

if ($entryExists) {
    # Reemplazar entrada existente
    $newContent = $existingContent | ForEach-Object {
        if ($_ -like "${DbHost}:${DbPort}:${DbName}:${DbUser}:*") {
            $pgpassEntry
        } else {
            $_
        }
    }
    $newContent | Set-Content $pgpassPath
    Write-Success "Actualizada credencial en .pgpass"
} else {
    # Agregar nueva entrada
    Add-Content -Path $pgpassPath -Value $pgpassEntry
    Write-Success "Credencial agregada a .pgpass"
}

# Limpiar contraseña de memoria
$pgPasswordPlain = $null

# Construir comando para la tarea programada
$compressionFlag = if ($CompressBackups) { "-CompressOutput" } else { "" }
$taskCommand = "powershell.exe"
$taskArguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command",
    "& '$backupScriptPath' -OutputPath '$absoluteBackupPath' -DbName '$DbName' -DbHost '$DbHost' -DbPort '$DbPort' -DbUser '$DbUser' $compressionFlag"
)

Write-Info ""
Write-Info "Creando tarea programada..."

try {
    # Verificar si la tarea ya existe
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    
    if ($existingTask) {
        Write-Warning "La tarea '$TaskName' ya existe"
        $overwrite = Read-Host "¿Desea sobrescribirla? (S/N)"
        if ($overwrite -ne 'S' -and $overwrite -ne 's') {
            Write-Info "Operación cancelada"
            exit 0
        }
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Info "Tarea existente eliminada"
    }
    
    # Crear acción (comando a ejecutar)
    $action = New-ScheduledTaskAction -Execute $taskCommand -Argument ($taskArguments -join ' ')
    
    # Crear trigger según frecuencia
    switch ($Frequency) {
        "Daily" {
            $trigger = New-ScheduledTaskTrigger -Daily -At $BackupTime
        }
        "Weekly" {
            # Domingos a las 2:00 AM
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At $BackupTime
        }
        "Monthly" {
            # Primera día de cada mes
            $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Sunday -At $BackupTime
        }
    }
    
    # Configuración adicional
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable:$false `
        -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    
    # Crear la tarea (ejecutar con la cuenta del sistema)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Backup automático de base de datos Finly PostgreSQL" | Out-Null
    
    Write-Success "Tarea programada creada exitosamente"
    
    # Mostrar información de la tarea
    $task = Get-ScheduledTask -TaskName $TaskName
    Write-Info ""
    Write-Info "Detalles de la tarea:"
    Write-Info "  Estado: $($task.State)"
    Write-Info "  Próxima ejecución: $((Get-ScheduledTaskInfo -TaskName $TaskName).NextRunTime)"
    
} catch {
    Write-Error "Error al crear tarea programada: $_"
    exit 1
}

# Script de limpieza de backups antiguos
$cleanupScriptPath = Join-Path $scriptRoot "scripts\cleanup-old-backups.ps1"
Write-Info ""
Write-Info "Creando script de limpieza de backups antiguos..."

$cleanupScript = @"
# Script de Limpieza de Backups Antiguos
# Elimina backups más antiguos de $RetentionDays días

`$backupPath = '$absoluteBackupPath'
`$retentionDays = $RetentionDays
`$cutoffDate = (Get-Date).AddDays(-`$retentionDays)

Write-Host "Limpiando backups anteriores a: `$(`$cutoffDate.ToString('yyyy-MM-dd'))"

`$oldBackups = Get-ChildItem -Path `$backupPath -Filter "finly_backup_*" | 
    Where-Object { `$_.LastWriteTime -lt `$cutoffDate }

if (`$oldBackups.Count -gt 0) {
    Write-Host "Eliminando `$(`$oldBackups.Count) archivo(s) antiguo(s)..."
    `$oldBackups | ForEach-Object {
        Write-Host "  • `$(`$_.Name)"
        Remove-Item `$_.FullName -Force
    }
    Write-Host "Limpieza completada"
} else {
    Write-Host "No hay backups antiguos para eliminar"
}
"@

$cleanupScript | Set-Content -Path $cleanupScriptPath
Write-Success "Script de limpieza creado: $cleanupScriptPath"

# Agregar tarea de limpieza mensual
$cleanupTaskName = "Finly Backup Cleanup"
$cleanupAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$cleanupScriptPath`""
$cleanupTrigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Saturday -At "01:00"
$cleanupSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

try {
    $existingCleanup = Get-ScheduledTask -TaskName $cleanupTaskName -ErrorAction SilentlyContinue
    if ($existingCleanup) {
        Unregister-ScheduledTask -TaskName $cleanupTaskName -Confirm:$false
    }
    
    Register-ScheduledTask `
        -TaskName $cleanupTaskName `
        -Action $cleanupAction `
        -Trigger $cleanupTrigger `
        -Settings $cleanupSettings `
        -User "SYSTEM" `
        -Description "Limpieza automática de backups antiguos de Finly" | Out-Null
    
    Write-Success "Tarea de limpieza automática configurada"
} catch {
    Write-Warning "No se pudo crear tarea de limpieza: $_"
}

Write-Info ""
Write-Success "=== Configuración Completada ==="
Write-Info ""
Write-Info "Tareas creadas:"
Write-Info "  1. $TaskName - Backup $Frequency a las $BackupTime"
Write-Info "  2. $cleanupTaskName - Limpieza mensual de backups antiguos"
Write-Info ""
Write-Info "Comandos útiles:"
Write-Info "  • Ver tarea: Get-ScheduledTask -TaskName '$TaskName'"
Write-Info "  • Ejecutar ahora: Start-ScheduledTask -TaskName '$TaskName'"
Write-Info "  • Ver historial: Get-ScheduledTaskInfo -TaskName '$TaskName'"
Write-Info "  • Deshabilitar: Disable-ScheduledTask -TaskName '$TaskName'"
Write-Info "  • Eliminar: Unregister-ScheduledTask -TaskName '$TaskName'"
Write-Info ""
Write-Info "Credenciales almacenadas en: $pgpassPath"
Write-Info "Backups se guardarán en: $absoluteBackupPath"
