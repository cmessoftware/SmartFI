#!/usr/bin/env python
"""
Finly Database Migration Script - Local to Render
Migrates PostgreSQL data from local Docker to Render database
"""

import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse
import argparse

# Colors for terminal output
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    GRAY = '\033[90m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.CYAN}{Colors.BOLD}{text}{Colors.RESET}")

def print_success(text):
    print(f"{Colors.GREEN}✅ {text}{Colors.RESET}")

def print_warning(text):
    print(f"{Colors.YELLOW}⚠️  {text}{Colors.RESET}")

def print_error(text):
    print(f"{Colors.RED}❌ {text}{Colors.RESET}")

def print_info(text):
    print(f"{Colors.GRAY}   {text}{Colors.RESET}")

def run_command(command, check=True, capture_output=True):
    """Execute shell command and return result"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=check,
            capture_output=capture_output,
            text=True
        )
        return result
    except subprocess.CalledProcessError as e:
        if check:
            raise
        return e

def check_docker():
    """Check if Docker is running"""
    print_header("🔍 Step 1: Checking local database...")
    try:
        result = run_command('docker ps --filter "name=finly-postgres" --format "{{.Status}}"')
        if result.returncode == 0 and result.stdout.strip():
            print_success("Local PostgreSQL is running")
            return True
        else:
            print_error("Local PostgreSQL container is not running")
            print_warning("Please start it with: docker-compose up -d postgres")
            return False
    except:
        print_error("Unable to check Docker status")
        return False

def export_local_db(backup_file):
    """Export local database to SQL file"""
    print_header("📦 Step 2: Exporting local database...")
    
    local_password = "admin123"
    local_user = "admin"
    local_db = "fin_per_db"
    
    export_cmd = (
        f'docker exec -e PGPASSWORD={local_password} finly-postgres '
        f'pg_dump -h localhost -p 5432 -U {local_user} -d {local_db} '
        f'--clean --if-exists --no-owner --no-acl'
    )
    
    try:
        result = run_command(export_cmd)
        if result.returncode == 0:
            with open(backup_file, 'w', encoding='utf-8') as f:
                f.write(result.stdout)
            
            file_size = os.path.getsize(backup_file) / 1024
            print_success("Database exported successfully")
            print_info(f"File: {backup_file}")
            print_info(f"Size: {file_size:.2f} KB")
            return True
        else:
            print_error("Export failed")
            print(result.stderr)
            return False
    except Exception as e:
        print_error(f"Export error: {e}")
        return False

def get_table_count(db_url, table):
    """Get row count for a table"""
    try:
        result = run_command(
            f'psql "{db_url}" -t -c "SELECT COUNT(*) FROM {table};"',
            check=False
        )
        if result.returncode == 0:
            return result.stdout.strip()
        return "?"
    except:
        return "?"

def show_data_summary():
    """Show summary of local data"""
    print_header("📊 Step 3: Database Summary...")
    
    local_password = "admin123"
    local_user = "admin"
    local_db = "fin_per_db"
    
    tables = ['transactions', 'debts', 'categories', 'users']
    
    for table in tables:
        query_cmd = (
            f'docker exec -e PGPASSWORD={local_password} finly-postgres '
            f'psql -h localhost -p 5432 -U {local_user} -d {local_db} '
            f'-t -c "SELECT COUNT(*) FROM {table};"'
        )
        try:
            result = run_command(query_cmd, check=False)
            if result.returncode == 0:
                count = result.stdout.strip()
                print_info(f"{table.capitalize()}: {count}")
        except:
            print_info(f"{table.capitalize()}: ?")

def import_to_render(backup_file, render_url):
    """Import backup file to Render database"""
    print_header("📥 Step 4: Importing to Render database...")
    
    print_warning("WARNING: This will REPLACE all data in the Render database!")
    print()
    confirmation = input(f"{Colors.YELLOW}Continue? (yes/no): {Colors.RESET}")
    
    if confirmation.lower() != 'yes':
        print_error("Migration cancelled by user")
        return False
    
    print()
    print_info("Importing to Render...")
    
    try:
        import_cmd = f'psql "{render_url}" < "{backup_file}"'
        result = run_command(import_cmd, check=False, capture_output=False)
        
        if result.returncode == 0:
            print_success("Database imported successfully to Render!")
            return True
        else:
            print_error(f"Import failed with exit code {result.returncode}")
            return False
    except Exception as e:
        print_error(f"Import error: {e}")
        return False

def verify_migration(render_url):
    """Verify the migration was successful"""
    print_header("🔍 Step 5: Verifying migration...")
    
    try:
        result = run_command(
            f'psql "{render_url}" -t -c "SELECT COUNT(*) FROM transactions;"',
            check=False
        )
        if result.returncode == 0:
            count = result.stdout.strip()
            print_success("Verification successful")
            print_info(f"Transactions in Render: {count}")
            return True
        else:
            print_warning("Could not verify migration")
            return False
    except:
        print_warning("Verification failed")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='Migrate Finly database from local to Render'
    )
    parser.add_argument(
        '--render-url',
        type=str,
        help='Render PostgreSQL connection URL'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be done without making changes'
    )
    
    args = parser.parse_args()
    
    print(f"\n{Colors.CYAN}{Colors.BOLD}🚀 Finly Database Migration: Local → Render{Colors.RESET}")
    print(f"{Colors.CYAN}{'='*45}{Colors.RESET}\n")
    
    # Get Render URL
    render_url = args.render_url
    if not render_url:
        render_url = os.environ.get('RENDER_DATABASE_URL')
    
    if not render_url:
        print_warning("Render Database URL not provided.")
        print()
        print(f"{Colors.YELLOW}Please provide the Render PostgreSQL connection URL:{Colors.RESET}")
        print_info("Example: postgresql://user:password@host:port/database")
        print()
        render_url = input("Enter Render Database URL: ")
    
    if not render_url or not render_url.startswith('postgres'):
        print_error("Invalid PostgreSQL URL format")
        print_info("Expected format: postgresql://user:password@host:port/database")
        sys.exit(1)
    
    # Create backup directory
    script_dir = Path(__file__).parent
    backup_dir = script_dir.parent / 'backups'
    backup_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_file = backup_dir / f'local_backup_{timestamp}.sql'
    
    # Show configuration
    parsed_url = urlparse(render_url)
    masked_url = render_url.replace(f':{parsed_url.password}@', ':***@')
    
    print("📋 Migration Configuration:")
    print_info(f"Local: localhost:5433/fin_per_db")
    print_info(f"Render URL: {masked_url}")
    print_info(f"Backup File: {backup_file}")
    print()
    
    if args.dry_run:
        print_warning("DRY RUN MODE - No changes will be made")
        print()
    
    # Execute migration steps
    if not check_docker():
        sys.exit(1)
    
    if not export_local_db(backup_file):
        sys.exit(1)
    
    show_data_summary()
    
    if args.dry_run:
        print()
        print_success("DRY RUN COMPLETED - No changes were made")
        sys.exit(0)
    
    if not import_to_render(backup_file, render_url):
        sys.exit(1)
    
    verify_migration(render_url)
    
    # Success summary
    print(f"\n{Colors.CYAN}{'='*45}{Colors.RESET}")
    print_success("MIGRATION COMPLETED SUCCESSFULLY!")
    print(f"{Colors.CYAN}{'='*45}{Colors.RESET}\n")
    
    print(f"{Colors.BOLD}📁 Backup files saved in: {backup_dir}{Colors.RESET}")
    print()
    print(f"{Colors.BOLD}Next steps:{Colors.RESET}")
    print_info("1. Test your Render deployment")
    print_info("2. Verify all data is correct")
    print_info("3. Update your .env files if needed")
    print()
    print_warning("Keep the backup files for recovery if needed!")
    print()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print()
        print_error("Migration interrupted by user")
        sys.exit(1)
    except Exception as e:
        print()
        print_error(f"Unexpected error: {e}")
        sys.exit(1)
