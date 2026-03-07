# Finly - Setup and Installation Guide

## Prerequisites

### Frontend
- Node.js 18 or higher
- npm or yarn

### Backend
- Python 3.9 or higher
- pip

### Database (Optional for Sprint 1 & 2)
- Docker and Docker Compose (for PostgreSQL)
- Google Sheets API credentials (see docs/configuration/GOOGLE_SHEETS_SETUP.md)

## Installation Steps

### 1. Clone the Repository
```bash
git clone <repository-url>
cd Finly
```

### 2. Setup Frontend

```bash
cd frontend
npm install
```

Copy the environment file:
```bash
cp .env.example .env
```

### 3. Setup Backend

```bash
cd backend
pip install -r requirements.txt
```

Copy the environment file:
```bash
cp .env.example .env
```

Edit `.env` and configure:
- `SECRET_KEY`: Generate a secure random key (at least 32 characters)
- `GOOGLE_SHEET_ID`: Your Google Sheet ID (if using Google Sheets)
- `GOOGLE_CREDENTIALS_FILE`: Path to credentials.json (if using Google Sheets)

### 4. Setup PostgreSQL (Optional - Sprint 3)

```bash
# From project root
docker-compose up -d
```

Verify:
```bash
docker ps
```

### 5. Copy Logo
Copy your logo file to:
```
frontend/public/logo.png
```

Or copy the existing logo from `img/logo.png` to `frontend/public/logo.png`

## Running the Application

### Option 1: Run Both Services Separately

**Terminal 1 - Backend:**
```bash
cd backend
python main.py
```
Backend will run on: http://localhost:8000

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```
Frontend will run on: http://localhost:5173

### Option 2: Use the PowerShell Start Script

From the project root:
```powershell
.\start.ps1
```

This will start both frontend and backend in separate terminal windows.

## Accessing the Application

1. Open your browser and go to: http://localhost:5173
2. Login with one of the default users:
   - **Admin**: admin / admin123
   - **Writer**: writer / writer123
   - **Reader**: reader / reader123

## Project Structure

```
Finly/
├── frontend/              # React + Vite frontend
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── services/     # API services
│   │   ├── App.jsx       # Main app component
│   │   └── main.jsx      # Entry point
│   ├── public/           # Static assets
│   └── package.json
├── backend/              # FastAPI backend
│   ├── services/         # Business logic services
│   ├── database/         # Database models and config
│   ├── main.py          # Main API file
│   └── requirements.txt
├── docs/                # Documentation
├── docker-compose.yml   # PostgreSQL container
└── README.md
```

## Features by Sprint

### Sprint 1 ✅
- JWT Authentication
- Transaction entry form
- Reports with charts (Chart.js)
- Google Sheets integration (optional)
- Admin panel for users and categories
- LocalStorage persistence

### Sprint 2 ✅
- CSV bulk import with PapaParse
- Column mapping for flexible imports
- Preview before import

### Sprint 3 🔄
- PostgreSQL integration
- Database persistence
- Migration from Google Sheets

## Troubleshooting

### Frontend issues
- Make sure Node.js 18+ is installed
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Check if port 5173 is available

### Backend issues
- Make sure Python 3.9+ is installed
- Install requirements: `pip install -r requirements.txt`
- Check if port 8000 is available
- Verify .env configuration

### CORS issues
- Backend must be running on port 8000
- Frontend must be running on port 5173
- Check CORS configuration in backend/main.py

### Google Sheets not working
- Follow the setup guide in `docs/configuration/GOOGLE_SHEETS_SETUP.md`
- Verify credentials.json is in the backend folder
- Check that the sheet is shared with the service account email

### PostgreSQL not connecting
- Make sure Docker is running
- Start the container: `docker-compose up -d`
- Check logs: `docker-compose logs postgres`
- Verify connection string in .env

## Development

### Frontend Development
```bash
cd frontend
npm run dev      # Start dev server
npm run build    # Build for production
npm run preview  # Preview production build
```

### Backend Development
```bash
cd backend
python main.py   # Start with auto-reload
```

## Building for Production

### Frontend
```bash
cd frontend
npm run build
```
Output will be in `frontend/dist/`

### Backend
The backend runs as-is with uvicorn. For production:
```bash
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## Support

For issues or questions:
1. Check the documentation in the `docs/` folder
2. Review the roadmap: `docs/ROADMAP_FINLY_V1.md`
3. Check setup guides in the backend folder

## License

[Add your license here]
