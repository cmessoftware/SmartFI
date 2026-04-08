"""add_month_closings_table

Revision ID: ff17f8e16fb1
Revises: b5e8f2a1c3d7
Create Date: 2026-04-03 21:54:44.536988

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'ff17f8e16fb1'
down_revision: Union[str, None] = 'b5e8f2a1c3d7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('month_closings',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('year', sa.Integer(), nullable=False),
    sa.Column('month', sa.Integer(), nullable=False),
    sa.Column('total_ingresos', sa.Float(), nullable=False),
    sa.Column('total_gastos', sa.Float(), nullable=False),
    sa.Column('balance', sa.Float(), nullable=False),
    sa.Column('carry_over_transaction_id', sa.Integer(), nullable=True),
    sa.Column('closed_by', sa.String(length=100), nullable=True),
    sa.Column('closed_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['carry_over_transaction_id'], ['transactions.id'], ondelete='SET NULL'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('year', 'month', name='uq_month_closings_year_month')
    )
    op.create_index(op.f('ix_month_closings_id'), 'month_closings', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_month_closings_id'), table_name='month_closings')
    op.drop_table('month_closings')
