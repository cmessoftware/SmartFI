"""monthly_periods_per_user_and_events

Revision ID: a1b2c3d4e5f6
Revises: e18b741c007c
Create Date: 2026-05-02 20:00:00.000000

Changes:
- Add user_id column to monthly_periods (per-user period isolation)
- Drop old unique index on year_month alone
- Add unique constraint on (year_month, user_id)
- Create monthly_period_events table for audit log
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import ENUM as PgEnum

revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, None] = 'e18b741c007c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # NOTE: monthperiodeventtype enum may already exist if SQLAlchemy auto-created it.
    # Use create_type=False in sa.Enum to avoid re-creating. Ensure it exists:
    op.execute("""
        DO $$ BEGIN
            CREATE TYPE monthperiodeventtype AS ENUM ('OPEN', 'CLOSE', 'REOPEN');
        EXCEPTION WHEN duplicate_object THEN NULL;
        END $$;
    """)

    # Add user_id column to monthly_periods
    op.add_column('monthly_periods',
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=True, index=True)
    )

    # Drop old unique index on year_month alone
    op.drop_index('ix_monthly_periods_year_month', table_name='monthly_periods')

    # Create non-unique index on year_month (for query performance)
    op.create_index('ix_monthly_periods_year_month', 'monthly_periods', ['year_month'], unique=False)

    # Add unique constraint on (year_month, user_id)
    op.create_unique_constraint(
        'uq_monthly_periods_year_month_user',
        'monthly_periods',
        ['year_month', 'user_id']
    )

    # Create monthly_period_events table
    op.create_table('monthly_period_events',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('monthly_period_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('username', sa.String(length=100), nullable=True),
        sa.Column('event_type', PgEnum('OPEN', 'CLOSE', 'REOPEN', name='monthperiodeventtype', create_type=False), nullable=False),
        sa.Column('occurred_at', sa.DateTime(), nullable=False),
        sa.Column('reason', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['monthly_period_id'], ['monthly_periods.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_monthly_period_events_id', 'monthly_period_events', ['id'], unique=False)
    op.create_index('ix_monthly_period_events_monthly_period_id', 'monthly_period_events', ['monthly_period_id'], unique=False)


def downgrade() -> None:
    op.drop_table('monthly_period_events')
    op.execute("DROP TYPE IF EXISTS monthperiodeventtype")

    op.drop_constraint('uq_monthly_periods_year_month_user', 'monthly_periods', type_='unique')
    op.drop_index('ix_monthly_periods_year_month', table_name='monthly_periods')
    op.create_index('ix_monthly_periods_year_month', 'monthly_periods', ['year_month'], unique=True)
    op.drop_column('monthly_periods', 'user_id')
