"""add user_id to transactions budget_items month_closings

Revision ID: 4a996ebe53db
Revises: cd27b5ecca12
Create Date: 2026-04-09 22:37:20.964950

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '4a996ebe53db'
down_revision: Union[str, None] = 'cd27b5ecca12'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add user_id columns
    op.add_column('budget_items', sa.Column('user_id', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_budget_items_user_id'), 'budget_items', ['user_id'], unique=False)
    op.create_foreign_key('fk_budget_items_user_id', 'budget_items', 'users', ['user_id'], ['id'])

    op.add_column('month_closings', sa.Column('user_id', sa.Integer(), nullable=True))
    op.drop_constraint('uq_month_closings_year_month', 'month_closings', type_='unique')
    op.create_index(op.f('ix_month_closings_user_id'), 'month_closings', ['user_id'], unique=False)
    op.create_unique_constraint('uq_month_closings_year_month_user', 'month_closings', ['year', 'month', 'user_id'])
    op.create_foreign_key('fk_month_closings_user_id', 'month_closings', 'users', ['user_id'], ['id'])

    op.add_column('transactions', sa.Column('user_id', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_transactions_user_id'), 'transactions', ['user_id'], unique=False)
    op.create_foreign_key('fk_transactions_user_id', 'transactions', 'users', ['user_id'], ['id'])

    # Assign all existing data to admin user (id=1)
    op.execute("UPDATE transactions SET user_id = 1 WHERE user_id IS NULL")
    op.execute("UPDATE budget_items SET user_id = 1 WHERE user_id IS NULL")
    op.execute("UPDATE month_closings SET user_id = 1 WHERE user_id IS NULL")
    op.execute("UPDATE credit_cards SET user_id = 1 WHERE user_id IS NULL")


def downgrade() -> None:
    op.drop_constraint('fk_transactions_user_id', 'transactions', type_='foreignkey')
    op.drop_index(op.f('ix_transactions_user_id'), table_name='transactions')
    op.drop_column('transactions', 'user_id')

    op.drop_constraint('fk_month_closings_user_id', 'month_closings', type_='foreignkey')
    op.drop_constraint('uq_month_closings_year_month_user', 'month_closings', type_='unique')
    op.drop_index(op.f('ix_month_closings_user_id'), table_name='month_closings')
    op.create_unique_constraint('uq_month_closings_year_month', 'month_closings', ['year', 'month'])
    op.drop_column('month_closings', 'user_id')

    op.drop_constraint('fk_budget_items_user_id', 'budget_items', type_='foreignkey')
    op.drop_index(op.f('ix_budget_items_user_id'), table_name='budget_items')
    op.drop_column('budget_items', 'user_id')
    op.create_table('test_123',
    sa.Column('id', sa.INTEGER(), autoincrement=False, nullable=True)
    )
    op.create_table('transactions_demo',
    sa.Column('id', sa.INTEGER(), autoincrement=True, nullable=False),
    sa.Column('timestamp', postgresql.TIMESTAMP(), autoincrement=False, nullable=True),
    sa.Column('date', sa.VARCHAR(), autoincrement=False, nullable=False),
    sa.Column('type', postgresql.ENUM('GASTO', 'INGRESO', name='transactiontype'), autoincrement=False, nullable=False),
    sa.Column('amount', sa.DOUBLE_PRECISION(precision=53), autoincrement=False, nullable=False),
    sa.Column('necessity', postgresql.ENUM('NECESARIO', 'SUPERFLUO', 'IMPORTANTE_NO_URGENTE', name='necessitytype'), autoincrement=False, nullable=False),
    sa.Column('payment_method', sa.VARCHAR(), autoincrement=False, nullable=False),
    sa.Column('detail', sa.VARCHAR(length=50), autoincrement=False, nullable=True),
    sa.Column('created_at', postgresql.TIMESTAMP(), autoincrement=False, nullable=True),
    sa.Column('debt_id', sa.INTEGER(), autoincrement=False, nullable=True),
    sa.Column('assignment_status', postgresql.ENUM('ASIGNADA_MANUAL', 'ASIGNADA_AUTOMATICA', 'NO_PLANIFICADA', 'REASIGNADA_AUTOMATICA', name='assignmentstatus'), server_default=sa.text("'ASIGNADA_MANUAL'::assignmentstatus"), autoincrement=False, nullable=True),
    sa.Column('category_id', sa.INTEGER(), autoincrement=False, nullable=False),
    sa.ForeignKeyConstraint(['category_id'], ['categories.id'], name='transactions_demo_category_id_fkey'),
    sa.ForeignKeyConstraint(['debt_id'], ['budget_items.id'], name='transactions_demo_debt_id_fkey'),
    sa.PrimaryKeyConstraint('id', name='transactions_demo_pkey')
    )
    op.create_index('ix_transactions_demo_id', 'transactions_demo', ['id'], unique=False, postgresql_with={'fillfactor': '100', 'deduplicate_items': 'true'})
    # ### end Alembic commands ###
