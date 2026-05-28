"""add cash advance fields to credit card purchases

Revision ID: 9c4f8f3d1a2b
Revises: 47c34fcbcce0
Create Date: 2026-05-28 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


# revision identifiers, used by Alembic.
revision: str = '9c4f8f3d1a2b'
down_revision: Union[str, None] = '47c34fcbcce0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


FK_NAME = 'fk_credit_card_purchases_derived_debt_id_budget_items'


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('credit_card_purchases')}

    if 'movement_type' not in existing_columns:
        op.add_column(
            'credit_card_purchases',
            sa.Column('movement_type', sa.String(length=30), nullable=False, server_default='normal')
        )
    if 'cash_advance_fee' not in existing_columns:
        op.add_column(
            'credit_card_purchases',
            sa.Column('cash_advance_fee', sa.Float(), nullable=False, server_default='0')
        )
    if 'derived_debt_id' not in existing_columns:
        op.add_column(
            'credit_card_purchases',
            sa.Column('derived_debt_id', sa.Integer(), nullable=True)
        )

    fk_names = {fk['name'] for fk in inspector.get_foreign_keys('credit_card_purchases')}
    if FK_NAME not in fk_names:
        op.create_foreign_key(
            FK_NAME,
            'credit_card_purchases',
            'budget_items',
            ['derived_debt_id'],
            ['id'],
            ondelete='SET NULL'
        )


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('credit_card_purchases')}
    fk_names = {fk['name'] for fk in inspector.get_foreign_keys('credit_card_purchases')}

    if FK_NAME in fk_names:
        op.drop_constraint(FK_NAME, 'credit_card_purchases', type_='foreignkey')
    if 'derived_debt_id' in existing_columns:
        op.drop_column('credit_card_purchases', 'derived_debt_id')
    if 'cash_advance_fee' in existing_columns:
        op.drop_column('credit_card_purchases', 'cash_advance_fee')
    if 'movement_type' in existing_columns:
        op.drop_column('credit_card_purchases', 'movement_type')
