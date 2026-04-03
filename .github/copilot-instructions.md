# Finly - Copilot Instructions

## Database Migrations

**All database schema changes (DDL) and data migrations (DML) MUST be done using Alembic.**

- Never use raw SQL files for migrations.
- Never use `psycopg2` or direct SQL to alter tables, create tables, or modify data in migrations.
- All migrations go in `backend/alembic/versions/`.
- Run migrations from the `backend/` directory with `alembic upgrade head`.
- To create a new migration: `alembic revision --autogenerate -m "description"` or manually create the revision file.
- The Alembic `env.py` reads `DATABASE_URL` from `.env` (default: `postgresql://admin:admin123@localhost:5433/fin_per_db`).
- Models are defined in `backend/database/database.py` — always update the model first, then generate the migration.

## Project Structure

- **Backend**: FastAPI + SQLAlchemy, conda env `finly`, port 8000
- **Frontend**: Vite + React, port 5173
- **Database**: PostgreSQL in Docker container `finly-postgres`, port 5432 (mapped from 5433 inside)
- **ORM**: SQLAlchemy with `SessionLocal()` pattern

## Coding Conventions

- Currency amounts use `Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' })` in frontend.
- Backend services follow singleton pattern (e.g., `CreditCardService`).
- API endpoints are in `backend/main.py`.
- Frontend API client is in `frontend/src/services/api.js`.
