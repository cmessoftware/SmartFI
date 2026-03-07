from services.google_sheets import sheets_service
import json

print("Conectando a Google Sheets...")
if sheets_service.connect():
    print("✅ Conectado")
    
    print("\nObteniendo transacciones...")
    data = sheets_service.get_all_transactions()
    
    print(f"\n📊 Total transacciones: {len(data)}")
    print("\n" + "="*60)
    
    for i, trans in enumerate(data, 1):
        print(f"\nTransacción {i}:")
        print(json.dumps(trans, indent=2, ensure_ascii=False))
        print("-"*60)
else:
    print("❌ No se pudo conectar")
