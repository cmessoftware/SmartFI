"""Auth API router — login, refresh, logout, change-password, me."""
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional

from sqlalchemy.orm import Session

from database.database import get_db, User as DBUser
from security.auth_dependencies import get_current_user, get_client_info
from security import auth_service

router = APIRouter(prefix="/api/auth", tags=["auth"])


# ── Pydantic schemas ──────────────────────────────────────────

class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

class RefreshRequest(BaseModel):
    refresh_token: str


# ── Endpoints ─────────────────────────────────────────────────

@router.post("/login")
async def login(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        result = auth_service.authenticate(
            db,
            form_data.username,
            form_data.password,
            ip_address=client["ip_address"],
            user_agent=client["user_agent"],
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        )
    return result


@router.post("/refresh")
async def refresh_token(body: RefreshRequest, db: Session = Depends(get_db)):
    try:
        return auth_service.refresh_access_token(db, body.refresh_token)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@router.post("/logout")
async def logout(
    request: Request,
    current_user: DBUser = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    auth_service.logout(db, current_user.id, **client)
    return {"message": "Logged out successfully"}


@router.post("/change-password")
async def change_password(
    body: ChangePasswordRequest,
    request: Request,
    current_user: DBUser = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        auth_service.change_password(
            db, current_user,
            body.current_password,
            body.new_password,
            **client,
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    return {"message": "Password changed successfully"}


@router.get("/me")
async def me(current_user: DBUser = Depends(get_current_user)):
    roles = [r.name for r in current_user.roles]
    permissions = list({p.code for r in current_user.roles for p in r.permissions})
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "first_name": current_user.first_name,
        "last_name": current_user.last_name,
        "roles": roles,
        "permissions": permissions,
        "force_password_change": current_user.force_password_change,
    }
