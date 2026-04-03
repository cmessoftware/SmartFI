"""Normalize categories table and rename transaction fields to English

Revision ID: b5e8f2a1c3d7
Revises: a3f7c9d1e2b4
Create Date: 2026-04-02

Mejora 6: Populate categories table, add category_id FK to transactions
Mejora 7: Rename transaction columns from Spanish to English
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'b5e8f2a1c3d7'
down_revision = 'a3f7c9d1e2b4'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ==========================================
    # MEJORA 6: Normalize categories
    # ==========================================

    # 1. Populate categories table from distinct values in transactions + hardcoded list
    op.execute("""
        INSERT INTO categories (name, created_at)
        SELECT DISTINCT categoria, NOW()
        FROM transactions
        WHERE categoria IS NOT NULL AND categoria != ''
        ON CONFLICT (name) DO NOTHING
    """)

    # Also insert categories from the hardcoded list that may not exist in transactions yet
    extra_categories = [
        'Cuidado Personal', 'Tarjeta VISA', 'Ocio', 'Seguros', 'Trámites'
    ]
    conn = op.get_bind()
    for cat in extra_categories:
        conn.execute(
            sa.text("INSERT INTO categories (name, created_at) VALUES (:name, NOW()) ON CONFLICT (name) DO NOTHING"),
            {"name": cat}
        )

    # 2. Add category_id column to transactions (nullable initially for data migration)
    op.add_column('transactions', sa.Column('category_id', sa.Integer(), nullable=True))

    # 3. Populate category_id from existing categoria text
    op.execute("""
        UPDATE transactions t
        SET category_id = c.id
        FROM categories c
        WHERE t.categoria = c.name
    """)

    # 4. Make category_id NOT NULL after population
    op.alter_column('transactions', 'category_id', nullable=False)

    # 5. Add foreign key constraint
    op.create_foreign_key(
        'transactions_category_id_fkey',
        'transactions', 'categories',
        ['category_id'], ['id']
    )

    # 6. Drop old categoria text column
    op.drop_column('transactions', 'categoria')

    # ==========================================
    # MEJORA 7: Rename transaction columns to English
    # ==========================================

    op.alter_column('transactions', 'marca_temporal', new_column_name='timestamp')
    op.alter_column('transactions', 'fecha', new_column_name='date')
    op.alter_column('transactions', 'tipo', new_column_name='type')
    op.alter_column('transactions', 'monto', new_column_name='amount')
    op.alter_column('transactions', 'necesidad', new_column_name='necessity')
    op.alter_column('transactions', 'forma_pago', new_column_name='payment_method')
    op.alter_column('transactions', 'detalle', new_column_name='detail')
    op.alter_column('transactions', 'estado_asignacion', new_column_name='assignment_status')


def downgrade() -> None:
    # Reverse column renames
    op.alter_column('transactions', 'assignment_status', new_column_name='estado_asignacion')
    op.alter_column('transactions', 'detail', new_column_name='detalle')
    op.alter_column('transactions', 'payment_method', new_column_name='forma_pago')
    op.alter_column('transactions', 'necessity', new_column_name='necesidad')
    op.alter_column('transactions', 'amount', new_column_name='monto')
    op.alter_column('transactions', 'type', new_column_name='tipo')
    op.alter_column('transactions', 'date', new_column_name='fecha')
    op.alter_column('transactions', 'timestamp', new_column_name='marca_temporal')

    # Add back categoria column
    op.add_column('transactions', sa.Column('categoria', sa.String(), nullable=True))

    # Populate from categories join
    op.execute("""
        UPDATE transactions t
        SET categoria = c.name
        FROM categories c
        WHERE t.category_id = c.id
    """)

    op.alter_column('transactions', 'categoria', nullable=False)

    # Drop category_id FK and column
    op.drop_constraint('transactions_category_id_fkey', 'transactions', type_='foreignkey')
    op.drop_column('transactions', 'category_id')
