"""add dbt traceability fields to budget_items

Revision ID: f1c2d3e4b5a6
Revises: 9c4f8f3d1a2b
Create Date: 2026-05-29 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


# revision identifiers, used by Alembic.
revision: str = 'f1c2d3e4b5a6'
down_revision: Union[str, None] = '9c4f8f3d1a2b'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


FK_NAME = 'fk_budget_items_debt_record_id_debt_records'
INDEX_NAME = 'ix_budget_items_debt_record_id'


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('budget_items')}

    if 'debt_record_id' not in existing_columns:
        op.add_column('budget_items', sa.Column('debt_record_id', sa.Integer(), nullable=True))
    if 'debt_quota_number' not in existing_columns:
        op.add_column('budget_items', sa.Column('debt_quota_number', sa.Float(), nullable=True))
    if 'debt_total_quotas' not in existing_columns:
        op.add_column('budget_items', sa.Column('debt_total_quotas', sa.Float(), nullable=True))
    if 'debt_source' not in existing_columns:
        op.add_column('budget_items', sa.Column('debt_source', sa.String(length=120), nullable=True))

    fk_names = {fk['name'] for fk in inspector.get_foreign_keys('budget_items')}
    if FK_NAME not in fk_names:
        op.create_foreign_key(
            FK_NAME,
            'budget_items',
            'debt_records',
            ['debt_record_id'],
            ['id'],
            ondelete='SET NULL'
        )

    indexes = {idx['name'] for idx in inspector.get_indexes('budget_items')}
    if INDEX_NAME not in indexes:
        op.create_index(INDEX_NAME, 'budget_items', ['debt_record_id'], unique=False)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_columns = {col['name'] for col in inspector.get_columns('budget_items')}
    fk_names = {fk['name'] for fk in inspector.get_foreign_keys('budget_items')}
    indexes = {idx['name'] for idx in inspector.get_indexes('budget_items')}

    if INDEX_NAME in indexes:
        op.drop_index(INDEX_NAME, table_name='budget_items')
    if FK_NAME in fk_names:
        op.drop_constraint(FK_NAME, 'budget_items', type_='foreignkey')

    if 'debt_source' in existing_columns:
        op.drop_column('budget_items', 'debt_source')
    if 'debt_total_quotas' in existing_columns:
        op.drop_column('budget_items', 'debt_total_quotas')
    if 'debt_quota_number' in existing_columns:
        op.drop_column('budget_items', 'debt_quota_number')
    if 'debt_record_id' in existing_columns:
        op.drop_column('budget_items', 'debt_record_id')
