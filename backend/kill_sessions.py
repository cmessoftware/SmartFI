import psycopg2
conn = psycopg2.connect(host='localhost', port=5433, dbname='fin_per_db', user='admin', password='admin123')
conn.autocommit = True
cur = conn.cursor()
cur.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='fin_per_db' AND pid <> pg_backend_pid()")
rows = cur.fetchall()
print(f'Terminated {len(rows)} sessions')
cur.close()
conn.close()
print('Done')
