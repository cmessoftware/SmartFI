import gspread
from google.oauth2.service_account import Credentials
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

class GoogleSheetsService:
    def __init__(self):
        self.sheet_id = os.getenv("GOOGLE_SHEET_ID")
        self.credentials_file = os.getenv("GOOGLE_CREDENTIALS_FILE", "credentials.json")
        self.client = None
        self.sheet = None
        
    def connect(self):
        """Connect to Google Sheets"""
        try:
            scopes = [
                'https://www.googleapis.com/auth/spreadsheets',
                'https://www.googleapis.com/auth/drive'
            ]
            
            creds = Credentials.from_service_account_file(
                self.credentials_file,
                scopes=scopes
            )
            
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
            for record in records:
                normalized_record = {
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
