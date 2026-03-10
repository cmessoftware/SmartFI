from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from typing import Optional, List
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
import os
from dotenv import load_dotenv

load_dotenv()

# Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key-change-in-production-min-32-characters")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

app = FastAPI(title="Finly API", version="1.0.0")

# Initialize PostgreSQL Database
try:
    from services.database_service import database_service
    if database_service.is_connected():
        print("✅ PostgreSQL database connected successfully")
    else:
        print("⚠️ PostgreSQL database not connected")
        database_service = None
except Exception as e:
    print(f"⚠️ PostgreSQL database not available: {e}")
    database_service = None

# Initialize Google Sheets (optional backup)
try:
    from services.google_sheets import sheets_service
    if sheets_service.sheet_id:
        if sheets_service.connect():
            sheets_service.initialize_sheet()
            print("✅ Google Sheets connected successfully (backup)")
        else:
            print("⚠️ Google Sheets not connected")
    else:
        print("⚠️ GOOGLE_SHEET_ID not configured")
        sheets_service = None
except Exception as e:
    print(f"⚠️ Google Sheets not available: {e}")
    sheets_service = None

# CORS Configuration
# Allow both local development and production frontend
allowed_origins = [
    "http://localhost:5173",  # Local development (Vite)
    "http://localhost:5174",  # Alternative local port
    "http://localhost:3000",  # Docker frontend
]

# Add production frontend URL if configured
frontend_url = os.getenv("FRONTEND_URL")
if frontend_url:
    allowed_origins.append(frontend_url)
    print(f"✅ CORS configured for production: {frontend_url}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/api/health")
async def health_check():
    return {
        "status": "ok",
        "database_connected": database_service is not None and database_service.is_connected(),
        "google_sheets_connected": sheets_service is not None and sheets_service.sheet is not None,
        "sheet_id": sheets_service.sheet_id if sheets_service else None
    }

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")

# Models
class User(BaseModel):
    username: str
    role: str
    full_name: Optional[str] = None

class UserInDB(User):
    hashed_password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user: User

class Transaction(BaseModel):
    id: Optional[int] = None
    marca_temporal: Optional[str] = None
    fecha: str
    tipo: str
    categoria: str
    monto: float
    necesidad: str
    forma_pago: str = "Débito"
    partida: str
    detalle: str

# Hardcoded users database
fake_users_db = {
    "admin": {
        "username": "admin",
        "full_name": "Administrador",
        "role": "admin",
        "hashed_password": pwd_context.hash("admin123")
    },
    "writer": {
        "username": "writer",
        "full_name": "Editor",
        "role": "writer",
        "hashed_password": pwd_context.hash("writer123")
    },
    "reader": {
        "username": "reader",
        "full_name": "Lector",
        "role": "reader",
        "hashed_password": pwd_context.hash("reader123")
    }
}

# Helper functions
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_user(username: str):
    if username in fake_users_db:
        user_dict = fake_users_db[username]
        return UserInDB(**user_dict)

def authenticate_user(username: str, password: str):
    user = get_user(username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = get_user(username)
    if user is None:
        raise credentials_exception
    return User(username=user.username, role=user.role, full_name=user.full_name)

def require_role(required_roles: List[str]):
    def role_checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in required_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions"
            )
        return current_user
    return role_checker

# Routes
@app.get("/")
async def root():
    return {"message": "Finly API v1.0.0"}

@app.post("/api/auth/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role}, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": User(username=user.username, role=user.role, full_name=user.full_name)
    }

