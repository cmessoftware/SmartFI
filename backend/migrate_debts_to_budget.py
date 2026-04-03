"""
Script to rename debts table to budget_items
Run this script once to migrate the database
"""
from database.database import engine
from sqlalchemy import text

def migrate():
    print("🔄 Starting migration: debts → budget_items")
    
    with engine.connect() as conn:
        # Check if debts table exists
        result = conn.execute(text("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'debts'
            );
        """))
        debts_exists = result.scalar()
        
        # Check if budget_items already exists
        result = conn.execute(text("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'budget_items'
            );
        """))
        budget_items_exists = result.scalar()
        
        if budget_items_exists:
            print("✅ Table 'budget_items' already exists. Migration already applied.")
            return
        
        if not debts_exists:
            print("⚠️  Table 'debts' does not exist. Nothing to migrate.")
            return
        
        # Rename the table
        print("📝 Renaming table debts → budget_items...")
        conn.execute(text("ALTER TABLE debts RENAME TO budget_items;"))
        conn.commit()
        
        print("✅ Migration completed successfully!")
        print("   Table 'debts' renamed to 'budget_items'")
        
        # Verify
        result = conn.execute(text("SELECT COUNT(*) FROM budget_items;"))
        count = result.scalar()
        print(f"   Records in budget_items: {count}")

if __name__ == "__main__":
    migrate()
