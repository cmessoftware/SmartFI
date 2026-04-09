"""Audit logging service."""
from typing import Optional
from sqlalchemy.orm import Session
from database.database import AuditLog


def log_event(
    db: Session,
    action: str,
    *,
    user_id: Optional[int] = None,
    username: Optional[str] = None,
    entity: Optional[str] = None,
    entity_id: Optional[int] = None,
    details: Optional[str] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
):
    entry = AuditLog(
        user_id=user_id,
        username=username,
        action=action,
        entity=entity,
        entity_id=entity_id,
        details=details,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    db.add(entry)
    db.commit()
