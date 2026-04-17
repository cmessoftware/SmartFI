"""Users admin API router."""
from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel
from typing import Optional, List

from sqlalchemy.orm import Session

from database.database import get_db, User as DBUser
from security.auth_dependencies import get_current_user, require_role, get_client_info
from security import user_service

router = APIRouter(prefix="/api/admin/users", tags=["admin-users"])


# ── Pydantic schemas ──────────────────────────────────────────

class UserCreateRequest(BaseModel):
    username: str
    email: str
    password: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    role_ids: Optional[List[int]] = None
    is_active: Optional[bool] = True

class UserUpdateRequest(BaseModel):
    email: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    is_active: Optional[bool] = None
    role_ids: Optional[List[int]] = None

class ResetPasswordRequest(BaseModel):
    new_password: str


# ── Endpoints ─────────────────────────────────────────────────

@router.get("")
async def list_users(
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    return user_service.list_users(db)


@router.get("/{user_id}")
async def get_user(
    user_id: int,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    user = user_service.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_user(
    body: UserCreateRequest,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        return user_service.create_user(
            db,
            username=body.username,
            email=body.email,
            password=body.password,
            first_name=body.first_name,
            last_name=body.last_name,
            role_ids=body.role_ids,
            is_active=body.is_active,
            admin_user=current_user,
            **client,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{user_id}")
async def update_user(
    user_id: int,
    body: UserUpdateRequest,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        return user_service.update_user(
            db, user_id,
            email=body.email,
            first_name=body.first_name,
            last_name=body.last_name,
            is_active=body.is_active,
            role_ids=body.role_ids,
            admin_user=current_user,
            **client,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/{user_id}/activate")
async def activate_user(
    user_id: int,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        user_service.activate_user(db, user_id, current_user, **client)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "User activated"}


@router.patch("/{user_id}/deactivate")
async def deactivate_user(
    user_id: int,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        user_service.deactivate_user(db, user_id, current_user, **client)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "User deactivated"}


@router.patch("/{user_id}/unlock")
async def unlock_user(
    user_id: int,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        user_service.unlock_user(db, user_id, current_user, **client)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "User unlocked"}


@router.post("/{user_id}/reset-password")
async def reset_password(
    user_id: int,
    body: ResetPasswordRequest,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        user_service.reset_password(db, user_id, body.new_password, current_user, **client)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "Password reset successfully"}