@app.get("/api/auth/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

@app.get("/api/categories")
async def get_categories(current_user: User = Depends(get_current_user)):
    return [
        "Ahorro", "Comida", "Cuidado Personal", "Tarjeta VISA",
        "Educación", "Alquiler", "Hogar", "Impuestos",
        "Ingresos", "Ocio", "Préstamos", "Ropa",
        "Salud", "Seguros", "Servicios", "Trámites", "Transporte"
    ]

@app.get("/api/transaction-types")
async def get_transaction_types(current_user: User = Depends(get_current_user)):
    return ["Gasto", "Ingreso"]

@app.get("/api/necessity-types")
async def get_necessity_types(current_user: User = Depends(get_current_user)):
    return ["Necesario", "Superfluo", "Importante pero no urgente"]

# Transaction routes
@app.post("/api/transactions")
async def create_transaction(
    transaction: Transaction,
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    # Save to PostgreSQL (primary storage)
    transaction_id = None
    if database_service:
        try:
            transaction_id = database_service.add_transaction(transaction.dict())
            if transaction_id:
                print(f"✅ Transaction {transaction_id} saved to PostgreSQL")
            else:
                print(f"❌ Failed to save to PostgreSQL")
        except Exception as e:
            print(f"❌ Error saving to PostgreSQL: {e}")
    
    # Also save to Google Sheets as backup if configured
    sheets_success = False
    if sheets_service and transaction_id:
        try:
            sheets_success = sheets_service.add_transaction(transaction.dict())
            if sheets_success:
                print(f"✅ Transaction also saved to Google Sheets (backup)")
        except Exception as e:
            print(f"⚠️ Could not save to Google Sheets backup: {e}")
    
    if transaction_id:
        return {
            "message": "Transaction created successfully",
            "transaction": transaction,
            "id": transaction_id,
            "saved_to_sheets": sheets_success
        }
    else:
        raise HTTPException(status_code=500, detail="Failed to save transaction")

@app.post("/api/transactions/import")
async def import_transactions(
    transactions: List[Transaction],
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    # Save to PostgreSQL (primary storage)
    success = False
    if database_service:
        try:
            success = database_service.add_transactions_batch([t.dict() for t in transactions])
            if success:
                print(f"✅ {len(transactions)} transactions saved to PostgreSQL")
            else:
                print(f"❌ Failed to save batch to PostgreSQL")
        except Exception as e:
            print(f"❌ Error saving batch to PostgreSQL: {e}")
    
    # Also save to Google Sheets as backup if configured
    sheets_success = False
    if sheets_service and success:
        try:
            sheets_success = sheets_service.add_transactions_batch([t.dict() for t in transactions])
            if sheets_success:
                print(f"✅ {len(transactions)} transactions also saved to Google Sheets (backup)")
        except Exception as e:
            print(f"⚠️ Could not save to Google Sheets backup: {e}")
    
    if success:
        return {
            "message": f"{len(transactions)} transactions imported successfully",
            "saved_to_sheets": sheets_success
        }
    else:
        raise HTTPException(status_code=500, detail="Failed to import transactions")

@app.get("/api/transactions")
async def get_transactions(current_user: User = Depends(get_current_user)):
    # Get from PostgreSQL (primary storage)
    if database_service:
        try:
            transactions = database_service.get_all_transactions()
            print(f"✅ Retrieved {len(transactions)} transactions from PostgreSQL")
            return transactions
        except Exception as e:
            print(f"❌ Error getting transactions from PostgreSQL: {e}")
            # Fallback to Google Sheets if database fails
            if sheets_service:
                try:
                    transactions = sheets_service.get_all_transactions()
                    print(f"✅ Retrieved {len(transactions)} transactions from Google Sheets (fallback)")
                    return transactions
                except Exception as e2:
                    print(f"❌ Error getting transactions from Google Sheets: {e2}")
            return []
    else:
        print("⚠️ PostgreSQL not configured")
        return []

@app.post("/api/transactions/migrate")
async def migrate_transactions(
    transactions: List[Transaction],
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    """Migrate transactions from localStorage to Google Sheets"""
    if not sheets_service:
        raise HTTPException(status_code=503, detail="Google Sheets not configured")
    
    try:
        # Get existing transactions to avoid duplicates
        existing = sheets_service.get_all_transactions()
        existing_ids = set()
        
        # Try to extract IDs from existing transactions
        for t in existing:
            if 'id' in t:
                existing_ids.add(t['id'])
        
        # Filter out duplicates
        new_transactions = []
        for t in transactions:
            t_dict = t.dict() if hasattr(t, 'dict') else t
            if 'id' in t_dict and t_dict['id'] not in existing_ids:
                new_transactions.append(t_dict)
            elif 'id' not in t_dict:
                new_transactions.append(t_dict)
        
        if len(new_transactions) > 0:
            success = sheets_service.add_transactions_batch(new_transactions)
            if success:
                print(f"✅ Migrated {len(new_transactions)} new transactions to Google Sheets")
                return {
                    "message": f"Successfully migrated {len(new_transactions)} transactions",
                    "migrated_count": len(new_transactions),
                    "skipped_count": len(transactions) - len(new_transactions)
                }
            else:
                raise HTTPException(status_code=500, detail="Failed to save to Google Sheets")
        else:
            return {
                "message": "All transactions already exist in Google Sheets",
                "migrated_count": 0,
                "skipped_count": len(transactions)
            }
    except Exception as e:
        print(f"❌ Error migrating transactions: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/transactions/sync-from-sheets")
async def sync_from_sheets(
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    """Sync transactions from Google Sheets to PostgreSQL"""
    if not sheets_service:
        raise HTTPException(status_code=503, detail="Google Sheets not configured")
    
    if not database_service:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    try:
        # Get transactions from Google Sheets
        print("📥 Fetching transactions from Google Sheets...")
        sheets_transactions = sheets_service.get_all_transactions()
        print(f"✅ Found {len(sheets_transactions)} transactions in Google Sheets")
        
        if not sheets_transactions:
            return {
                "message": "No transactions found in Google Sheets",
                "synced_count": 0,
                "skipped_count": 0
            }
        
        # Get existing transactions from PostgreSQL to avoid duplicates
        print("📥 Fetching existing transactions from PostgreSQL...")
        db_transactions = database_service.get_all_transactions()
        print(f"✅ Found {len(db_transactions)} existing transactions in PostgreSQL")
        
        # Build set of existing transaction fingerprints (fecha + monto + categoria)
        # Since Google Sheets IDs are row numbers, we can't rely on them
        existing_fingerprints = set()
        for t in db_transactions:
            fingerprint = f"{t.get('fecha')}_{t.get('monto')}_{t.get('categoria')}_{t.get('detalle', '')}"
            existing_fingerprints.add(fingerprint)
        
        # Filter new transactions
        new_transactions = []
        skipped = 0
        
        for t in sheets_transactions:
            # Create fingerprint
            fingerprint = f"{t.get('fecha')}_{t.get('monto')}_{t.get('categoria')}_{t.get('detalle', '')}"
            
            if fingerprint in existing_fingerprints:
                skipped += 1
                continue
            
            # Ensure forma_pago field exists
            if 'forma_pago' not in t:
                t['forma_pago'] = 'Débito'  # Default value
            
            new_transactions.append(t)
        
        # Save new transactions to PostgreSQL
        if new_transactions:
            print(f"💾 Saving {len(new_transactions)} new transactions to PostgreSQL...")
            saved_count = 0
            
            for t in new_transactions:
                try:
                    # Remove the row ID from sheets as it shouldn't be used in DB
                    t_copy = t.copy()
                    if 'id' in t_copy:
                        del t_copy['id']
                    
                    success = database_service.save_transaction(t_copy)
                    if success:
                        saved_count += 1
                except Exception as e:
                    print(f"⚠️ Error saving transaction: {e}")
                    continue
            
            print(f"✅ Synced {saved_count} new transactions from Google Sheets to PostgreSQL")
            return {
                "message": f"Successfully synced {saved_count} transactions from Google Sheets",
                "synced_count": saved_count,
                "skipped_count": skipped,
                "total_sheets": len(sheets_transactions),
                "total_db": len(db_transactions) + saved_count
            }
        else:
            return {
                "message": "All Google Sheets transactions already exist in PostgreSQL",
                "synced_count": 0,
                "skipped_count": skipped,
                "total_sheets": len(sheets_transactions),
                "total_db": len(db_transactions)
            }
            
    except Exception as e:
        print(f"❌ Error syncing from Google Sheets: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/transactions/{transaction_id}")
async def update_transaction(
    transaction_id: int,
    transaction: Transaction,
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    """Update an existing transaction"""
    if not database_service:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    try:
        success = database_service.update_transaction(transaction_id, transaction.dict())
        if success:
            print(f"✅ Transaction {transaction_id} updated in PostgreSQL")
            
            # Also update in Google Sheets if configured
            if sheets_service:
                try:
                    sheets_service.update_transaction(transaction_id, transaction.dict())
                    print(f"✅ Transaction {transaction_id} also updated in Google Sheets (backup)")
                except Exception as e:
                    print(f"⚠️ Could not update in Google Sheets backup: {e}")
            
            return {"message": "Transaction updated successfully", "transaction": transaction}
        else:
            raise HTTPException(status_code=404, detail="Transaction not found")
    except Exception as e:
        print(f"❌ Error updating transaction: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/transactions/{transaction_id}")
async def delete_transaction(
    transaction_id: int,
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    """Delete a transaction"""
    if not database_service:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    try:
        success = database_service.delete_transaction(transaction_id)
        if success:
            print(f"✅ Transaction {transaction_id} deleted from PostgreSQL")
            
            # Also delete from Google Sheets if configured
            if sheets_service:
                try:
                    sheets_service.delete_transaction(transaction_id)
                    print(f"✅ Transaction {transaction_id} also deleted from Google Sheets (backup)")
                except Exception as e:
                    print(f"⚠️ Could not delete from Google Sheets backup: {e}")
            
            return {"message": "Transaction deleted successfully", "id": transaction_id}
        else:
            raise HTTPException(status_code=404, detail="Transaction not found")
    except Exception as e:
        print(f"❌ Error deleting transaction: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Admin routes
@app.get("/api/admin/users")
async def get_users(current_user: User = Depends(require_role(["admin"]))):
    users = [
        {"username": u.username, "full_name": u.full_name, "role": u.role}
        for u in fake_users_db.values()
    ]
    return users

@app.post("/api/admin/users")
async def create_user(
    username: str,
    full_name: str,
    role: str,
    password: str,
    current_user: User = Depends(require_role(["admin"]))
):
    if username in fake_users_db:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    fake_users_db[username] = {
        "username": username,
        "full_name": full_name,
        "role": role,
        "hashed_password": pwd_context.hash(password)
    }
    return {"message": "User created successfully"}

@app.put("/api/admin/users/{username}")
async def update_user(
    username: str,
    full_name: str,
    role: str,
    current_user: User = Depends(require_role(["admin"]))
):
    if username not in fake_users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    fake_users_db[username]["full_name"] = full_name
    fake_users_db[username]["role"] = role
    return {"message": "User updated successfully"}

@app.delete("/api/admin/users/{username}")
async def delete_user(
    username: str,
    current_user: User = Depends(require_role(["admin"]))
):
    if username == "admin":
        raise HTTPException(status_code=400, detail="Cannot delete admin user")
    
    if username not in fake_users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    del fake_users_db[username]
    return {"message": "User deleted successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
