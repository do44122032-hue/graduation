import requests
import json

base_url = 'https://graduation-backend-production-7023.up.railway.app'

# 1. Sign up a test user to get a real ID/UID
test_email = f"test_{int(__import__('time').time())}@example.com"
print(f"Creating test user: {test_email}...")
signup_resp = requests.post(f"{base_url}/auth/signup", json={
    "name": "Integration Test",
    "email": test_email,
    "password": "password123",
    "phone": "123456",
    "role": "patient"
})

if signup_resp.status_code != 200:
    print(f"Signup failed: {signup_resp.text}")
    exit(1)

user = signup_resp.json().get('user')
uid = user.get('id')
print(f"User Created. ID/UID: {uid}")

# 2. Log a vital reading
print("Logging vitals...")
vitals_resp = requests.post(f"{base_url}/dashboard/vitals", json={
    "uid": str(uid),
    "bloodPressureSys": 150,
    "bloodPressureDia": 95,
    "heartRate": 80,
    "temperature": 37.0,
    "respiratoryRate": 16,
    "oxygenSaturation": 98,
    "weight": 70,
    "bmi": 22.5,
    "bloodGlucose": 100
})
print(f"Log Vitals Status: {vitals_resp.status_code}")
print(f"Log Vitals Body: {vitals_resp.json()}")

# 3. Fetch the dashboard
print("Fetching dashboard...")
dash_resp = requests.get(f"{base_url}/dashboard/patient/{uid}")
print(f"Dashboard Status: {dash_resp.status_code}")
dash_data = dash_resp.json()

vitals = dash_data.get('recentVitals', [])
print(f"Vitals Count: {len(vitals)}")
if len(vitals) > 0:
    print(f"LATEST VITAL BP: {vitals[0].get('bloodPressureSys')}/{vitals[0].get('bloodPressureDia')}")
else:
    print("CRITICAL: VITALS LIST IS EMPTY AFTER SAVING!")
