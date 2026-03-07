# Google Sheets Credentials Configuration

This file explains how to set up Google Sheets API credentials for the Finly application.

## Steps to Configure Google Sheets

### 1. Create a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (e.g., "Finly Finance App")
3. Enable the Google Sheets API and Google Drive API

### 2. Create Service Account
1. Go to "IAM & Admin" > "Service Accounts"
2. Click "Create Service Account"
3. Name it (e.g., "finly-service-account")
4. Grant it the role "Editor"
5. Click "Create Key" and download the JSON file
6. Save it as `credentials.json` in the backend folder

### 3. Create Google Sheet
1. Create a new Google Sheet
2. Copy the Sheet ID from the URL (the long string between `/d/` and `/edit`)
   - Example: `https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID_HERE/edit`
3. Share the sheet with the service account email (found in credentials.json)
   - Give "Editor" permissions

### 4. Configure Environment Variables
In your `.env` file in the backend folder, set:
```
GOOGLE_SHEET_ID=your-sheet-id-here
GOOGLE_CREDENTIALS_FILE=credentials.json
```

### 5. Sheet Structure
The sheet should have the following columns (will be auto-created if empty):
- Marca temporal
- Fecha
- Tipo
- Categoría
- Monto
- Necesidad
- Partida
- Detalle

## Testing the Connection
Run the backend server and the system will attempt to initialize the sheet with headers if it's empty.

## Security Notes
- Never commit `credentials.json` to version control
- The `.gitignore` file already excludes this file
- Keep your service account credentials secure
