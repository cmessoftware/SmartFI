"""add_app_settings_and_purchase_currency

Revision ID: a3f7c9d1e2b4
Revises: e10c0b8c5dbe
Create Date: 2026-03-29 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a3f7c9d1e2b4'
down_revision: Union[str, None] = 'e10c0b8c5dbe'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create app_settings table
    op.create_table('app_settings',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('key', sa.String(length=100), nullable=False),
        sa.Column('value', sa.String(length=500), nullable=False),
        sa.Column('description', sa.String(length=255), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('key')
    )
    op.create_index(op.f('ix_app_settings_id'), 'app_settings', ['id'], unique=False)
    op.create_index(op.f('ix_app_settings_key'), 'app_settings', ['key'], unique=True)

    # 2. Insert default dollar exchange rate
    op.execute(
        "INSERT INTO app_settings (key, value, description, updated_at) "
        "VALUES ('dollar_exchange_rate', '1200', 'Cotización del dólar (ARS por 1 USD)', NOW())"
    )

    # 3. Add currency columns to credit_card_purchases
    op.add_column('credit_card_purchases', sa.Column('currency', sa.String(length=3), server_default='ARS', nullable=True))
    op.add_column('credit_card_purchases', sa.Column('exchange_rate', sa.Float(), nullable=True))
    op.add_column('credit_card_purchases', sa.Column('amount_in_pesos', sa.Float(), nullable=True))

    # 4. Set existing purchases to ARS
    op.execute("UPDATE credit_card_purchases SET currency = 'ARS' WHERE currency IS NULL")


def downgrade() -> None:
    # Remove currency columns from credit_card_purchases
    op.drop_column('credit_card_purchases', 'amount_in_pesos')
    op.drop_column('credit_card_purchases', 'exchange_rate')
    op.drop_column('credit_card_purchases', 'currency')

    # Drop app_settings table
    op.drop_index(op.f('ix_app_settings_key'), table_name='app_settings')
    op.drop_index(op.f('ix_app_settings_id'), table_name='app_settings')
    op.drop_table('app_settings')
