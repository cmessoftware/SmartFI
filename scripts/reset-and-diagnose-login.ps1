$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Write-Host "1) Killing local backend conflicts (python main.py)..." -ForegroundColor Cyan
Get-CimInstance Win32_Process | Where-Object {
  $_.Name -eq "python.exe" -and $_.CommandLine -match "main.py"
} | ForEach-Object {
  try {
    Stop-Process -Id $_.ProcessId -Force
    Write-Host ("  killed PID " + $_.ProcessId) -ForegroundColor Yellow
  } catch {
    Write-Host ("  could not kill PID " + $_.ProcessId + ": " + $_.Exception.Message) -ForegroundColor DarkYellow
  }
}

Write-Host "2) Checking Docker daemon..." -ForegroundColor Cyan
docker version | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Docker daemon is not responding. Restart Docker Desktop and run this script again." -ForegroundColor Red
  exit 1
}
Write-Host "  docker=OK" -ForegroundColor Green

Write-Host "3) Resetting SmartFI stack..." -ForegroundColor Cyan
docker compose down
docker compose up -d --build backend frontend postgres

Write-Host "4) Container status..." -ForegroundColor Cyan
docker compose ps

Write-Host "5) Backend health check..." -ForegroundColor Cyan
try {
  $healthResponse = Invoke-WebRequest -Uri http://localhost:8000/api/health -UseBasicParsing -TimeoutSec 12
  Write-Host ("  health=" + $healthResponse.StatusCode) -ForegroundColor Green
} catch {
  Write-Host ("  health_error=" + $_.Exception.Message) -ForegroundColor Red
}

Write-Host "6) API login check..." -ForegroundColor Cyan
try {
  $loginResponse = Invoke-RestMethod -Uri http://localhost:8000/api/auth/login -Method POST -Body @{username='admin';password='admin123'} -TimeoutSec 12
  if ($loginResponse.access_token) {
    Write-Host ("  login=OK token_len=" + $loginResponse.access_token.Length) -ForegroundColor Green
  } else {
    Write-Host "  login=NO_TOKEN" -ForegroundColor Yellow
  }
} catch {
  Write-Host ("  login_error=" + $_.Exception.Message) -ForegroundColor Red
}

Write-Host "Done." -ForegroundColor Cyan
