"""change_detail_column_to_text

Revision ID: feb52f2c5e5c
Revises: ff17f8e16fb1
Create Date: 2026-04-03 23:30:34.844531

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'feb52f2c5e5c'
down_revision: Union[str, None] = 'ff17f8e16fb1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column('transactions', 'detail',
               existing_type=sa.VARCHAR(length=50),
               type_=sa.Text(),
               existing_nullable=True)


def downgrade() -> None:
    op.alter_column('transactions', 'detail',
               existing_type=sa.Text(),
               type_=sa.VARCHAR(length=50),
               existing_nullable=True)
