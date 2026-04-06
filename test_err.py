import urllib.request
import json
import urllib.error

url = f'https://graduation-backend-production-7023.up.railway.app/dashboard/doctor/8/appointments'
try:
    data = urllib.request.urlopen(url).read().decode()
    print(data)
except urllib.error.HTTPError as e:
    print(f"HTTPError: {e.code}")
    print(e.read().decode())
except Exception as e:
    print(f"Error: {e}")
