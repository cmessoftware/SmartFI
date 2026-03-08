#!/usr/bin/env python3
"""
Migration script to transfer data from Google Sheets to PostgreSQL
Run this script to migrate existing transactions from Sprint 1&2 (Google Sheets) to Sprint 3 (PostgreSQL)
"""

import sys
import os
from dotenv import load_dotenv

load_dotenv()

# Add parent directory to path to import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.google_sheets import sheets_service
from services.database_service import database_service

def migrate_data():
    """Migrate all data from Google Sheets to PostgreSQL"""
    
    print("=" * 60)
    print("📦 FINLY DATA MIGRATION: Google Sheets → PostgreSQL")
    print("=" * 60)
    print()
    
    # Check Google Sheets connection
    if not sheets_service or not sheets_service.sheet_id:
        print("❌ Google Sheets not configured. Cannot migrate.")
        print("   Please set GOOGLE_SHEET_ID in .env file")
        return False
    
    if not sheets_service.connect():
        print("❌ Could not connect to Google Sheets")
        return False
    
    print("✅ Connected to Google Sheets")
    print(f"   Sheet ID: {sheets_service.sheet_id}")
    print()
    
    # Check PostgreSQL connection
    if not database_service or not database_service.initialized:
        print("❌ PostgreSQL not initialized. Cannot migrate.")
        print("   Please check DATABASE_URL in .env file")
        return False
    
    if not database_service.is_connected():
        print("❌ Could not connect to PostgreSQL")
        return False
    
    print("✅ Connected to PostgreSQL")
    print()
    
    # Get transactions from Google Sheets
    print("📥 Fetching transactions from Google Sheets...")
    try:
        sheets_transactions = sheets_service.get_all_transactions()
        print(f"✅ Found {len(sheets_transactions)} transactions in Google Sheets")
    except Exception as e:
        print(f"❌ Error fetching from Google Sheets: {e}")
        return False
    
    if not sheets_transactions:
        print("⚠️  No transactions to migrate")
        return True
    
    print()
    
    # Get existing transactions from PostgreSQL to avoid duplicates
    print("📥 Fetching existing transactions from PostgreSQL...")
    try:
        db_transactions = database_service.get_all_transactions()
        print(f"✅ Found {len(db_transactions)} existing transactions in PostgreSQL")
    except Exception as e:
        print(f"❌ Error fetching from PostgreSQL: {e}")
        return False
    
    # Build set of existing transaction IDs (if they have one)
    existing_ids = set()
    for t in db_transactions:
        if 'id' in t and t['id']:
            existing_ids.add(t['id'])
    
    print()
    
    # Filter new transactions
    new_transactions = []
    skipped = 0
    
    for t in sheets_transactions:
        # Check if transaction already exists
        if 'id' in t and t['id'] in existing_ids:
            skipped += 1
            continue
        
        # Ensure forma_pago field exists (for old data without it)
        if 'forma_pago' not in t:
            t['forma_pago'] = 'Débito'  # Default value for migrated data
        
        new_transactions.append(t)
    
    print(f"📊 Migration Plan:")
    print(f"   • Total in Google Sheets: {len(sheets_transactions)}")
    print(f"   • Already in PostgreSQL: {len(db_transactions)}")
    print(f"   • Duplicates to skip: {skipped}")
    print(f"   • New to migrate: {len(new_transactions)}")
    print()
    
    if not new_transactions:
        print("✅ All transactions already migrated!")
        return True
    
    # Ask for confirmation
    response = input(f"🤔 Do you want to migrate {len(new_transactions)} transactions? (yes/no): ").strip().lower()
    if response not in ['yes', 'y', 'si', 'sí']:
        print("❌ Migration cancelled by user")
        return False
    
    print()
    print("🚀 Starting migration...")
    
    # Migrate in batches
    batch_size = 100
    total_migrated = 0
    
    for i in range(0, len(new_transactions), batch_size):
        batch = new_transactions[i:i+batch_size]
        try:
            success = database_service.add_transactions_batch(batch)
            if success:
                total_migrated += len(batch)
                print(f"✅ Migrated batch {i//batch_size + 1}: {len(batch)} transactions")
            else:
                print(f"❌ Failed to migrate batch {i//batch_size + 1}")
                return False
        except Exception as e:
            print(f"❌ Error migrating batch: {e}")
            return False
    
    print()
    print("=" * 60)
    print(f"✅ MIGRATION COMPLETED!")
    print(f"   • Successfully migrated: {total_migrated} transactions")
    print(f"   • Skipped (duplicates): {skipped} transactions")
    print("=" * 60)
    print()
    print("💡 TIP: PostgreSQL is now your primary storage.")
    print("   Google Sheets will continue to work as a backup.")
    print()
    
    return True

if __name__ == "__main__":
    try:
        success = migrate_data()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n❌ Migration interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
