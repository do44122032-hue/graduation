import sqlite3
import os

db_path = r'c:\development\graduation_backend\graduation.db'
with open('db_dump.txt', 'w', encoding='utf-8') as f:
    if not os.path.exists(db_path):
        f.write(f"Database {db_path} does not exist.")
    else:
        f.write(f"Checking database: {db_path}\n")
        try:
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
            tables = [t[0] for t in cursor.fetchall()]
            f.write(f"Tables: {tables}\n")
            
            if 'users' in tables:
                cursor.execute("PRAGMA table_info(users)")
                cols = [c[1] for c in cursor.fetchall()]
                f.write(f"Columns: {cols}\n")
                
                cursor.execute("SELECT * FROM users")
                rows = cursor.fetchall()
                for row in rows:
                    f.write(f"{row}\n")
            
            if 'vitals' in tables:
                cursor.execute("SELECT * FROM vitals")
                vitals = cursor.fetchall()
                f.write(f"\nVitals: {vitals}\n")
            
            conn.close()
        except Exception as e:
            f.write(f"Error: {e}\n")
print("Done writing to db_dump.txt")
