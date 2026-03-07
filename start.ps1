# Finly Startup Script
# This script starts both the backend and frontend services

Write-Host "🚀 Starting Finly Application..." -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if Node.js is installed
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if conda environment exists
$condaAvailable = $false
$useCondaEnv = $false
$useVenv = $false

if (Get-Command conda -ErrorAction SilentlyContinue) {
    $envExists = conda env list | Select-String -Pattern "finly"
    if ($envExists) {
        Write-Host "✅ Using conda environment 'finly'" -ForegroundColor Green
        $useCondaEnv = $true
    }
}

# Check if venv exists
if (!$useCondaEnv -and (Test-Path "backend/venv")) {
    Write-Host "✅ Using Python virtual environment" -ForegroundColor Green
    $useVenv = $true
}

# Start Backend
Write-Host "📦 Starting Backend (FastAPI)..." -ForegroundColor Green

if ($useCondaEnv) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; Write-Host '🔧 Backend Server Starting (conda: finly)...' -ForegroundColor Yellow; conda run -n finly python main.py"
} elseif ($useVenv) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; Write-Host '🔧 Backend Server Starting (venv)...' -ForegroundColor Yellow; .\venv\Scripts\Activate.ps1; python main.py"
} else {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; Write-Host '🔧 Backend Server Starting...' -ForegroundColor Yellow; python main.py"
}

# Wait a bit for backend to start
Start-Sleep -Seconds 3

# Start Frontend
Write-Host "🎨 Starting Frontend (React + Vite)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd frontend; Write-Host '⚛️  Frontend Server Starting...' -ForegroundColor Yellow; npm run dev"

Write-Host ""
Write-Host "✅ Both services are starting..." -ForegroundColor Green

if ($useCondaEnv) {
    Write-Host "   (Backend using conda environment 'finly')" -ForegroundColor Cyan
} elseif ($useVenv) {
    Write-Host "   (Backend using Python virtual environment)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "📍 Backend API: http://localhost:8000" -ForegroundColor Cyan
Write-Host "📍 Frontend App: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Default Login Credentials:" -ForegroundColor Yellow
Write-Host "   Admin:  admin / admin123" -ForegroundColor White
Write-Host "   Writer: writer / writer123" -ForegroundColor White
Write-Host "   Reader: reader / reader123" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit this window (services will continue running)..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
