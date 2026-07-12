# =============================================================================
# Script: Import Local Backup to Neon
# Description: Imports a local SQL dump into Neon using NEON_DATABASE_URL from .env
# Usage:
#   .\scripts\import-local-to-neon.ps1
#   .\scripts\import-local-to-neon.ps1 -BackupFile "backups\local_backup.sql"
#   .\scripts\import-local-to-neon.ps1 -SkipNeonBackup -Force
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$BackupFile,

    [Parameter(Mandatory = $false)]
    [string]$DatabaseUrl,

    [Parameter(Mandatory = $false)]
    [switch]$SkipNeonBackup,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "postgres-helpers.ps1")

Write-Host "Import local backup -> Neon" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

$neonUrl = Get-NeonDatabaseUrl -OverrideUrl $DatabaseUrl
if (-not $neonUrl) {
    Write-Host "NEON_DATABASE_URL not found." -ForegroundColor Red
    Write-Host "Add it to .env in the project root or pass -DatabaseUrl." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-PostgresUrl $neonUrl)) {
    Write-Host "Invalid PostgreSQL URL format." -ForegroundColor Red
    exit 1
}

$psqlPath = Resolve-PostgresTool -ToolName "psql"
$pgDumpPath = Resolve-PostgresTool -ToolName "pg_dump"

if (-not $psqlPath) {
    Write-Host "psql not found. Install PostgreSQL client tools." -ForegroundColor Red
    Write-Host "Expected: C:\Program Files\PostgreSQL\*\bin\psql.exe" -ForegroundColor Gray
    exit 1
}

$backupDir = Get-BackupDirectory
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

try {
    $resolvedBackup = Resolve-LocalBackupFile -BackupFile $BackupFile -BackupDir $backupDir
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupSizeKb = [math]::Round((Get-Item $resolvedBackup).Length / 1KB, 2)

Write-Host "Configuration:" -ForegroundColor White
Write-Host "  Neon URL: $(Format-RedactedDbUrl $neonUrl)" -ForegroundColor Gray
Write-Host "  Backup file: $resolvedBackup" -ForegroundColor Gray
Write-Host "  Backup size: $backupSizeKb KB" -ForegroundColor Gray
Write-Host "  psql: $psqlPath" -ForegroundColor Gray
Write-Host ""

if (-not $SkipNeonBackup) {
    if (-not $pgDumpPath) {
        Write-Host "pg_dump not found. Skipping Neon backup (use -SkipNeonBackup to hide this warning)." -ForegroundColor Yellow
    } else {
        $neonBackupFile = Join-Path $backupDir "neon_backup_before_import_${timestamp}.sql"
        Write-Host "Creating Neon backup before import..." -ForegroundColor Cyan
        Write-Host "  Output: $neonBackupFile" -ForegroundColor Gray

        & $pgDumpPath $neonUrl --clean --if-exists --no-owner --no-acl -f $neonBackupFile
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Neon backup failed. Import cancelled." -ForegroundColor Red
            exit 1
        }

        $neonBackupSizeKb = [math]::Round((Get-Item $neonBackupFile).Length / 1KB, 2)
        Write-Host "Neon backup created ($neonBackupSizeKb KB)." -ForegroundColor Green
        Write-Host ""
    }
} else {
    Write-Host "Skipping Neon backup (-SkipNeonBackup)." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "WARNING: This will REPLACE all data in the Neon database." -ForegroundColor Yellow
Write-Host ""

if (-not $Force) {
    $confirmation = Read-Host "Continue? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Host "Import cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "Importing backup to Neon..." -ForegroundColor Cyan

Get-Content $resolvedBackup | & $psqlPath $neonUrl 2>&1 | Tee-Object -Variable importOutput | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Import failed (exit code $LASTEXITCODE)." -ForegroundColor Red
    if ($importOutput) {
        Write-Host ($importOutput | Select-Object -Last 20 | Out-String)
    }
    exit 1
}

Write-Host "Import completed." -ForegroundColor Green
Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan

try {
    $transactions = Invoke-NeonQuery -PsqlPath $psqlPath -DatabaseUrl $neonUrl -Query "SELECT COUNT(*) FROM transactions;"
    $users = Invoke-NeonQuery -PsqlPath $psqlPath -DatabaseUrl $neonUrl -Query "SELECT COUNT(*) FROM users;"
    $budgetItems = Invoke-NeonQuery -PsqlPath $psqlPath -DatabaseUrl $neonUrl -Query "SELECT COUNT(*) FROM budget_items;"

    Write-Host "  Transactions: $transactions" -ForegroundColor Gray
    Write-Host "  Users: $users" -ForegroundColor Gray
    Write-Host "  Budget items: $budgetItems" -ForegroundColor Gray
} catch {
    Write-Host "  Could not verify counts: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
