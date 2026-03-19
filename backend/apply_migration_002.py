"""
Script para aplicar la migración 002: Eliminar campo partida
"""
import psycopg2
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def apply_migration():
    """Apply migration 002 - Remove partida field"""
    try:
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=os.getenv('DB_PORT', '5432'),
            database=os.getenv('DB_NAME', 'finly'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD')
        )
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("Aplicando migración 002: Eliminar campo partida...")
        
        # Read and execute migration
        with open('migrations/002_remove_partida_field.sql', 'r', encoding='utf-8') as f:
            sql = f.read()
        
        cursor.execute(sql)
        
        print("✅ Migración 002 aplicada exitosamente")
        print("   - Campo 'partida' eliminado de tabla transactions")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error aplicando migración: {e}")
        raise

if __name__ == "__main__":
    apply_migration()
