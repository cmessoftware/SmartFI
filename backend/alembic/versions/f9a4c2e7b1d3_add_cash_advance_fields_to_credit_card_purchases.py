"""add cash advance fields to credit card purchases

Revision ID: f9a4c2e7b1d3
Revises: 47c34fcbcce0
Create Date: 2026-05-22 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f9a4c2e7b1d3'
down_revision: Union[str, None] = '47c34fcbcce0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'credit_card_purchases',
        sa.Column('movement_type', sa.String(length=20), nullable=True),
    )
    op.add_column(
        'credit_card_purchases',
        sa.Column('cash_advance_fee', sa.Float(), nullable=True),
    )
    op.add_column(
        'credit_card_purchases',
        sa.Column('derived_debt_id', sa.Integer(), nullable=True),
    )

    op.execute("UPDATE credit_card_purchases SET movement_type = 'normal' WHERE movement_type IS NULL")
    op.execute("UPDATE credit_card_purchases SET cash_advance_fee = 0 WHERE cash_advance_fee IS NULL")

    op.alter_column('credit_card_purchases', 'movement_type', nullable=False)
    op.alter_column('credit_card_purchases', 'cash_advance_fee', nullable=False)

    op.create_check_constraint(
        'ck_cc_purchase_movement_type',
        'credit_card_purchases',
        "movement_type IN ('normal', 'cash_advance')",
    )
    op.create_check_constraint(
        'ck_cc_purchase_cash_advance_fee_non_negative',
        'credit_card_purchases',
        'cash_advance_fee >= 0',
    )
    op.create_foreign_key(
        'fk_cc_purchase_derived_debt',
        'credit_card_purchases',
        'budget_items',
        ['derived_debt_id'],
        ['id'],
        ondelete='SET NULL',
    )


def downgrade() -> None:
    op.drop_constraint('fk_cc_purchase_derived_debt', 'credit_card_purchases', type_='foreignkey')
    op.drop_constraint('ck_cc_purchase_cash_advance_fee_non_negative', 'credit_card_purchases', type_='check')
    op.drop_constraint('ck_cc_purchase_movement_type', 'credit_card_purchases', type_='check')
    op.drop_column('credit_card_purchases', 'derived_debt_id')
    op.drop_column('credit_card_purchases', 'cash_advance_fee')
    op.drop_column('credit_card_purchases', 'movement_type')
