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
                transaction_data.get('timestamp', transaction_data.get('marca_temporal', datetime.now().isoformat())),
                transaction_data.get('date', transaction_data.get('fecha')),
                transaction_data.get('type', transaction_data.get('tipo')),
                transaction_data.get('category', transaction_data.get('categoria')),
                transaction_data.get('amount', transaction_data.get('monto')),
                transaction_data.get('necessity', transaction_data.get('necesidad')),
                transaction_data.get('payment_method', transaction_data.get('forma_pago', 'Débito')),
                transaction_data.get('detail', transaction_data.get('detalle', ''))
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
                    transaction.get('timestamp', transaction.get('marca_temporal', datetime.now().isoformat())),
                    transaction.get('date', transaction.get('fecha')),
                    transaction.get('type', transaction.get('tipo')),
                    transaction.get('category', transaction.get('categoria')),
                    transaction.get('amount', transaction.get('monto')),
                    transaction.get('necessity', transaction.get('necesidad')),
                    transaction.get('payment_method', transaction.get('forma_pago', 'Débito')),
                    transaction.get('detail', transaction.get('detalle', ''))
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
                # Helper to safely convert monto to float
                monto_raw = record.get('Monto', record.get('monto', 0))
                try:
                    monto = float(monto_raw) if monto_raw and str(monto_raw).strip() else 0.0
                except (ValueError, TypeError):
                    monto = 0.0
                
                normalized_record = {
                    'id': idx,  # Row number as ID
                    'timestamp': record.get('Marca temporal', record.get('marca_temporal', '')),
                    'date': record.get('Fecha', record.get('fecha', '')),
                    'type': record.get('Tipo', record.get('tipo', '')),
                    'category': record.get('Categoría', record.get('categoria', '')),
                    'amount': monto,
                    'necessity': record.get('Necesidad', record.get('necesidad', '')),
                    'payment_method': record.get('Forma de Pago', record.get('forma_pago', 'Débito')),
                    'detail': record.get('Detalle', record.get('detalle', ''))
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
                transaction_data.get('timestamp', transaction_data.get('marca_temporal', datetime.now().isoformat())),
                transaction_data.get('date', transaction_data.get('fecha')),
                transaction_data.get('type', transaction_data.get('tipo')),
                transaction_data.get('category', transaction_data.get('categoria')),
                transaction_data.get('amount', transaction_data.get('monto')),
                transaction_data.get('necessity', transaction_data.get('necesidad')),
                transaction_data.get('payment_method', transaction_data.get('forma_pago', 'Débito')),
                transaction_data.get('detail', transaction_data.get('detalle', ''))
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
    
    def clear_all_transactions(self):
        """Clear all transactions from the sheet, keeping only headers"""
        try:
            if not self.sheet:
                self.connect()
            
            # Get total rows
            all_values = self.sheet.get_all_values()
            total_rows = len(all_values)
            
            print(f"📊 Current rows in sheet: {total_rows}")
            
            if total_rows <= 1:
                # Only headers or empty, nothing to clear
                print("ℹ️ No transactions to clear (only headers)")
                return True
            
            # Delete all rows except the header (row 1)
            # Delete from row 2 to the last row in one operation
            try:
                self.sheet.delete_rows(2, total_rows)
                print(f"✅ Cleared {total_rows - 1} transaction rows from Google Sheets")
            except Exception as delete_error:
                print(f"⚠️ Error during delete_rows: {delete_error}")
                # Fallback: try clearing by updating to empty
                if total_rows > 1:
                    empty_range = f'A2:I{total_rows}'
                    empty_values = [[''] * 9 for _ in range(total_rows - 1)]
                    self.sheet.update(empty_range, empty_values)
                    print(f"✅ Cleared data using update method (fallback)")
            
            return True
        except Exception as e:
            print(f"❌ Error clearing transactions from Google Sheets: {e}")
            return False
    
    def initialize_sheet(self):
        """Create headers if sheet is empty or fix them if incorrect"""
        try:
            if not self.sheet:
                self.connect()
            
            correct_headers = [
                'Marca temporal',
                'Fecha',
                'Tipo',
                'Categoría',
                'Monto',
                'Necesidad',
                'Forma de Pago',
                'Detalle'
            ]
            
            all_values = self.sheet.get_all_values()
            
            # Check if sheet is empty
            if len(all_values) == 0:
                self.sheet.append_row(correct_headers)
                print("✅ Headers created in Google Sheets")
                return True
            
            # Check if headers are incorrect and fix them
            current_headers = all_values[0] if len(all_values) > 0 else []
            if current_headers != correct_headers:
                self.sheet.update('A1:I1', [correct_headers])
                print("✅ Headers updated in Google Sheets")
            
            return True
        except Exception as e:
            print(f"Error initializing sheet: {e}")
            return False

# Singleton instance
sheets_service = GoogleSheetsService()
