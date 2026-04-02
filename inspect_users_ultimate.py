import sqlite3
import os

db_path = r'c:\development\graduation_backend\graduation.db'
print(f"Checking database: {db_path}, exists: {os.path.exists(db_path)}")
try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = [t[0] for t in cursor.fetchall()]
    print(f"Tables: {tables}")
    
    if 'users' in tables:
        # Get column names
        cursor.execute("PRAGMA table_info(users)")
        columns = [c[1] for c in cursor.fetchall()]
        print(f"Users columns: {columns}")
        
        cursor.execute("SELECT * FROM users")
        rows = cursor.fetchall()
        print(f"\nAll registered users:")
        # We find name/email/role
        # find where name is 'id', 'name', 'email', 'role' indices
        id_idx = columns.index('id') if 'id' in columns else 0
        name_idx = columns.index('name') if 'name' in columns else -1
        email_idx = columns.index('email') if 'email' in columns else -1
        role_idx = columns.index('role') if 'role' in columns else -1
        
        for row in rows:
            print(f"ID={row[id_idx]}, Name={row[name_idx]}, Email={row[email_idx]}, Role={row[role_idx]}")
    conn.close()
except Exception as e:
    print(f"Error: {e}")
