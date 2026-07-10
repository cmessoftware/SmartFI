"""add salary-percent installment fields to debt_records

Revision ID: b2c3d4e5f6a7
Revises: c7d8e9f0a1b2, f9a4c2e7b1d3
Create Date: 2026-06-29 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision: str = 'b2c3d4e5f6a7'
down_revision: Union[str, Sequence[str], None] = ('c7d8e9f0a1b2', 'f9a4c2e7b1d3')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('debt_records')}

    if 'installment_mode' not in existing_columns:
        op.add_column(
            'debt_records',
            sa.Column('installment_mode', sa.String(length=20), nullable=False, server_default='FIXED'),
        )
    if 'base_salary' not in existing_columns:
        op.add_column('debt_records', sa.Column('base_salary', sa.Float(), nullable=True))
    if 'installment_salary_percent' not in existing_columns:
        op.add_column('debt_records', sa.Column('installment_salary_percent', sa.Float(), nullable=True))
    if 'salary_increase_percent' not in existing_columns:
        op.add_column('debt_records', sa.Column('salary_increase_percent', sa.Float(), nullable=True))
    if 'salary_increase_interval_months' not in existing_columns:
        op.add_column('debt_records', sa.Column('salary_increase_interval_months', sa.Integer(), nullable=True))


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('debt_records')}

    for col in (
        'salary_increase_interval_months',
        'salary_increase_percent',
        'installment_salary_percent',
        'base_salary',
        'installment_mode',
    ):
        if col in existing_columns:
            op.drop_column('debt_records', col)
