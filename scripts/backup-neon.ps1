# =============================================================================
# Script: Backup Neon Database
# Description: Exports Neon PostgreSQL to a local SQL file using NEON_DATABASE_URL from .env
# Usage:
#   .\scripts\backup-neon.ps1
#   .\scripts\backup-neon.ps1 -OutputFile "backups\neon_backup_manual.sql"
#   .\scripts\backup-neon.ps1 -Compress
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$DatabaseUrl,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputFile,

    [Parameter(Mandatory = $false)]
    [switch]$Compress
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "postgres-helpers.ps1")

Write-Host "Backup Neon -> local file" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
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

$pgDumpPath = Resolve-PostgresTool -ToolName "pg_dump"
$psqlPath = Resolve-PostgresTool -ToolName "psql"

if (-not $pgDumpPath) {
    Write-Host "pg_dump not found. Install PostgreSQL client tools." -ForegroundColor Red
    Write-Host "Expected: C:\Program Files\PostgreSQL\*\bin\pg_dump.exe" -ForegroundColor Gray
    exit 1
}

$backupDir = if ($OutputPath) { $OutputPath } else { Get-BackupDirectory }
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if (-not $OutputFile) {
    $OutputFile = Join-Path $backupDir "neon_backup_${timestamp}.sql"
} elseif (-not [System.IO.Path]::IsPathRooted($OutputFile)) {
    $OutputFile = Join-Path (Get-ProjectRoot) $OutputFile
}

Write-Host "Configuration:" -ForegroundColor White
Write-Host "  Neon URL: $(Format-RedactedDbUrl $neonUrl)" -ForegroundColor Gray
Write-Host "  Output file: $OutputFile" -ForegroundColor Gray
Write-Host "  pg_dump: $pgDumpPath" -ForegroundColor Gray
Write-Host ""

Write-Host "Exporting Neon database..." -ForegroundColor Cyan

Set-PgPasswordFromUrl -DatabaseUrl $neonUrl
& $pgDumpPath $neonUrl --clean --if-exists --no-owner --no-acl -f $OutputFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Backup failed (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}

$fileSizeKb = [math]::Round((Get-Item $OutputFile).Length / 1KB, 2)
Write-Host "Backup created ($fileSizeKb KB)." -ForegroundColor Green

if ($Compress) {
    $zipFile = "$OutputFile.zip"
    Compress-Archive -Path $OutputFile -DestinationPath $zipFile -Force
    $zipSizeKb = [math]::Round((Get-Item $zipFile).Length / 1KB, 2)
    Write-Host "Compressed backup: $zipFile ($zipSizeKb KB)" -ForegroundColor Green
}

if ($psqlPath) {
    Write-Host ""
    Write-Host "Database summary:" -ForegroundColor Cyan

    try {
        $transactions = Invoke-NeonQuery -PsqlPath $psqlPath -DatabaseUrl $neonUrl -Query "SELECT COUNT(*) FROM transactions;"
        $users = Invoke-NeonQuery -PsqlPath $psqlPath -DatabaseUrl $neonUrl -Query "SELECT COUNT(*) FROM users;"
        $budgetItems = Invoke-NeonQuery -PsqlPath $psqlPath -DatabaseUrl $neonUrl -Query "SELECT COUNT(*) FROM budget_items;"

        Write-Host "  Transactions: $transactions" -ForegroundColor Gray
        Write-Host "  Users: $users" -ForegroundColor Gray
        Write-Host "  Budget items: $budgetItems" -ForegroundColor Gray
    } catch {
        Write-Host "  Could not read summary: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Restore with: .\scripts\import-local-to-neon.ps1 -BackupFile `"$OutputFile`"" -ForegroundColor Gray
