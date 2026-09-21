import sqlite3

conn = sqlite3.connect("instance/data.db")

tables = ["stores", "users", "items", "tags", "items_tags"]

for table in tables:
    print(f"\n--- {table.upper()} ---")

    rows = conn.execute(f"SELECT * FROM {table}").fetchall()

    for row in rows:
        print(row)

conn.close()