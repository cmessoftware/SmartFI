"""
Script para hacer backup de la base de datos PostgreSQL
Genera un archivo con formato: <nombre_base>_YYYYMMDD.backup
"""
import os
import subprocess
from datetime import datetime
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

def create_backup():
    """Crea un backup de la base de datos"""
    try:
        # Obtener parámetros de conexión
        db_params = get_db_params()
        
        # Crear carpeta backup si no existe
        backup_dir = Path(__file__).parent.parent / 'backup'
        backup_dir.mkdir(exist_ok=True)
        
        # Generar nombre del archivo de backup
        date_str = datetime.now().strftime('%Y%m%d')
        backup_filename = f"{db_params['database']}_{date_str}.backup"
        backup_path = backup_dir / backup_filename
        
        # Comando pg_dump
        cmd = [
            'pg_dump',
            '-h', db_params['host'],
            '-p', str(db_params['port']),
            '-U', db_params['user'],
            '-F', 'c',  # Formato custom (comprimido)
            '-b',  # Incluir blobs
            '-v',  # Verbose
            '-f', str(backup_path),
            db_params['database']
        ]
        
        # Establecer variable de entorno para la contraseña
        env = os.environ.copy()
        env['PGPASSWORD'] = db_params['password']
        
        print(f"🔄 Iniciando backup de la base de datos '{db_params['database']}'...")
        print(f"📁 Destino: {backup_path}")
        
        # Ejecutar pg_dump
        result = subprocess.run(
            cmd,
            env=env,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            file_size = backup_path.stat().st_size / (1024 * 1024)  # MB
            print(f"✅ Backup completado exitosamente")
            print(f"📦 Archivo: {backup_filename}")
            print(f"💾 Tamaño: {file_size:.2f} MB")
            return str(backup_path)
        else:
            print(f"❌ Error al crear backup:")
            print(result.stderr)
            return None
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

if __name__ == '__main__':
    backup_file = create_backup()
    if backup_file:
        print(f"\n✨ Backup guardado en: {backup_file}")
    else:
        print("\n⚠️ El backup falló. Verifica los logs anteriores.")
        exit(1)
