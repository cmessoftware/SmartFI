param(
  [Parameter(Mandatory = $true)]
  [string]$TargetUsername,

  [Parameter(Mandatory = $true)]
  [string]$NewPassword,

  [Parameter(Mandatory = $false)]
  [string]$AdminUsername = "admin",

  [Parameter(Mandatory = $false)]
  [string]$AdminPassword = "admin123",

  [Parameter(Mandatory = $false)]
  [string]$ApiBaseUrl = "http://localhost:8000",

  [Parameter(Mandatory = $false)]
  [switch]$Unlock,

  [Parameter(Mandatory = $false)]
  [switch]$VerifyLogin
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "Resetting password for user '$TargetUsername'..." -ForegroundColor Cyan

function Fail([string]$Message) {
  Write-Host $Message -ForegroundColor Red
  exit 1
}

try {
  $adminLogin = Invoke-RestMethod \
    -Method POST \
    -Uri "$ApiBaseUrl/api/auth/login" \
    -Body @{ username = $AdminUsername; password = $AdminPassword } \
    -TimeoutSec 20
} catch {
  Fail "Admin login failed at $ApiBaseUrl/api/auth/login. Details: $($_.Exception.Message)"
}

if (-not $adminLogin.access_token) {
  Fail "Admin login did not return an access token."
}

$adminHeaders = @{ Authorization = "Bearer $($adminLogin.access_token)" }

try {
  $users = Invoke-RestMethod \
    -Method GET \
    -Uri "$ApiBaseUrl/api/admin/users" \
    -Headers $adminHeaders \
    -TimeoutSec 20
} catch {
  Fail "Could not fetch users from $ApiBaseUrl/api/admin/users. Details: $($_.Exception.Message)"
}

$targetUser = $users | Where-Object { $_.username -eq $TargetUsername } | Select-Object -First 1
if (-not $targetUser) {
  Fail "User '$TargetUsername' was not found."
}

$targetUserId = [int]$targetUser.id

if ($Unlock.IsPresent) {
  try {
    Invoke-RestMethod \
      -Method PATCH \
      -Uri "$ApiBaseUrl/api/admin/users/$targetUserId/unlock" \
      -Headers $adminHeaders \
      -TimeoutSec 20 | Out-Null
    Write-Host "User unlocked." -ForegroundColor Yellow
  } catch {
    Write-Host "Unlock failed (continuing with password reset): $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
}

$resetHeaders = @{
  Authorization = "Bearer $($adminLogin.access_token)"
  "Content-Type" = "application/json"
}

$resetBody = @{ new_password = $NewPassword } | ConvertTo-Json -Compress

try {
  Invoke-RestMethod \
    -Method POST \
    -Uri "$ApiBaseUrl/api/admin/users/$targetUserId/reset-password" \
    -Headers $resetHeaders \
    -Body $resetBody \
    -TimeoutSec 20 | Out-Null
} catch {
  Fail "Password reset failed for user '$TargetUsername'. Details: $($_.Exception.Message)"
}

Write-Host "Password reset completed for '$TargetUsername' (id=$targetUserId)." -ForegroundColor Green

if ($VerifyLogin.IsPresent) {
  try {
    $verify = Invoke-RestMethod \
      -Method POST \
      -Uri "$ApiBaseUrl/api/auth/login" \
      -Body @{ username = $TargetUsername; password = $NewPassword } \
      -TimeoutSec 20

    if ($verify.access_token) {
      Write-Host "Verification login: OK" -ForegroundColor Green
    } else {
      Write-Host "Verification login: no token returned" -ForegroundColor DarkYellow
    }
  } catch {
    Write-Host "Verification login failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
    exit 2
  }
}
