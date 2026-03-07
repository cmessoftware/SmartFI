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

# Initialize Google Sheets
try:
    from services.google_sheets import sheets_service
    if sheets_service.sheet_id:
        if sheets_service.connect():
            sheets_service.initialize_sheet()
            print("✅ Google Sheets connected successfully")
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
    # Save to Google Sheets if configured
    success = False
    if sheets_service:
        try:
            success = sheets_service.add_transaction(transaction.dict())
            if success:
                print(f"✅ Transaction saved to Google Sheets")
            else:
                print(f"❌ Failed to save to Google Sheets")
        except Exception as e:
            print(f"❌ Error saving to Google Sheets: {e}")
    else:
        print("⚠️ Google Sheets not configured")
    
    return {"message": "Transaction created successfully", "transaction": transaction, "saved_to_sheets": success}

@app.post("/api/transactions/import")
async def import_transactions(
    transactions: List[Transaction],
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    success = False
    if sheets_service:
        try:
            success = sheets_service.add_transactions_batch([t.dict() for t in transactions])
            if success:
                print(f"✅ {len(transactions)} transactions saved to Google Sheets")
            else:
                print(f"❌ Failed to save batch to Google Sheets")
        except Exception as e:
            print(f"❌ Error saving batch to Google Sheets: {e}")
    else:
        print("⚠️ Google Sheets not configured")
    
    return {"message": f"{len(transactions)} transactions imported successfully", "saved_to_sheets": success}

@app.get("/api/transactions")
async def get_transactions(current_user: User = Depends(get_current_user)):
    # Get from Google Sheets if configured
    if sheets_service:
        try:
            transactions = sheets_service.get_all_transactions()
            print(f"✅ Retrieved {len(transactions)} transactions from Google Sheets")
            return transactions
        except Exception as e:
            print(f"❌ Error getting transactions from Google Sheets: {e}")
            return []
    else:
        print("⚠️ Google Sheets not configured")
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

@app.put("/api/transactions/{transaction_id}")
async def update_transaction(
    transaction_id: int,
    transaction: Transaction,
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    """Update an existing transaction"""
    if not sheets_service:
        raise HTTPException(status_code=503, detail="Google Sheets not configured")
    
    try:
        success = sheets_service.update_transaction(transaction_id, transaction.dict())
        if success:
            print(f"✅ Transaction {transaction_id} updated successfully")
            return {"message": "Transaction updated successfully", "transaction": transaction}
        else:
            raise HTTPException(status_code=500, detail="Failed to update transaction")
    except Exception as e:
        print(f"❌ Error updating transaction: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/transactions/{transaction_id}")
async def delete_transaction(
    transaction_id: int,
    current_user: User = Depends(require_role(["admin", "writer"]))
):
    """Delete a transaction"""
    if not sheets_service:
        raise HTTPException(status_code=503, detail="Google Sheets not configured")
    
    try:
        success = sheets_service.delete_transaction(transaction_id)
        if success:
            print(f"✅ Transaction {transaction_id} deleted successfully")
            return {"message": "Transaction deleted successfully", "id": transaction_id}
        else:
            raise HTTPException(status_code=500, detail="Failed to delete transaction")
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
