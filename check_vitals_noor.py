import sqlite3
import os

db_path = r'c:\development\graduation_backend\graduation.db'
user_uid = '117de243-6cf1-46f1-8012-8d9ba12c2934'

with open('vitals_check.txt', 'w', encoding='utf-8') as f:
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        cursor.execute("PRAGMA table_info(vital_signs)")
        cols = [c[1] for c in cursor.fetchall()]
        f.write(f"Columns: {cols}\n")
        
        cursor.execute(f"SELECT * FROM vital_signs WHERE uid='{user_uid}'")
        rows = cursor.fetchall()
        f.write(f"Vitals for UID {user_uid}:\n")
        for row in rows:
            f.write(f"{row}\n")
        
        if not rows:
            f.write("No vitals found for this user.\n")
            
        conn.close()
    except Exception as e:
        f.write(f"Error: {e}\n")
print("Done")
