"""add_credit_card_period_configs_table

Revision ID: 8813f60f5c38
Revises: 454edd24e1a1
Create Date: 2026-04-07 17:14:55.853232

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '8813f60f5c38'
down_revision: Union[str, None] = '454edd24e1a1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('credit_card_period_configs',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('card_id', sa.Integer(), nullable=False),
    sa.Column('year', sa.Integer(), nullable=False),
    sa.Column('month', sa.Integer(), nullable=False),
    sa.Column('closing_day', sa.Integer(), nullable=False),
    sa.Column('due_day', sa.Integer(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['card_id'], ['credit_cards.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('card_id', 'year', 'month', name='uq_card_period_config')
    )
    op.create_index(op.f('ix_credit_card_period_configs_id'), 'credit_card_period_configs', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_credit_card_period_configs_id'), table_name='credit_card_period_configs')
    op.drop_table('credit_card_period_configs')
