import urllib.request
import json

doctor_ids = ['5', '6', '7', '3', '8']

for d in doctor_ids:
    url = f'https://graduation-backend-production-7023.up.railway.app/users/doctors/{d}/schedule'
    try:
        data = urllib.request.urlopen(url).read().decode()
        slots = json.loads(data)
        print(f"Doctor {d} has {len(slots)} slots")
        if slots:
            print(slots)
    except Exception as e:
        print(f"Error for doctor {d}: {e}")
