#!/usr/bin/env python
"""Test Google Sheets connection"""
import os
from dotenv import load_dotenv

load_dotenv()

print("🔍 Testing Google Sheets Configuration...")
print(f"GOOGLE_SHEET_ID: {os.getenv('GOOGLE_SHEET_ID')}")
print(f"GOOGLE_CREDENTIALS_FILE: {os.getenv('GOOGLE_CREDENTIALS_FILE')}")

try:
    from services.google_sheets import sheets_service
    
    if sheets_service.sheet_id:
        print(f"\n✅ Sheet ID configured: {sheets_service.sheet_id}")
        
        print("\n🔗 Attempting to connect...")
        if sheets_service.connect():
            print("✅ Connected successfully!")
            
            print("\n📋 Initializing sheet...")
            if sheets_service.initialize_sheet():
                print("✅ Sheet initialized!")
                
                print("\n📊 Reading existing data...")
                data = sheets_service.get_all_transactions()
                print(f"✅ Found {len(data)} transactions")
                
                if len(data) > 0:
                    print("\n📝 First transaction:")
                    print(data[0])
            else:
                print("❌ Failed to initialize sheet")
        else:
            print("❌ Connection failed")
    else:
        print("\n❌ GOOGLE_SHEET_ID not configured in .env")
        
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
