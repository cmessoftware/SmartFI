"""
Script para ejecutar la migración 002: Budget Model Refactor Fase A
"""
import os
from dotenv import load_dotenv
import psycopg2

load_dotenv('backend/.env')

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://admin:admin123@localhost:5432/fin_per_db")

# Leer archivo de migración
with open('backend/migrations/002_add_budget_item_columns.sql', 'r', encoding='utf-8') as f:
    migration_sql = f.read()

try:
    # Conectar a la base de datos
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    
    # Ejecutar migración
    print("🔄 Ejecutando migración 002...")
    cursor.execute(migration_sql)
    
    # Commit
    conn.commit()
    
    # Mostrar resultado
    print("✅ Migración 002 ejecutada exitosamente")
    
    # Verificar columnas agregadas
    cursor.execute("""
        SELECT column_name, data_type, column_default 
        FROM information_schema.columns 
        WHERE table_name = 'debts' 
        AND column_name IN ('tipo_presupuesto', 'tipo_flujo', 'monto_ejecutado')
        ORDER BY column_name
    """)
    
    print("\n📋 Columnas nuevas en tabla debts:")
    for row in cursor.fetchall():
        print(f"  - {row[0]}: {row[1]} (default: {row[2]})")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Error ejecutando migración: {e}")
    if conn:
        conn.rollback()
        conn.close()
