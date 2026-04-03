"""
Script para restaurar la base de datos PostgreSQL desde un archivo de backup
Uso: python restore_database.py <nombre_archivo_backup>
Ejemplo: python restore_database.py fin_per_db_20260326.backup
"""
import os
import sys
import subprocess
from pathlib import Path
from urllib.parse import urlparse
from dotenv import load_dotenv

def get_db_params():
    """Extrae los parámetros de conexión desde DATABASE_URL en .env"""
    # Cargar variables de entorno desde .env en la raíz del proyecto
    env_path = Path(__file__).parent.parent / '.env'
    load_dotenv(env_path)
    
    database_url = os.getenv('DATABASE_URL')
    if not database_url:
        raise ValueError("DATABASE_URL no encontrada en .env")
    
    # Parsear la URL: postgresql://user:password@host:port/dbname
    parsed = urlparse(database_url)
    
    return {
        'host': parsed.hostname,
        'port': parsed.port or 5432,
        'user': parsed.username,
        'password': parsed.password,
        'database': parsed.path.lstrip('/')
    }

def restore_backup(backup_filename):
    """Restaura la base de datos desde un archivo de backup"""
    try:
        # Obtener parámetros de conexión
        db_params = get_db_params()
        
        # Buscar archivo de backup
        backup_dir = Path(__file__).parent.parent / 'backup'
        backup_path = backup_dir / backup_filename
        
        if not backup_path.exists():
            print(f"❌ Error: El archivo de backup no existe: {backup_path}")
            return False
        
        # Advertencia
        print(f"⚠️  ADVERTENCIA: Esta operación restaurará la base de datos '{db_params['database']}'")
        print(f"📁 Desde el archivo: {backup_filename}")
        print(f"🗄️  Servidor: {db_params['host']}:{db_params['port']}")
        
        confirm = input("\n¿Estás seguro de continuar? (escribe 'SI' para confirmar): ")
        if confirm != 'SI':
            print("❌ Operación cancelada por el usuario")
            return False
        
        # Comando pg_restore
        cmd = [
            'pg_restore',
            '-h', db_params['host'],
            '-p', str(db_params['port']),
            '-U', db_params['user'],
            '-d', db_params['database'],
            '-c',  # Clean (drop) database objects before recreating
            '-v',  # Verbose
            str(backup_path)
        ]
        
        # Establecer variable de entorno para la contraseña
        env = os.environ.copy()
        env['PGPASSWORD'] = db_params['password']
        
        print(f"\n🔄 Iniciando restore de la base de datos...")
        
        # Ejecutar pg_restore
        result = subprocess.run(
            cmd,
            env=env,
            capture_output=True,
            text=True
        )
        
        # pg_restore puede retornar warnings pero completarse exitosamente
        if result.returncode == 0 or 'error' not in result.stderr.lower():
            print(f"✅ Restore completado exitosamente")
            print(f"🗄️  Base de datos '{db_params['database']}' restaurada desde {backup_filename}")
            return True
        else:
            print(f"❌ Error al restaurar backup:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

def list_available_backups():
    """Lista los archivos de backup disponibles"""
    backup_dir = Path(__file__).parent.parent / 'backup'
    if not backup_dir.exists():
        return []
    
    backups = sorted(backup_dir.glob('*.backup'), reverse=True)
    return [b.name for b in backups]

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("❌ Error: Debes proporcionar el nombre del archivo de backup")
        print("\nUso: python restore_database.py <nombre_archivo_backup>")
        print("\nArchivos de backup disponibles:")
        
        backups = list_available_backups()
        if backups:
            for i, backup in enumerate(backups, 1):
                backup_path = Path(__file__).parent.parent / 'backup' / backup
                size_mb = backup_path.stat().st_size / (1024 * 1024)
                print(f"  {i}. {backup} ({size_mb:.2f} MB)")
        else:
            print("  (No hay backups disponibles)")
        
        print("\nEjemplo: python restore_database.py fin_per_db_20260326.backup")
        exit(1)
    
    backup_filename = sys.argv[1]
    success = restore_backup(backup_filename)
    
    if not success:
        exit(1)
