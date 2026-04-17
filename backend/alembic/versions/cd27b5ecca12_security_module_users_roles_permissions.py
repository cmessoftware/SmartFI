"""security_module_users_roles_permissions

Revision ID: cd27b5ecca12
Revises: 8813f60f5c38
Create Date: 2026-04-08 13:33:31.849842

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'cd27b5ecca12'
down_revision: Union[str, None] = '8813f60f5c38'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create new security tables
    op.create_table('permissions',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('code', sa.String(length=50), nullable=False),
    sa.Column('description', sa.String(length=255), nullable=True),
    sa.Column('module', sa.String(length=50), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_permissions_code'), 'permissions', ['code'], unique=True)
    op.create_index(op.f('ix_permissions_id'), 'permissions', ['id'], unique=False)
    op.create_table('roles',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=50), nullable=False),
    sa.Column('description', sa.String(length=255), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_roles_id'), 'roles', ['id'], unique=False)
    op.create_index(op.f('ix_roles_name'), 'roles', ['name'], unique=True)
    op.create_table('audit_logs',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('username', sa.String(length=50), nullable=True),
    sa.Column('action', sa.String(length=50), nullable=False),
    sa.Column('entity', sa.String(length=50), nullable=True),
    sa.Column('entity_id', sa.Integer(), nullable=True),
    sa.Column('details', sa.Text(), nullable=True),
    sa.Column('ip_address', sa.String(length=45), nullable=True),
    sa.Column('user_agent', sa.String(length=500), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='SET NULL'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_audit_logs_action'), 'audit_logs', ['action'], unique=False)
    op.create_index(op.f('ix_audit_logs_created_at'), 'audit_logs', ['created_at'], unique=False)
    op.create_index(op.f('ix_audit_logs_id'), 'audit_logs', ['id'], unique=False)
    op.create_table('refresh_tokens',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('token_hash', sa.String(length=255), nullable=False),
    sa.Column('expires_at', sa.DateTime(), nullable=False),
    sa.Column('revoked_at', sa.DateTime(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('ip_address', sa.String(length=45), nullable=True),
    sa.Column('user_agent', sa.String(length=500), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_refresh_tokens_id'), 'refresh_tokens', ['id'], unique=False)
    op.create_index(op.f('ix_refresh_tokens_token_hash'), 'refresh_tokens', ['token_hash'], unique=False)
    op.create_table('role_permissions',
    sa.Column('role_id', sa.Integer(), nullable=False),
    sa.Column('permission_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['permission_id'], ['permissions.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['role_id'], ['roles.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('role_id', 'permission_id')
    )
    op.create_table('user_roles',
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('role_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['role_id'], ['roles.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('user_id', 'role_id')
    )

    # Alter users table: add new columns, drop old ones
    op.add_column('users', sa.Column('email', sa.String(length=255), nullable=True))
    op.add_column('users', sa.Column('first_name', sa.String(length=100), nullable=True))
    op.add_column('users', sa.Column('last_name', sa.String(length=100), nullable=True))
    op.add_column('users', sa.Column('is_active', sa.Boolean(), server_default=sa.text('true'), nullable=False))
    op.add_column('users', sa.Column('is_locked', sa.Boolean(), server_default=sa.text('false'), nullable=False))
    op.add_column('users', sa.Column('failed_login_attempts', sa.Integer(), server_default=sa.text('0'), nullable=False))
    op.add_column('users', sa.Column('force_password_change', sa.Boolean(), server_default=sa.text('false'), nullable=False))
    op.add_column('users', sa.Column('last_login_at', sa.DateTime(), nullable=True))
    op.add_column('users', sa.Column('password_changed_at', sa.DateTime(), nullable=True))
    op.add_column('users', sa.Column('updated_at', sa.DateTime(), nullable=True))

    # Populate email from username for existing rows, then make it non-null + unique
    op.execute("UPDATE users SET email = username || '@finly.local' WHERE email IS NULL")
    op.alter_column('users', 'email', nullable=False)
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)

    # Drop old columns
    op.drop_column('users', 'role')
    op.drop_column('users', 'full_name')


def downgrade() -> None:
    # Restore old users columns
    op.add_column('users', sa.Column('full_name', sa.VARCHAR(), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('role', sa.VARCHAR(), autoincrement=False, nullable=True))
    op.execute("UPDATE users SET role = 'reader', full_name = first_name")
    op.alter_column('users', 'role', nullable=False)

    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_column('users', 'updated_at')
    op.drop_column('users', 'password_changed_at')
    op.drop_column('users', 'last_login_at')
    op.drop_column('users', 'force_password_change')
    op.drop_column('users', 'failed_login_attempts')
    op.drop_column('users', 'is_locked')
    op.drop_column('users', 'is_active')
    op.drop_column('users', 'last_name')
    op.drop_column('users', 'first_name')
    op.drop_column('users', 'email')

    op.drop_table('user_roles')
    op.drop_table('role_permissions')
    op.drop_index(op.f('ix_refresh_tokens_token_hash'), table_name='refresh_tokens')
    op.drop_index(op.f('ix_refresh_tokens_id'), table_name='refresh_tokens')
    op.drop_table('refresh_tokens')
    op.drop_index(op.f('ix_audit_logs_id'), table_name='audit_logs')
    op.drop_index(op.f('ix_audit_logs_created_at'), table_name='audit_logs')
    op.drop_index(op.f('ix_audit_logs_action'), table_name='audit_logs')
    op.drop_table('audit_logs')
    op.drop_index(op.f('ix_roles_name'), table_name='roles')
    op.drop_index(op.f('ix_roles_id'), table_name='roles')
    op.drop_table('roles')
    op.drop_index(op.f('ix_permissions_id'), table_name='permissions')
    op.drop_index(op.f('ix_permissions_code'), table_name='permissions')
    op.drop_table('permissions')
