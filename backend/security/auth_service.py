"""Authentication service — login, refresh, logout, password management."""
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy.orm import Session

from database.database import User as DBUser, RefreshToken
from security.jwt_manager import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    verify_refresh_token,
    REFRESH_TOKEN_EXPIRE_DAYS,
)
from security import audit_service

MAX_FAILED_ATTEMPTS = 5


def authenticate(
    db: Session,
    username_or_email: str,
    password: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> dict:
    """Validate credentials and return tokens + user payload.
    Returns dict with access_token, refresh_token, user info.
    Raises ValueError with specific message on failure."""

    user = (
        db.query(DBUser)
        .filter((DBUser.username == username_or_email) | (DBUser.email == username_or_email))
        .first()
    )

    if not user:
        raise ValueError("Incorrect username or password")

    if not user.is_active:
        audit_service.log_event(db, "LOGIN_FAIL", user_id=user.id, username=user.username,
                                details="User inactive", ip_address=ip_address, user_agent=user_agent)
        raise ValueError("User is inactive")

    if user.is_locked:
        audit_service.log_event(db, "LOGIN_FAIL", user_id=user.id, username=user.username,
                                details="User locked", ip_address=ip_address, user_agent=user_agent)
        raise ValueError("User is locked. Contact an administrator")

    if not verify_password(password, user.hashed_password):
        user.failed_login_attempts += 1
        if user.failed_login_attempts >= MAX_FAILED_ATTEMPTS:
            user.is_locked = True
        db.commit()
        audit_service.log_event(db, "LOGIN_FAIL", user_id=user.id, username=user.username,
                                details=f"Bad password (attempt {user.failed_login_attempts})",
                                ip_address=ip_address, user_agent=user_agent)
        raise ValueError("Incorrect username or password")

    # Success — reset failed attempts
    user.failed_login_attempts = 0
    user.last_login_at = datetime.utcnow()
    db.commit()

    roles = [r.name for r in user.roles]
    permissions = list({p.code for r in user.roles for p in r.permissions})

    access_token = create_access_token({
        "sub": str(user.id),
        "username": user.username,
        "roles": roles,
        "permissions": permissions,
    })

    raw_refresh, refresh_hash = create_refresh_token()
    rt = RefreshToken(
        user_id=user.id,
        token_hash=refresh_hash,
        expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS),
        ip_address=ip_address,
        user_agent=user_agent,
    )
    db.add(rt)
    db.commit()

    audit_service.log_event(db, "LOGIN_SUCCESS", user_id=user.id, username=user.username,
                            ip_address=ip_address, user_agent=user_agent)

    return {
        "access_token": access_token,
        "refresh_token": raw_refresh,
        "token_type": "bearer",
        "expires_in": 1800,
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "roles": roles,
            "permissions": permissions,
            "force_password_change": user.force_password_change,
        },
    }


def refresh_access_token(db: Session, raw_refresh: str) -> dict:
    """Validate a refresh token and issue a new access token."""
    tokens = (
        db.query(RefreshToken)
        .filter(RefreshToken.revoked_at.is_(None), RefreshToken.expires_at > datetime.utcnow())
        .all()
    )
    matched_rt = None
    for rt in tokens:
        if verify_refresh_token(raw_refresh, rt.token_hash):
            matched_rt = rt
            break

    if matched_rt is None:
        raise ValueError("Invalid or expired refresh token")

    user = db.query(DBUser).filter(DBUser.id == matched_rt.user_id).first()
    if not user or not user.is_active or user.is_locked:
        raise ValueError("User unavailable")

    roles = [r.name for r in user.roles]
    permissions = list({p.code for r in user.roles for p in r.permissions})

    access_token = create_access_token({
        "sub": str(user.id),
        "username": user.username,
        "roles": roles,
        "permissions": permissions,
    })
    return {"access_token": access_token, "token_type": "bearer", "expires_in": 1800}


def logout(db: Session, user_id: int, ip_address: Optional[str] = None, user_agent: Optional[str] = None):
    """Revoke all refresh tokens for a user."""
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.revoked_at.is_(None),
    ).update({"revoked_at": datetime.utcnow()})
    db.commit()
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if user:
        audit_service.log_event(db, "LOGOUT", user_id=user.id, username=user.username,
                                ip_address=ip_address, user_agent=user_agent)


def change_password(
    db: Session,
    user: DBUser,
    current_password: str,
    new_password: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
):
    """Change the user's own password."""
    if not verify_password(current_password, user.hashed_password):
        raise ValueError("Current password is incorrect")
    if current_password == new_password:
        raise ValueError("New password must be different from current")
    _validate_password_strength(new_password)

    user.hashed_password = hash_password(new_password)
    user.password_changed_at = datetime.utcnow()
    user.force_password_change = False
    db.commit()

    # Revoke all refresh tokens (force re-login)
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user.id,
        RefreshToken.revoked_at.is_(None),
    ).update({"revoked_at": datetime.utcnow()})
    db.commit()

    audit_service.log_event(db, "PASSWORD_CHANGED", user_id=user.id, username=user.username,
                            ip_address=ip_address, user_agent=user_agent)


def _validate_password_strength(password: str):
    if len(password) < 8:
        raise ValueError("Password must be at least 8 characters")
    if not any(c.isupper() for c in password):
        raise ValueError("Password must contain at least one uppercase letter")
    if not any(c.isdigit() for c in password):
        raise ValueError("Password must contain at least one digit")
    if not any(c in "!@#$%^&*()_+-=[]{}|;':\",./<>?" for c in password):
        raise ValueError("Password must contain at least one special character")
