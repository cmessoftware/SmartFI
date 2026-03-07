#!/usr/bin/env python
"""
Script para migrar datos de localStorage a Google Sheets
Copia y pega el contenido del localStorage en el array de transactions abajo.
"""

import sys
import json
from services.google_sheets import sheets_service

def migrate_transactions(transactions_json):
    """Migrate transactions from localStorage to Google Sheets"""
    
    try:
        # Parse JSON
        transactions = json.loads(transactions_json)
        print(f"📦 Found {len(transactions)} transactions to migrate")
        
        # Connect to Google Sheets
        if not sheets_service.sheet_id:
            print("❌ GOOGLE_SHEET_ID not configured")
            return False
            
        if not sheets_service.connect():
            print("❌ Failed to connect to Google Sheets")
            return False
            
        print("✅ Connected to Google Sheets")
        
        # Initialize sheet
        sheets_service.initialize_sheet()
        
        # Add transactions in batches
        batch_size = 50
        for i in range(0, len(transactions), batch_size):
            batch = transactions[i:i+batch_size]
            if sheets_service.add_transactions_batch(batch):
                print(f"✅ Migrated batch {i//batch_size + 1} ({len(batch)} transactions)")
            else:
                print(f"❌ Failed to migrate batch {i//batch_size + 1}")
                return False
        
        print(f"\n✅ Successfully migrated {len(transactions)} transactions to Google Sheets!")
        return True
        
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON: {e}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("  MIGRACIÓN DE DATOS DE LOCALSTORAGE A GOOGLE SHEETS")
    print("=" * 60)
    print()
    print("Instrucciones:")
    print("1. Abre el navegador y ve a la aplicación Finly")
    print("2. Abre las DevTools (F12)")
    print("3. Ve a la pestaña 'Console'")
    print("4. Ejecuta: console.log(JSON.stringify(JSON.parse(localStorage.getItem('transactions'))))")
    print("5. Copia el resultado (el array JSON)")
    print("6. Pégalo abajo cuando se te pida")
    print()
    print("O guarda el JSON en un archivo y pásalo como argumento:")
    print("  python migrate_localstorage.py <archivo.json>")
    print()
    print("-" * 60)
    
    if len(sys.argv) > 1:
        # Read from file
        try:
            with open(sys.argv[1], 'r', encoding='utf-8') as f:
                transactions_json = f.read()
            print(f"📄 Reading from file: {sys.argv[1]}")
            migrate_transactions(transactions_json)
        except FileNotFoundError:
            print(f"❌ File not found: {sys.argv[1]}")
    else:
        # Interactive mode
        print("Pega el JSON del localStorage y presiona Enter dos veces:")
        print()
        lines = []
        while True:
            try:
                line = input()
                if line.strip() == "" and len(lines) > 0:
                    break
                lines.append(line)
            except EOFError:
                break
        
        transactions_json = '\n'.join(lines)
        
        if transactions_json.strip():
            migrate_transactions(transactions_json)
        else:
            print("❌ No data provided")
