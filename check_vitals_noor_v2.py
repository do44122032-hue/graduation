import sqlite3
import os

db_path = r'c:\development\graduation_backend\graduation.db'
patient_id = 5

with open('vitals_check.txt', 'w', encoding='utf-8') as f:
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        cursor.execute(f"SELECT * FROM vital_signs WHERE patient_id='{patient_id}'")
        rows = cursor.fetchall()
        f.write(f"Vitals for ID {patient_id}:\n")
        for row in rows:
            f.write(f"{row}\n")
        
        if not rows:
            f.write(f"No vitals found for patient_id {patient_id}.\n")
            
        conn.close()
    except Exception as e:
        f.write(f"Error: {e}\n")
print("Done")
