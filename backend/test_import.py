"""Quick test for CSV import endpoint - Bug 8 investigation"""
import requests
import json

BASE = 'http://localhost:8000'

# Login
print("=== Login ===")
token_resp = requests.post(f'{BASE}/api/auth/login', data={'username':'admin','password':'admin123'}, timeout=5)
token = token_resp.json()['access_token']
headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
print(f'Token OK')

# Test 0: Single add (simpler endpoint)
print("\n=== Test 0: Single transaction add ===")
single = {
    'timestamp': '2026-04-05T12:00:00',
    'date': '2026-04-05',
    'type': 'Gasto',
    'category': 'Supermercado',
    'amount': 50.00,
    'necessity': 'Necesario',
    'payment_method': 'Debito',
    'detail': 'Test single bug8'
}
try:
    resp0 = requests.post(f'{BASE}/api/transactions', json=single, headers=headers, timeout=30)
    print(f'STATUS: {resp0.status_code}')
    print(f'BODY: {resp0.text[:300]}')
except requests.exceptions.Timeout:
    print('TIMEOUT - endpoint hung for 30s!')

# Test 1: Import (batch endpoint)
print("\n=== Test 1: Import transaction ===")
test_data = [{
    'timestamp': '2026-04-05T12:00:00',
    'date': '2026-04-05',
    'type': 'Gasto',
    'category': 'Supermercado',
    'amount': 100.50,
    'necessity': 'Necesario',
    'payment_method': 'Debito',
    'detail': 'Test import bug8'
}]
try:
    resp = requests.post(f'{BASE}/api/transactions/import', json=test_data, headers=headers, timeout=30)
    print(f'STATUS: {resp.status_code}')
    print(f'BODY: {resp.text[:500]}')
except requests.exceptions.Timeout:
    print('TIMEOUT - endpoint hung for 30s!')

# Test 2: Multiple transactions (like real CSV)
print("\n=== Test 2: Multiple transactions ===")
test_data2 = [
    {
        'timestamp': '2026-04-05T12:00:00',
        'date': '2026-04-05',
        'type': 'Gasto',
        'category': 'Supermercado',
        'amount': 200,
        'necessity': 'Necesario',
        'payment_method': 'Debito',
        'detail': 'Test row 1'
    },
    {
        'timestamp': '2026-04-05T12:00:00',
        'date': '2026-04-05',
        'type': 'Ingreso',
        'category': 'Sueldo',
        'amount': 5000,
        'necessity': 'Necesario',
        'payment_method': 'Debito',
        'detail': 'Test row 2'
    }
]
resp2 = requests.post(f'{BASE}/api/transactions/import', json=test_data2, headers=headers)
print(f'STATUS: {resp2.status_code}')
print(f'BODY: {resp2.text[:500]}')

# Cleanup - delete test transactions
print("\n=== Cleanup ===")
txns = requests.get(f'{BASE}/api/transactions', headers=headers).json()
for t in txns:
    if isinstance(t, dict) and t.get('detail','').startswith('Test import bug8') or t.get('detail','').startswith('Test row'):
        del_resp = requests.delete(f'{BASE}/api/transactions/{t["id"]}', headers=headers)
        print(f'Deleted {t["id"]}: {del_resp.status_code}')
