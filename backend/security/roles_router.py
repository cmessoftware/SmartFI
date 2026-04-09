"""Roles & permissions admin API router."""
from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel
from typing import Optional, List

from sqlalchemy.orm import Session

from database.database import get_db, User as DBUser
from security.auth_dependencies import require_role, get_client_info
from security import role_service

router = APIRouter(prefix="/api/admin/roles", tags=["admin-roles"])


# ── Pydantic schemas ──────────────────────────────────────────

class RoleCreateRequest(BaseModel):
    name: str
    description: Optional[str] = None
    permission_ids: Optional[List[int]] = None

class RoleUpdateRequest(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    permission_ids: Optional[List[int]] = None


# ── Role endpoints ────────────────────────────────────────────

@router.get("")
async def list_roles(
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    return role_service.list_roles(db)


@router.get("/{role_id}")
async def get_role(
    role_id: int,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    role = role_service.get_role(db, role_id)
    if not role:
        raise HTTPException(status_code=404, detail="Role not found")
    return role


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_role(
    body: RoleCreateRequest,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        return role_service.create_role(
            db, name=body.name, description=body.description,
            permission_ids=body.permission_ids,
            admin_user=current_user, **client,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{role_id}")
async def update_role(
    role_id: int,
    body: RoleUpdateRequest,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        return role_service.update_role(
            db, role_id,
            name=body.name, description=body.description,
            permission_ids=body.permission_ids,
            admin_user=current_user, **client,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{role_id}")
async def delete_role(
    role_id: int,
    request: Request,
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    client = get_client_info(request)
    try:
        role_service.delete_role(db, role_id, current_user, **client)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "Role deleted"}


# ── Permission endpoints ──────────────────────────────────────

@router.get("/permissions/all")
async def list_permissions(
    current_user: DBUser = Depends(require_role(["ADMIN"])),
    db: Session = Depends(get_db),
):
    return role_service.list_permissions(db)
