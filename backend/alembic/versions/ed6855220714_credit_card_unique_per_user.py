"""credit_card_unique_per_user

Revision ID: ed6855220714
Revises: 4a996ebe53db
Create Date: 2026-04-13 16:14:24.887707

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'ed6855220714'
down_revision: Union[str, None] = '4a996ebe53db'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_constraint('credit_cards_card_name_key', 'credit_cards', type_='unique')
    op.create_unique_constraint('uq_credit_cards_user_card_name', 'credit_cards', ['user_id', 'card_name'])


def downgrade() -> None:
    op.drop_constraint('uq_credit_cards_user_card_name', 'credit_cards', type_='unique')
    op.create_unique_constraint('credit_cards_card_name_key', 'credit_cards', ['card_name'])
