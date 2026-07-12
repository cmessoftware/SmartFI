param(
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $false)]
    [SecureString]$NewPassword,

    [Parameter(Mandatory = $false)]
    [string]$BackendPath = "backend",

    [Parameter(Mandatory = $false)]
    [switch]$NoUnlock,

    [Parameter(Mandatory = $false)]
    [switch]$NoForcePasswordChange
)

$ErrorActionPreference = "Stop"

if (-not $NewPassword) {
    $NewPassword = Read-Host "Nueva clave" -AsSecureString
}

$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword)
try {
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

$unlock = if ($NoUnlock) { "false" } else { "true" }
$forcePasswordChange = if ($NoForcePasswordChange) { "false" } else { "true" }

$resolvedBackendPath = Resolve-Path $BackendPath

$env:RESET_USERNAME = $Username
$env:RESET_PASSWORD = $plainPassword
$env:RESET_UNLOCK = $unlock
$env:RESET_FORCE_PASSWORD_CHANGE = $forcePasswordChange

Push-Location $resolvedBackendPath
try {
    python -c @'
import os
import sys
from datetime import datetime

from database.database import SessionLocal, User as DBUser, RefreshToken
from security.jwt_manager import hash_password
from security.auth_service import _validate_password_strength

username = os.environ["RESET_USERNAME"]
new_password = os.environ["RESET_PASSWORD"]
unlock = os.environ.get("RESET_UNLOCK", "true").lower() == "true"
force_change = os.environ.get("RESET_FORCE_PASSWORD_CHANGE", "true").lower() == "true"

session = SessionLocal()
try:
    user = session.query(DBUser).filter(
        (DBUser.username == username) | (DBUser.email == username)
    ).first()

    if not user:
        print(f"ERROR: Usuario no encontrado: {username}")
        sys.exit(2)

    _validate_password_strength(new_password)

    user.hashed_password = hash_password(new_password)
    user.password_changed_at = datetime.utcnow()
    user.updated_at = datetime.utcnow()
    user.force_password_change = force_change

    if unlock:
        user.is_locked = False
        user.failed_login_attempts = 0

    session.query(RefreshToken).filter(
        RefreshToken.user_id == user.id,
        RefreshToken.revoked_at.is_(None),
    ).update({"revoked_at": datetime.utcnow()})

    session.commit()

    print("OK: Password reseteada")
    print(f"User: {user.username} (id={user.id})")
    print(f"Unlocked: {unlock}")
    print(f"force_password_change: {force_change}")
except Exception as exc:
    session.rollback()
    print(f"ERROR: {exc}")
    sys.exit(1)
finally:
    session.close()
'@

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location

    Remove-Item Env:RESET_USERNAME -ErrorAction SilentlyContinue
    Remove-Item Env:RESET_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:RESET_UNLOCK -ErrorAction SilentlyContinue
    Remove-Item Env:RESET_FORCE_PASSWORD_CHANGE -ErrorAction SilentlyContinue

    $plainPassword = $null
}
