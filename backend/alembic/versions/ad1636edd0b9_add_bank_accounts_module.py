"""add_bank_accounts_module

Revision ID: ad1636edd0b9
Revises: ed6855220714
Create Date: 2026-04-25 20:36:40.535480

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ad1636edd0b9'
down_revision: Union[str, None] = 'ed6855220714'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


ACCOUNT_TYPE_ENUM = sa.Enum(
    'CUENTA_CORRIENTE',
    'CAJA_AHORRO',
    'BILLETERA_VIRTUAL',
    'INVERSION',
    'OTRO',
    name='accounttype',
)

DEBT_TYPE_ENUM = sa.Enum(
    'TARJETA',
    'PRESTAMO',
    'HIPOTECA',
    'PERSONAL',
    'OTRO',
    name='debttype',
)

DEBT_RECORD_STATUS_ENUM = sa.Enum(
    'ACTIVA',
    'CANCELADA',
    'VENCIDA',
    name='debtrecordstatus',
)


def _has_column(bind, table_name: str, column_name: str) -> bool:
    inspector = sa.inspect(bind)
    return any(col['name'] == column_name for col in inspector.get_columns(table_name))


def _has_table(bind, table_name: str) -> bool:
    inspector = sa.inspect(bind)
    return table_name in inspector.get_table_names()


def upgrade() -> None:
    bind = op.get_bind()

    if not _has_table(bind, 'bank_accounts'):
        op.create_table(
            'bank_accounts',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('user_id', sa.Integer(), nullable=False),
            sa.Column('account_name', sa.String(length=100), nullable=False),
            sa.Column('institution_name', sa.String(length=100), nullable=False),
            sa.Column('account_type', ACCOUNT_TYPE_ENUM, nullable=False),
            sa.Column('currency', sa.String(length=3), nullable=False, server_default='ARS'),
            sa.Column('balance', sa.Float(), nullable=False, server_default='0'),
            sa.Column('is_active', sa.Boolean(), nullable=False, server_default=sa.text('true')),
            sa.Column('cbu_cvu', sa.String(length=22), nullable=True),
            sa.Column('alias', sa.String(length=50), nullable=True),
            sa.Column('notes', sa.Text(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.Column('updated_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id']),
            sa.PrimaryKeyConstraint('id'),
        )
        op.create_index(op.f('ix_bank_accounts_id'), 'bank_accounts', ['id'], unique=False)
        op.create_index(op.f('ix_bank_accounts_user_id'), 'bank_accounts', ['user_id'], unique=False)

    if _has_column(bind, 'transactions', 'debt_id') and not _has_column(bind, 'transactions', 'budget_item_id'):
        with op.batch_alter_table('transactions') as batch_op:
            batch_op.alter_column('debt_id', new_column_name='budget_item_id')

    if _has_column(bind, 'installment_plans', 'debt_id') and not _has_column(bind, 'installment_plans', 'budget_item_id'):
        with op.batch_alter_table('installment_plans') as batch_op:
            batch_op.alter_column('debt_id', new_column_name='budget_item_id')

    if not _has_table(bind, 'debt_records'):
        op.create_table(
            'debt_records',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('user_id', sa.Integer(), nullable=False),
            sa.Column('debt_name', sa.String(length=120), nullable=False),
            sa.Column('debt_type', DEBT_TYPE_ENUM, nullable=False),
            sa.Column('creditor', sa.String(length=120), nullable=True),
            sa.Column('currency', sa.String(length=3), nullable=False, server_default='ARS'),
            sa.Column('principal_amount', sa.Float(), nullable=False),
            sa.Column('outstanding_amount', sa.Float(), nullable=False),
            sa.Column('annual_interest_rate', sa.Float(), nullable=True),
            sa.Column('start_date', sa.Date(), nullable=True),
            sa.Column('due_date', sa.Date(), nullable=True),
            sa.Column('status', DEBT_RECORD_STATUS_ENUM, nullable=False, server_default='ACTIVA'),
            sa.Column('notes', sa.Text(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.Column('updated_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id']),
            sa.PrimaryKeyConstraint('id'),
        )
        op.create_index(op.f('ix_debt_records_id'), 'debt_records', ['id'], unique=False)
        op.create_index(op.f('ix_debt_records_user_id'), 'debt_records', ['user_id'], unique=False)

    if not _has_table(bind, 'debt_payments'):
        op.create_table(
            'debt_payments',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('debt_record_id', sa.Integer(), nullable=False),
            sa.Column('transaction_id', sa.Integer(), nullable=True),
            sa.Column('payment_date', sa.Date(), nullable=False),
            sa.Column('amount', sa.Float(), nullable=False),
            sa.Column('notes', sa.Text(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['debt_record_id'], ['debt_records.id'], ondelete='CASCADE'),
            sa.ForeignKeyConstraint(['transaction_id'], ['transactions.id'], ondelete='SET NULL'),
            sa.PrimaryKeyConstraint('id'),
        )
        op.create_index(op.f('ix_debt_payments_id'), 'debt_payments', ['id'], unique=False)
        op.create_index(op.f('ix_debt_payments_debt_record_id'), 'debt_payments', ['debt_record_id'], unique=False)


def downgrade() -> None:
    bind = op.get_bind()

    if _has_table(bind, 'debt_payments'):
        op.drop_index(op.f('ix_debt_payments_debt_record_id'), table_name='debt_payments')
        op.drop_index(op.f('ix_debt_payments_id'), table_name='debt_payments')
        op.drop_table('debt_payments')

    if _has_table(bind, 'debt_records'):
        op.drop_index(op.f('ix_debt_records_user_id'), table_name='debt_records')
        op.drop_index(op.f('ix_debt_records_id'), table_name='debt_records')
        op.drop_table('debt_records')

    if _has_column(bind, 'installment_plans', 'budget_item_id') and not _has_column(bind, 'installment_plans', 'debt_id'):
        with op.batch_alter_table('installment_plans') as batch_op:
            batch_op.alter_column('budget_item_id', new_column_name='debt_id')

    if _has_column(bind, 'transactions', 'budget_item_id') and not _has_column(bind, 'transactions', 'debt_id'):
        with op.batch_alter_table('transactions') as batch_op:
            batch_op.alter_column('budget_item_id', new_column_name='debt_id')

    if _has_table(bind, 'bank_accounts'):
        op.drop_index(op.f('ix_bank_accounts_user_id'), table_name='bank_accounts')
        op.drop_index(op.f('ix_bank_accounts_id'), table_name='bank_accounts')
        op.drop_table('bank_accounts')
