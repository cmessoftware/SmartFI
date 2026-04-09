"""Seed default roles, permissions, and admin user.

Run once after migration to populate initial data.
Can be called on startup — it is idempotent (skips if data already exists).
"""
from sqlalchemy.orm import Session

from database.database import User as DBUser, Role as DBRole, Permission as DBPermission
from security.jwt_manager import hash_password


# ── Default permissions per module ────────────────────────────

DEFAULT_PERMISSIONS = [
    # Transactions
    ("transactions.read",   "Transacciones", "Ver transacciones"),
    ("transactions.write",  "Transacciones", "Crear/editar transacciones"),
    ("transactions.delete", "Transacciones", "Eliminar transacciones"),
    # Debts / Budget
    ("debts.read",   "Presupuesto", "Ver presupuesto/deudas"),
    ("debts.write",  "Presupuesto", "Crear/editar presupuesto"),
    ("debts.delete", "Presupuesto", "Eliminar presupuesto"),
    # Credit cards
    ("creditcards.read",   "Tarjetas", "Ver tarjetas de crédito"),
    ("creditcards.write",  "Tarjetas", "Crear/editar tarjetas"),
    ("creditcards.delete", "Tarjetas", "Eliminar tarjetas"),
    # Categories
    ("categories.read",   "Categorías", "Ver categorías"),
    ("categories.write",  "Categorías", "Crear/editar categorías"),
    ("categories.delete", "Categorías", "Eliminar categorías"),
    # Admin
    ("users.read",   "Admin", "Ver usuarios"),
    ("users.write",  "Admin", "Crear/editar usuarios"),
    ("users.delete", "Admin", "Eliminar usuarios"),
    ("roles.read",   "Admin", "Ver roles"),
    ("roles.write",  "Admin", "Crear/editar roles"),
    ("roles.delete", "Admin", "Eliminar roles"),
    # Settings
    ("settings.read",  "Configuración", "Ver configuración"),
    ("settings.write", "Configuración", "Editar configuración"),
]


# ── Default roles with assigned permission codes ──────────────

DEFAULT_ROLES = {
    "ADMIN": {
        "description": "Administrador con acceso total",
        "permissions": [code for code, _, _ in DEFAULT_PERMISSIONS],  # all
    },
    "WRITER": {
        "description": "Editor — puede leer y escribir datos",
        "permissions": [
            "transactions.read", "transactions.write",
            "debts.read", "debts.write",
            "creditcards.read", "creditcards.write",
            "categories.read",
            "settings.read",
        ],
    },
    "READER": {
        "description": "Lector — solo lectura",
        "permissions": [
            "transactions.read",
            "debts.read",
            "creditcards.read",
            "categories.read",
            "settings.read",
        ],
    },
}


def seed(db: Session):
    """Create default permissions, roles and admin user if they don't exist."""
    _seed_permissions(db)
    _seed_roles(db)
    _seed_admin_user(db)


def _seed_permissions(db: Session):
    for code, module, description in DEFAULT_PERMISSIONS:
        existing = db.query(DBPermission).filter(DBPermission.code == code).first()
        if not existing:
            db.add(DBPermission(code=code, module=module, description=description))
    db.commit()


def _seed_roles(db: Session):
    for role_name, info in DEFAULT_ROLES.items():
        role = db.query(DBRole).filter(DBRole.name == role_name).first()
        if not role:
            role = DBRole(name=role_name, description=info["description"])
            db.add(role)
            db.flush()  # get role.id

        # Assign permissions
        perm_codes = info["permissions"]
        perms = db.query(DBPermission).filter(DBPermission.code.in_(perm_codes)).all()
        role.permissions = perms
    db.commit()


def _seed_admin_user(db: Session):
    admin = db.query(DBUser).filter(DBUser.username == "admin").first()
    if admin:
        # Make sure admin has ADMIN role
        admin_role = db.query(DBRole).filter(DBRole.name == "ADMIN").first()
        if admin_role and admin_role not in admin.roles:
            admin.roles.append(admin_role)
            db.commit()
        return

    admin_role = db.query(DBRole).filter(DBRole.name == "ADMIN").first()
    admin = DBUser(
        username="admin",
        email="admin@finly.local",
        hashed_password=hash_password("admin123"),
        first_name="Administrador",
        is_active=True,
    )
    if admin_role:
        admin.roles.append(admin_role)

    db.add(admin)
    db.commit()
