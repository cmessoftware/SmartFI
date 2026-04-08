"""add_estimated_payment_column

Revision ID: 454edd24e1a1
Revises: feb52f2c5e5c
Create Date: 2026-04-04 01:56:41.576939

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '454edd24e1a1'
down_revision: Union[str, None] = 'feb52f2c5e5c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add estimated_payment column (monto_a_pagar)
    op.add_column('budget_items', sa.Column('estimated_payment', sa.Float(), nullable=True))
    # Backfill: set estimated_payment = monto_total for existing rows
    op.execute("UPDATE budget_items SET estimated_payment = monto_total WHERE estimated_payment IS NULL")


def downgrade() -> None:
    op.drop_column('budget_items', 'estimated_payment')
