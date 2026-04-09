"""User management service (admin operations)."""
from datetime import datetime
from typing import Optional, List

from sqlalchemy.orm import Session

from database.database import User as DBUser, Role as DBRole, RefreshToken
from security.jwt_manager import hash_password
from security import audit_service


def list_users(db: Session) -> list:
    users = db.query(DBUser).order_by(DBUser.id).all()
    return [_user_to_dict(u) for u in users]


def get_user(db: Session, user_id: int) -> Optional[dict]:
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    return _user_to_dict(user) if user else None


def create_user(
    db: Session,
    *,
    username: str,
    email: str,
    password: str,
    first_name: Optional[str] = None,
    last_name: Optional[str] = None,
    role_ids: Optional[List[int]] = None,
    is_active: bool = True,
    admin_user: DBUser,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> dict:
    if db.query(DBUser).filter(DBUser.username == username).first():
        raise ValueError("Username already exists")
    if db.query(DBUser).filter(DBUser.email == email).first():
        raise ValueError("Email already exists")

    from security.auth_service import _validate_password_strength
    _validate_password_strength(password)

    user = DBUser(
        username=username,
        email=email,
        hashed_password=hash_password(password),
        first_name=first_name,
        last_name=last_name,
        is_active=is_active,
    )

    if role_ids:
        roles = db.query(DBRole).filter(DBRole.id.in_(role_ids)).all()
        user.roles = roles

    db.add(user)
    db.commit()
    db.refresh(user)

    audit_service.log_event(db, "USER_CREATED", user_id=admin_user.id, username=admin_user.username,
                            entity="User", entity_id=user.id,
                            details=f"Created user {username}",
                            ip_address=ip_address, user_agent=user_agent)

    return _user_to_dict(user)


def update_user(
    db: Session,
    user_id: int,
    *,
    email: Optional[str] = None,
    first_name: Optional[str] = None,
    last_name: Optional[str] = None,
    is_active: Optional[bool] = None,
    role_ids: Optional[List[int]] = None,
    admin_user: DBUser,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> dict:
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if not user:
        raise ValueError("User not found")

    if email is not None and email != user.email:
        if db.query(DBUser).filter(DBUser.email == email, DBUser.id != user_id).first():
            raise ValueError("Email already exists")
        user.email = email

    if first_name is not None:
        user.first_name = first_name
    if last_name is not None:
        user.last_name = last_name
    if is_active is not None:
        user.is_active = is_active
        if not is_active:
            audit_service.log_event(db, "USER_DEACTIVATED", user_id=admin_user.id, username=admin_user.username,
                                    entity="User", entity_id=user.id, ip_address=ip_address, user_agent=user_agent)

    if role_ids is not None:
        roles = db.query(DBRole).filter(DBRole.id.in_(role_ids)).all()
        user.roles = roles

    user.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(user)

    audit_service.log_event(db, "USER_UPDATED", user_id=admin_user.id, username=admin_user.username,
                            entity="User", entity_id=user.id, ip_address=ip_address, user_agent=user_agent)

    return _user_to_dict(user)


def activate_user(db: Session, user_id: int, admin_user: DBUser, ip_address=None, user_agent=None):
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if not user:
        raise ValueError("User not found")
    user.is_active = True
    user.updated_at = datetime.utcnow()
    db.commit()
    audit_service.log_event(db, "USER_ACTIVATED", user_id=admin_user.id, username=admin_user.username,
                            entity="User", entity_id=user.id, ip_address=ip_address, user_agent=user_agent)


def deactivate_user(db: Session, user_id: int, admin_user: DBUser, ip_address=None, user_agent=None):
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if not user:
        raise ValueError("User not found")
    user.is_active = False
    user.updated_at = datetime.utcnow()
    db.commit()
    audit_service.log_event(db, "USER_DEACTIVATED", user_id=admin_user.id, username=admin_user.username,
                            entity="User", entity_id=user.id, ip_address=ip_address, user_agent=user_agent)


def unlock_user(db: Session, user_id: int, admin_user: DBUser, ip_address=None, user_agent=None):
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if not user:
        raise ValueError("User not found")
    user.is_locked = False
    user.failed_login_attempts = 0
    user.updated_at = datetime.utcnow()
    db.commit()
    audit_service.log_event(db, "USER_UNLOCKED", user_id=admin_user.id, username=admin_user.username,
                            entity="User", entity_id=user.id, ip_address=ip_address, user_agent=user_agent)


def reset_password(
    db: Session,
    user_id: int,
    new_password: str,
    admin_user: DBUser,
    ip_address=None,
    user_agent=None,
):
    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if not user:
        raise ValueError("User not found")

    from security.auth_service import _validate_password_strength
    _validate_password_strength(new_password)

    user.hashed_password = hash_password(new_password)
    user.force_password_change = True
    user.password_changed_at = datetime.utcnow()
    user.updated_at = datetime.utcnow()
    db.commit()

    # Revoke all refresh tokens
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user.id,
        RefreshToken.revoked_at.is_(None),
    ).update({"revoked_at": datetime.utcnow()})
    db.commit()

    audit_service.log_event(db, "PASSWORD_RESET", user_id=admin_user.id, username=admin_user.username,
                            entity="User", entity_id=user.id, ip_address=ip_address, user_agent=user_agent)


def _user_to_dict(user: DBUser) -> dict:
    return {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "is_active": user.is_active,
        "is_locked": user.is_locked,
        "roles": [{"id": r.id, "name": r.name} for r in user.roles],
        "last_login_at": user.last_login_at.isoformat() if user.last_login_at else None,
        "created_at": user.created_at.isoformat() if user.created_at else None,
    }
