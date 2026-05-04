"""add_credit_card_purchase_billing_date

Revision ID: d21f4e8a9c7b
Revises: ad1636edd0b9
Create Date: 2026-04-27 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from dateutil.relativedelta import relativedelta


# revision identifiers, used by Alembic.
revision: str = 'd21f4e8a9c7b'
down_revision: Union[str, None] = 'ad1636edd0b9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


credit_card_purchases = sa.table(
    'credit_card_purchases',
    sa.column('id', sa.Integer),
    sa.column('purchase_date', sa.Date),
    sa.column('billing_date', sa.Date),
    sa.column('currency', sa.String(length=3)),
)


def upgrade() -> None:
    op.add_column('credit_card_purchases', sa.Column('billing_date', sa.Date(), nullable=True))

    bind = op.get_bind()
    rows = bind.execute(
        sa.select(
            credit_card_purchases.c.id,
            credit_card_purchases.c.purchase_date,
            credit_card_purchases.c.currency,
        )
    ).fetchall()

    for row in rows:
        purchase_date = row.purchase_date
        if purchase_date is None:
            continue

        billing_date = purchase_date
        if row.currency == 'USD':
            billing_date = purchase_date + relativedelta(months=1)

        bind.execute(
            credit_card_purchases.update()
            .where(credit_card_purchases.c.id == row.id)
            .values(billing_date=billing_date)
        )


def downgrade() -> None:
    op.drop_column('credit_card_purchases', 'billing_date')