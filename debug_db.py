import sqlite3
import os

db_path = r'c:\development\flutter-projects\graduation_project\graduation.db'
if not os.path.exists(db_path):
    print(f"Database {db_path} does not exist.")
else:
    print(f"Checking database: {db_path}")
    print(f"File size: {os.path.getsize(db_path)} bytes")
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        print(f"Tables: {tables}")
        for table in tables:
            table_name = table[0]
            # cursor.execute(f"PRAGMA table_info({table_name});")
            # columns = cursor.fetchall()
            print(f"\nTable: {table_name}")
            
            if table_name.lower() == 'users':
                cursor.execute(f"SELECT * FROM {table_name};")
                rows = cursor.fetchall()
                print(f"Data in {table_name}:")
                for row in rows:
                    print(row)
        conn.close()
    except Exception as e:
        print(f"Error: {e}")
