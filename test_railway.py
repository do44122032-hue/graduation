import urllib.request
import urllib.error
import json

url = "https://graduation-backend-production-7023.up.railway.app/auth/reset-password"
data = json.dumps({"email": "daniadano2004@gmail.com"}).encode('utf-8')
req = urllib.request.Request(url, data=data, headers={'content-type': 'application/json', 'Origin': 'http://localhost:50341'})

try:
    with urllib.request.urlopen(req) as response:
        with open('error_log.json', 'w') as f:
            f.write(response.read().decode())
except urllib.error.HTTPError as e:
    with open('error_log.json', 'w') as f:
        f.write(e.read().decode())
except Exception as e:
    with open('error_log.json', 'w') as f:
        f.write(str(e))
