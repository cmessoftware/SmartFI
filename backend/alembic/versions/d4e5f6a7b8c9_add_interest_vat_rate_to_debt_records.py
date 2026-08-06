"""add interest_vat_rate to debt_records

Revision ID: d4e5f6a7b8c9
Revises: b2c3d4e5f6a7
Create Date: 2026-08-06 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision: str = 'd4e5f6a7b8c9'
down_revision: Union[str, None] = 'b2c3d4e5f6a7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('debt_records')}

    if 'interest_vat_rate' not in existing_columns:
        op.add_column(
            'debt_records',
            sa.Column('interest_vat_rate', sa.Float(), nullable=False, server_default='21'),
        )
        op.alter_column('debt_records', 'interest_vat_rate', server_default=None)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('debt_records')}

    if 'interest_vat_rate' in existing_columns:
        op.drop_column('debt_records', 'interest_vat_rate')
