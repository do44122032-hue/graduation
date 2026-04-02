import requests
import json

base_url = 'https://graduation-backend-production-7023.up.railway.app'
# Use the UID/ID of Noor if possible, but we don't know it on Railway. 
# We'll just test the endpoint existence.

endpoints = [
    '/',
    '/health',
    '/dashboard/patient/5',
]

for ep in endpoints:
    url = base_url + ep
    try:
        print(f"Testing {url}...")
        resp = requests.get(url, timeout=10)
        print(f"Status: {resp.status_code}")
        print(f"Body: {resp.text[:200]}")
    except Exception as e:
        print(f"Error connecting to {url}: {e}")

print("\nTesting POST /dashboard/vitals (Dry run/Check existence)...")
try:
    url = base_url + '/dashboard/vitals'
    # Send empty body to see error code (should be 422 if exists, 404 if not)
    resp = requests.post(url, json={}, timeout=10)
    print(f"POST {url} Status: {resp.status_code}")
except Exception as e:
    print(f"Error: {e}")
