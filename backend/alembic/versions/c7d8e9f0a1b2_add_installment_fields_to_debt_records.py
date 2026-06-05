"""add installment and source fields to debt_records

Revision ID: c7d8e9f0a1b2
Revises: f1c2d3e4b5a6
Create Date: 2026-06-01 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect, text


# revision identifiers, used by Alembic.
revision: str = 'c7d8e9f0a1b2'
down_revision: Union[str, None] = 'f1c2d3e4b5a6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('debt_records')}

    if 'debt_source' not in existing_columns:
        op.add_column('debt_records', sa.Column('debt_source', sa.String(length=50), nullable=True))
    if 'total_installments' not in existing_columns:
        op.add_column('debt_records', sa.Column('total_installments', sa.Float(), nullable=True))
    if 'current_installment' not in existing_columns:
        op.add_column('debt_records', sa.Column('current_installment', sa.Float(), nullable=True))
    if 'pending_installments' not in existing_columns:
        op.add_column('debt_records', sa.Column('pending_installments', sa.Float(), nullable=True))

    # Backfill pending_installments for rows with total/current and missing pending.
    op.execute(
        text(
            """
            UPDATE debt_records
               SET pending_installments = GREATEST(0, total_installments - current_installment + 1)
             WHERE pending_installments IS NULL
               AND total_installments IS NOT NULL
               AND current_installment IS NOT NULL
            """
        )
    )


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('debt_records')}

    if 'pending_installments' in existing_columns:
        op.drop_column('debt_records', 'pending_installments')
    if 'current_installment' in existing_columns:
        op.drop_column('debt_records', 'current_installment')
    if 'total_installments' in existing_columns:
        op.drop_column('debt_records', 'total_installments')
    if 'debt_source' in existing_columns:
        op.drop_column('debt_records', 'debt_source')
