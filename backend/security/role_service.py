"""Role and permission management service."""
from datetime import datetime
from typing import Optional, List

from sqlalchemy.orm import Session

from database.database import Role as DBRole, Permission as DBPermission
from security import audit_service


def list_roles(db: Session) -> list:
    roles = db.query(DBRole).order_by(DBRole.id).all()
    return [_role_to_dict(r) for r in roles]


def get_role(db: Session, role_id: int) -> Optional[dict]:
    role = db.query(DBRole).filter(DBRole.id == role_id).first()
    return _role_to_dict(role) if role else None


def create_role(
    db: Session,
    *,
    name: str,
    description: Optional[str] = None,
    permission_ids: Optional[List[int]] = None,
    admin_user,
    ip_address=None,
    user_agent=None,
) -> dict:
    if db.query(DBRole).filter(DBRole.name == name).first():
        raise ValueError("Role already exists")

    role = DBRole(name=name, description=description)
    if permission_ids:
        permissions = db.query(DBPermission).filter(DBPermission.id.in_(permission_ids)).all()
        role.permissions = permissions

    db.add(role)
    db.commit()
    db.refresh(role)

    audit_service.log_event(db, "ROLE_CREATED", user_id=admin_user.id, username=admin_user.username,
                            entity="Role", entity_id=role.id, details=f"Created role {name}",
                            ip_address=ip_address, user_agent=user_agent)
    return _role_to_dict(role)


def update_role(
    db: Session,
    role_id: int,
    *,
    name: Optional[str] = None,
    description: Optional[str] = None,
    permission_ids: Optional[List[int]] = None,
    admin_user,
    ip_address=None,
    user_agent=None,
) -> dict:
    role = db.query(DBRole).filter(DBRole.id == role_id).first()
    if not role:
        raise ValueError("Role not found")

    if name is not None and name != role.name:
        if db.query(DBRole).filter(DBRole.name == name).first():
            raise ValueError("Role name already exists")
        role.name = name
    if description is not None:
        role.description = description
    if permission_ids is not None:
        permissions = db.query(DBPermission).filter(DBPermission.id.in_(permission_ids)).all()
        role.permissions = permissions

    role.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(role)

    audit_service.log_event(db, "ROLE_UPDATED", user_id=admin_user.id, username=admin_user.username,
                            entity="Role", entity_id=role.id, ip_address=ip_address, user_agent=user_agent)
    return _role_to_dict(role)


def delete_role(db: Session, role_id: int, admin_user, ip_address=None, user_agent=None):
    role = db.query(DBRole).filter(DBRole.id == role_id).first()
    if not role:
        raise ValueError("Role not found")
    if role.users:
        raise ValueError("Cannot delete role that is assigned to users")

    role_name = role.name
    db.delete(role)
    db.commit()

    audit_service.log_event(db, "ROLE_DELETED", user_id=admin_user.id, username=admin_user.username,
                            entity="Role", entity_id=role_id, details=f"Deleted role {role_name}",
                            ip_address=ip_address, user_agent=user_agent)


def list_permissions(db: Session) -> list:
    perms = db.query(DBPermission).order_by(DBPermission.module, DBPermission.code).all()
    return [_permission_to_dict(p) for p in perms]


def _role_to_dict(role: DBRole) -> dict:
    return {
        "id": role.id,
        "name": role.name,
        "description": role.description,
        "permissions": [_permission_to_dict(p) for p in role.permissions],
        "user_count": len(role.users) if role.users else 0,
        "created_at": role.created_at.isoformat() if role.created_at else None,
    }


def _permission_to_dict(perm: DBPermission) -> dict:
    return {
        "id": perm.id,
        "code": perm.code,
        "module": perm.module,
        "description": perm.description,
    }
