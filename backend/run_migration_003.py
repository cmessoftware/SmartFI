import psycopg2

conn = psycopg2.connect(
    dbname='fin_per_db', 
    user='admin', 
    password='admin123', 
    host='localhost', 
    port='5433'
)
conn.autocommit = False
cur = conn.cursor()

# Check current state
cur.execute("SELECT version_num FROM alembic_version")
version = cur.fetchone()[0]
print(f"Current alembic version: {version}")

if version == 'a3f7c9d1e2b4':
    print("Migration already applied!")
    cur.close()
    conn.close()
    exit(0)

try:
    # 1. Create app_settings if not exists
    cur.execute("SELECT EXISTS(SELECT FROM information_schema.tables WHERE table_name='app_settings')")
    if not cur.fetchone()[0]:
        cur.execute("""
            CREATE TABLE app_settings (
                id SERIAL PRIMARY KEY,
                key VARCHAR(100) NOT NULL UNIQUE,
                value VARCHAR(500) NOT NULL,
                description VARCHAR(255),
                updated_at TIMESTAMP DEFAULT NOW()
            )
        """)
        cur.execute("CREATE INDEX ix_app_settings_id ON app_settings(id)")
        cur.execute("CREATE UNIQUE INDEX ix_app_settings_key ON app_settings(key)")
        print("Created app_settings table")
    else:
        print("app_settings already exists")

    # 2. Insert default exchange rate
    cur.execute("SELECT EXISTS(SELECT FROM app_settings WHERE key='dollar_exchange_rate')")
    if not cur.fetchone()[0]:
        cur.execute(
            "INSERT INTO app_settings (key, value, description, updated_at) "
            "VALUES ('dollar_exchange_rate', '1200', 'Cotizacion del dolar (ARS por 1 USD)', NOW())"
        )
        print("Inserted default exchange rate")
    else:
        print("Default exchange rate already exists")

    # 3. Add columns to credit_card_purchases
    cur.execute("SELECT EXISTS(SELECT FROM information_schema.columns WHERE table_name='credit_card_purchases' AND column_name='currency')")
    if not cur.fetchone()[0]:
        cur.execute("ALTER TABLE credit_card_purchases ADD COLUMN currency VARCHAR(3) DEFAULT 'ARS'")
        cur.execute("ALTER TABLE credit_card_purchases ADD COLUMN exchange_rate FLOAT")
        cur.execute("ALTER TABLE credit_card_purchases ADD COLUMN amount_in_pesos FLOAT")
        cur.execute("UPDATE credit_card_purchases SET currency = 'ARS' WHERE currency IS NULL")
        print("Added currency columns")
    else:
        print("Currency columns already exist")

    # 4. Update alembic_version
    cur.execute("UPDATE alembic_version SET version_num = 'a3f7c9d1e2b4'")
    print("Updated alembic_version to a3f7c9d1e2b4")

    conn.commit()
    print("SUCCESS: Migration 003 applied!")
except Exception as e:
    conn.rollback()
    print(f"ERROR: {e}")
finally:
    cur.close()
    conn.close()
