"""FastAPI dependencies for authentication and authorization."""
from typing import List, Optional

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from database.database import get_db, User as DBUser
from security.jwt_manager import decode_access_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> DBUser:
    """Decode JWT and return the DB user. Raises 401 if invalid."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    sub = payload.get("sub")
    if sub is None:
        raise credentials_exception
    try:
        user_id = int(sub)
    except (ValueError, TypeError):
        raise credentials_exception

    user = db.query(DBUser).filter(DBUser.id == user_id).first()
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="User is inactive")
    if user.is_locked:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="User is locked")
    return user


def require_role(required_roles: List[str]):
    """Dependency factory: check that the user has at least one of the required roles."""
    async def role_checker(current_user: DBUser = Depends(get_current_user)):
        user_roles = {r.name.upper() for r in current_user.roles}
        if not user_roles.intersection({r.upper() for r in required_roles}):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions",
            )
        return current_user
    return role_checker


def require_permission(required_permission: str):
    """Dependency factory: check that the user has a specific permission."""
    async def permission_checker(current_user: DBUser = Depends(get_current_user)):
        user_permissions = set()
        for role in current_user.roles:
            for perm in role.permissions:
                user_permissions.add(perm.code)
        if required_permission not in user_permissions:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Missing permission: {required_permission}",
            )
        return current_user
    return permission_checker


def get_client_info(request: Request) -> dict:
    """Extract IP and user_agent from the request."""
    ip = request.client.host if request.client else None
    ua = request.headers.get("user-agent", "")[:500]
    return {"ip_address": ip, "user_agent": ua}
