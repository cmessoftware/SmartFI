# =============================================================================
# Script: Migrate Database from Local to Render
# Description: Exports local PostgreSQL data and imports to Render database
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$RenderDatabaseUrl,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBackup
)

Write-Host "🚀 Finly Database Migration: Local → Render" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$LocalHost = "localhost"
$LocalPort = "5433"
$LocalDatabase = "fin_per_db"
$LocalUser = "admin"
$LocalPassword = "admin123"
$BackupDir = Join-Path $PSScriptRoot "..\backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = Join-Path $BackupDir "local_backup_${Timestamp}.sql"

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Host "✅ Created backup directory: $BackupDir" -ForegroundColor Green
}

# Check if Render Database URL is provided
if (-not $RenderDatabaseUrl) {
    Write-Host "⚠️  Render Database URL not provided." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please provide the Render PostgreSQL connection URL:" -ForegroundColor Yellow
    Write-Host "Example: postgresql://user:password@host:port/database" -ForegroundColor Gray
    Write-Host ""
    $RenderDatabaseUrl = Read-Host "Enter Render Database URL"
    
    if (-not $RenderDatabaseUrl) {
        Write-Host "❌ Database URL is required. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Validate Render URL format
if ($RenderDatabaseUrl -notmatch "^postgres(ql)?://") {
    Write-Host "❌ Invalid PostgreSQL URL format" -ForegroundColor Red
    Write-Host "Expected format: postgresql://user:password@host:port/database" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Migration Configuration:" -ForegroundColor White
Write-Host "   Local: ${LocalHost}:${LocalPort}/${LocalDatabase}" -ForegroundColor Gray
Write-Host "   Render URL: $($RenderDatabaseUrl -replace '://.*:.*@', '://***:***@')" -ForegroundColor Gray
Write-Host "   Backup File: $BackupFile" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Step 1: Check if Docker is running (for local database)
Write-Host "🔍 Step 1: Checking local database..." -ForegroundColor Cyan
try {
    $dockerStatus = docker ps --filter "name=finly-postgres" --format "{{.Status}}" 2>&1
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($dockerStatus)) {
        Write-Host "❌ Local PostgreSQL container is not running" -ForegroundColor Red
        Write-Host "   Please start it with: docker-compose up -d postgres" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Local PostgreSQL is running" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Unable to check Docker status: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Export local database
Write-Host "📦 Step 2: Exporting local database..." -ForegroundColor Cyan
$env:PGPASSWORD = $LocalPassword

if ($DryRun) {
    Write-Host "   [DRY RUN] Would export to: $BackupFile" -ForegroundColor Yellow
} else {
    try {
        # Export using docker exec
        $exportCmd = "docker exec -e PGPASSWORD=$LocalPassword finly-postgres pg_dump -h localhost -p 5432 -U $LocalUser -d $LocalDatabase --clean --if-exists --no-owner --no-acl"
        
        $output = Invoke-Expression $exportCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $output | Out-File -FilePath $BackupFile -Encoding UTF8
            $fileSize = (Get-Item $BackupFile).Length / 1KB
            Write-Host "✅ Database exported successfully" -ForegroundColor Green
            Write-Host "   File: $BackupFile" -ForegroundColor Gray
            Write-Host "   Size: $([math]::Round($fileSize, 2)) KB" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Host "❌ Export failed" -ForegroundColor Red
            Write-Host $output
            exit 1
        }
    } catch {
        Write-Host "❌ Export error: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Show data summary
if (-not $DryRun) {
    Write-Host "📊 Step 3: Database Summary..." -ForegroundColor Cyan
    try {
        $transactionsCount = docker exec -e PGPASSWORD=$LocalPassword finly-postgres psql -h localhost -p 5432 -U $LocalUser -d $LocalDatabase -t -c "SELECT COUNT(*) FROM transactions;" 2>&1
        $debtsCount = docker exec -e PGPASSWORD=$LocalPassword finly-postgres psql -h localhost -p 5432 -U $LocalUser -d $LocalDatabase -t -c "SELECT COUNT(*) FROM debts;" 2>&1
        $categoriesCount = docker exec -e PGPASSWORD=$LocalPassword finly-postgres psql -h localhost -p 5432 -U $LocalUser -d $LocalDatabase -t -c "SELECT COUNT(*) FROM categories;" 2>&1
        $usersCount = docker exec -e PGPASSWORD=$LocalPassword finly-postgres psql -h localhost -p 5432 -U $LocalUser -d $LocalDatabase -t -c "SELECT COUNT(*) FROM users;" 2>&1
        
        Write-Host "   Transactions: $($transactionsCount.Trim())" -ForegroundColor Gray
        Write-Host "   Budget Items: $($debtsCount.Trim())" -ForegroundColor Gray
        Write-Host "   Categories: $($categoriesCount.Trim())" -ForegroundColor Gray
        Write-Host "   Users: $($usersCount.Trim())" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "⚠️  Could not retrieve data summary" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Step 4: Backup Render database (optional)
if (-not $SkipBackup) {
    Write-Host "💾 Step 4: Creating backup of Render database (recommended)..." -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "   [DRY RUN] Would create backup of Render database" -ForegroundColor Yellow
        Write-Host ""
    } else {
        $renderBackupFile = Join-Path $BackupDir "render_backup_before_migration_${Timestamp}.sql"
        Write-Host "   Backing up Render database..." -ForegroundColor Gray
        
        try {
            # Check if pg_dump is available locally
            $pgDumpAvailable = Get-Command pg_dump -ErrorAction SilentlyContinue
            
            if ($pgDumpAvailable) {
                pg_dump "$RenderDatabaseUrl" --clean --if-exists --no-owner --no-acl > $renderBackupFile
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Render backup created: $renderBackupFile" -ForegroundColor Green
                } else {
                    Write-Host "⚠️  Could not backup Render database (non-critical)" -ForegroundColor Yellow
                }
            } else {
                Write-Host "⚠️  pg_dump not found locally. Skipping Render backup." -ForegroundColor Yellow
                Write-Host "   Install PostgreSQL client tools to enable this feature." -ForegroundColor Gray
            }
            Write-Host ""
        } catch {
            Write-Host "⚠️  Could not backup Render database: $_" -ForegroundColor Yellow
            Write-Host ""
        }
    }
} else {
    Write-Host "⏭️  Step 4: Skipping Render backup (--SkipBackup flag)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 5: Import to Render
Write-Host "📥 Step 5: Importing to Render database..." -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "   [DRY RUN] Would import $BackupFile to Render" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "✅ DRY RUN COMPLETED - No changes were made" -ForegroundColor Green
    exit 0
}

Write-Host "⚠️  WARNING: This will REPLACE all data in the Render database!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Continue? (yes/no): " -NoNewline -ForegroundColor Yellow
$confirmation = Read-Host

if ($confirmation -ne "yes") {
    Write-Host "❌ Migration cancelled by user" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "   Importing to Render..." -ForegroundColor Gray

try {
    # Check if psql is available
    $psqlAvailable = Get-Command psql -ErrorAction SilentlyContinue
    
    if (-not $psqlAvailable) {
        Write-Host "❌ psql command not found" -ForegroundColor Red
        Write-Host "   Please install PostgreSQL client tools" -ForegroundColor Yellow
        Write-Host "   Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Gray
        exit 1
    }
    
    # Import the backup file to Render
    Get-Content $BackupFile | psql "$RenderDatabaseUrl" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database imported successfully to Render!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "❌ Import failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Check the backup file and Render credentials" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Import error: $_" -ForegroundColor Red
    exit 1
}

# Step 6: Verify migration
Write-Host "🔍 Step 6: Verifying migration..." -ForegroundColor Cyan
try {
    $verifyQuery = "SELECT COUNT(*) FROM transactions;"
    $renderCount = psql "$RenderDatabaseUrl" -t -c "$verifyQuery" 2>&1
    
    if ($renderCount -match "\d+") {
        Write-Host "✅ Verification successful" -ForegroundColor Green
        Write-Host "   Transactions in Render: $($renderCount.Trim())" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "⚠️  Could not verify migration" -ForegroundColor Yellow
        Write-Host ""
    }
} catch {
    Write-Host "⚠️  Verification failed: $_" -ForegroundColor Yellow
    Write-Host ""
}

# Summary
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "✅ MIGRATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Backup files saved in: $BackupDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Test your Render deployment" -ForegroundColor Gray
Write-Host "2. Verify all data is correct" -ForegroundColor Gray
Write-Host "3. Update your .env files if needed" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  Keep the backup files for recovery if needed!" -ForegroundColor Yellow
