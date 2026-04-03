import urllib.request
import urllib.error
import json

base_url = "https://graduation-backend-production-7023.up.railway.app"
email = "daniadano2004@gmail.com"

# 1. Force Register the user
signup_data = json.dumps({
    "name": "Dania Dano",
    "email": email,
    "password": "Password123!",
    "phone": "07722337164",
    "role": "patient"
}).encode('utf-8')

print("1. Creating test user...")
try:
    req = urllib.request.Request(f"{base_url}/auth/signup", data=signup_data, headers={'content-type': 'application/json'})
    res = urllib.request.urlopen(req)
    print("Signup Success:", res.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"Signup HTTPError ({e.code}):", e.read().decode('utf-8') if hasattr(e, 'read') else str(e))
except Exception as e:
    print("Signup Exception:", str(e))

# 2. Trigger Reset Password
reset_data = json.dumps({"email": email}).encode('utf-8')

print("\n2. Triggering Reset Password...")
try:
    req = urllib.request.Request(f"{base_url}/auth/reset-password", data=reset_data, headers={'content-type': 'application/json'})
    res = urllib.request.urlopen(req)
    print("Reset Success:", res.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"Reset HTTPError ({e.code}):", e.read().decode('utf-8') if hasattr(e, 'read') else str(e))
except Exception as e:
    print("Reset Exception:", str(e))
