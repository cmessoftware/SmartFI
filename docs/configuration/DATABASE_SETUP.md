
# PostgreSQL Database Setup

This guide explains how to set up and use PostgreSQL with Docker for the Finly application.

## Quick Start with Docker

### 1. Start PostgreSQL Container
```bash
docker-compose up -d
```

This will:
- Create a PostgreSQL container
- Database: `fin_per_db`
- User: `admin`
- Password: `admin123`
- Port: `5432`

### 2. Verify the Container is Running
```bash
docker ps
```

You should see `finly-postgres` in the list.

### 3. Initialize the Database
The database tables will be created automatically when you start the FastAPI backend.

To manually initialize:
```bash
cd backend
python -c "from database.database import init_db; init_db()"
```

## Database Connection

The connection string is configured in `.env`:
```
DATABASE_URL=postgresql://admin:admin123@localhost:5432/fin_per_db
```

## Database Schema

### Tables

#### transactions
- id (Primary Key)
- marca_temporal (DateTime)
- fecha (String)
- tipo (Enum: Gasto, Ingreso)
- categoria (String)
- monto (Float)
- necesidad (Enum: Necesario, Superfluo, Importante pero no urgente)
- partida (String)
- detalle (String, max 50 chars)
- created_at (DateTime)

#### categories
- id (Primary Key)
- name (String, unique)
- created_at (DateTime)

#### users
- id (Primary Key)
- username (String, unique)
- full_name (String)
- role (String)
- hashed_password (String)
- created_at (DateTime)

## Useful Commands

### Stop the Container
```bash
docker-compose down
```

### Stop and Remove All Data
```bash
docker-compose down -v
```

### Access PostgreSQL CLI
```bash
docker exec -it finly-postgres psql -U admin -d fin_per_db
```

### View Logs
```bash
docker-compose logs -f postgres
```

## Connect with Database Client

You can use any PostgreSQL client (pgAdmin, DBeaver, DataGrip, etc.):
- Host: `localhost`
- Port: `5432`
- Database: `fin_per_db`
- Username: `admin`
- Password: `admin123`

## Migration from Google Sheets (Sprint 3)

When migrating from Google Sheets to PostgreSQL:
1. The backend will support both data sources
2. New transactions will be saved to both Google Sheets and PostgreSQL
3. Existing Google Sheets data can be imported using a migration script
