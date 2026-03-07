import gspread
from google.oauth2.service_account import Credentials
from datetime import datetime
import os
import json
from dotenv import load_dotenv

load_dotenv()

class GoogleSheetsService:
    def __init__(self):
        self.sheet_id = os.getenv("GOOGLE_SHEET_ID")
        self.credentials_file = os.getenv("GOOGLE_CREDENTIALS_FILE", "credentials.json")
        self.credentials_json = os.getenv("GOOGLE_CREDENTIALS_JSON")  # New: JSON string from env
        self.client = None
        self.sheet = None
        
    def connect(self):
        """Connect to Google Sheets"""
        try:
            scopes = [
                'https://www.googleapis.com/auth/spreadsheets',
                'https://www.googleapis.com/auth/drive'
            ]
            
            # Try to load from JSON environment variable first (for cloud deployments)
            if self.credentials_json:
                try:
                    creds_dict = json.loads(self.credentials_json)
                    creds = Credentials.from_service_account_info(creds_dict, scopes=scopes)
                except json.JSONDecodeError as e:
                    print(f"Error parsing GOOGLE_CREDENTIALS_JSON: {e}")
                    return False
            # Fallback to file (for local development)
            elif os.path.exists(self.credentials_file):
                creds = Credentials.from_service_account_file(
                    self.credentials_file,
                    scopes=scopes
                )
            else:
                print(f"No Google credentials found (file: {self.credentials_file} or env: GOOGLE_CREDENTIALS_JSON)")
                return False
            
            self.client = gspread.authorize(creds)
            self.sheet = self.client.open_by_key(self.sheet_id).sheet1
            return True
        except Exception as e:
            print(f"Error connecting to Google Sheets: {e}")
            return False
    
    def add_transaction(self, transaction_data):
        """Add a single transaction to the sheet"""
        try:
            if not self.sheet:
                self.connect()
            
            row = [
                transaction_data.get('marca_temporal', datetime.now().isoformat()),
                transaction_data.get('fecha'),
                transaction_data.get('tipo'),
                transaction_data.get('categoria'),
                transaction_data.get('monto'),
                transaction_data.get('necesidad'),
                transaction_data.get('partida'),
                transaction_data.get('detalle', '')
            ]
            
            self.sheet.append_row(row)
            return True
        except Exception as e:
            print(f"Error adding transaction to Google Sheets: {e}")
            return False
    
    def add_transactions_batch(self, transactions):
        """Add multiple transactions to the sheet"""
        try:
            if not self.sheet:
                self.connect()
            
            rows = []
            for transaction in transactions:
                row = [
                    transaction.get('marca_temporal', datetime.now().isoformat()),
                    transaction.get('fecha'),
                    transaction.get('tipo'),
                    transaction.get('categoria'),
                    transaction.get('monto'),
                    transaction.get('necesidad'),
                    transaction.get('partida'),
                    transaction.get('detalle', '')
                ]
                rows.append(row)
            
            self.sheet.append_rows(rows)
            return True
        except Exception as e:
            print(f"Error adding batch transactions to Google Sheets: {e}")
            return False
    
    def get_all_transactions(self):
        """Get all transactions from the sheet"""
        try:
            if not self.sheet:
                self.connect()
            
            records = self.sheet.get_all_records()
            
            # Normalize column names from Spanish headers to expected format
            normalized = []
            for idx, record in enumerate(records, start=2):  # Start at 2 (row 1 is headers)
                normalized_record = {
                    'id': idx,  # Row number as ID
                    'marca_temporal': record.get('Marca temporal', record.get('marca_temporal', '')),
                    'fecha': record.get('Fecha', record.get('fecha', '')),
                    'tipo': record.get('Tipo', record.get('tipo', '')),
                    'categoria': record.get('Categoría', record.get('categoria', '')),
                    'monto': float(record.get('Monto', record.get('monto', 0))),
                    'necesidad': record.get('Necesidad', record.get('necesidad', '')),
                    'partida': record.get('Partida', record.get('partida', '')),
                    'detalle': record.get('Detalle', record.get('detalle', ''))
                }
                normalized.append(normalized_record)
            
            return normalized
        except Exception as e:
            print(f"Error getting transactions from Google Sheets: {e}")
            return []
    
    def update_transaction(self, row_id, transaction_data):
        """Update a transaction in the sheet by row ID"""
        try:
            if not self.sheet:
                self.connect()
            
            # Row ID is the actual row number in the sheet (includes header row)
            row_values = [
                transaction_data.get('marca_temporal', datetime.now().isoformat()),
                transaction_data.get('fecha'),
                transaction_data.get('tipo'),
                transaction_data.get('categoria'),
                transaction_data.get('monto'),
                transaction_data.get('necesidad'),
                transaction_data.get('partida'),
                transaction_data.get('detalle', '')
            ]
            
            # Update the specific row
            self.sheet.update(f'A{row_id}:H{row_id}', [row_values])
            print(f"✅ Transaction updated at row {row_id}")
            return True
        except Exception as e:
            print(f"Error updating transaction in Google Sheets: {e}")
            return False
    
    def delete_transaction(self, row_id):
        """Delete a transaction from the sheet by row ID"""
        try:
            if not self.sheet:
                self.connect()
            
            # Delete the specific row
            self.sheet.delete_rows(row_id)
            print(f"✅ Transaction deleted from row {row_id}")
            return True
        except Exception as e:
            print(f"Error deleting transaction from Google Sheets: {e}")
            return False
    
    def initialize_sheet(self):
        """Create headers if sheet is empty"""
        try:
            if not self.sheet:
                self.connect()
            
            headers = [
                'Marca temporal',
                'Fecha',
                'Tipo',
                'Categoría',
                'Monto',
                'Necesidad',
                'Partida',
                'Detalle'
            ]
            
            # Check if sheet is empty
            if len(self.sheet.get_all_values()) == 0:
                self.sheet.append_row(headers)
                return True
            return True
        except Exception as e:
            print(f"Error initializing sheet: {e}")
            return False

# Singleton instance
sheets_service = GoogleSheetsService()
