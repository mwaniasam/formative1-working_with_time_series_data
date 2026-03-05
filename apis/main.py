from fastapi import FastAPI 
import mysql.connector
import os

app = FastAPI()

@app.post("/data")
def insert_data(data: dict):
    # Connect to MySQL
    mysql_conn = mysql.connector.connect(
        host="localhost",
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database="energy_db"
    )
    cursor = mysql_conn.cursor()

    # Build SQL query
    columns = ", ".join(data.keys())
    placeholders = ", ".join(["%s"] * len(data))
    sql = f"INSERT INTO clean_energy ({columns}) VALUES ({placeholders})"
    
    # Execute query
    cursor.execute(sql, tuple(data.values()))
    mysql_conn.commit()
    cursor.close()
    mysql_conn.close()
    
    return {"message": "Data inserted successfully"}

@app.get("/data")
def get_data():
    # Connect to MySQL
    mysql_conn = mysql.connector.connect(
        host="localhost",
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database="energy_db"
    )
    cursor = mysql_conn.cursor(dictionary=True)

    # Execute query
    cursor.execute("SELECT * FROM clean_energy")
    results = cursor.fetchall()
    
    cursor.close()
    mysql_conn.close()
    
    return results

@app.delete("/data")
def delete_data():  
    # Connect to MySQL
    mysql_conn = mysql.connector.connect(
        host="localhost",
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database="energy_db"
    )
    cursor = mysql_conn.cursor()

    # Execute query
    cursor.execute("DELETE FROM clean_energy")
    mysql_conn.commit()
    
    cursor.close()
    mysql_conn.close()
    
    return {"message": "All data deleted successfully"} 

@app.put("/data")
def update_data(id: int, data: dict):
    # Connect to MySQL
    mysql_conn = mysql.connector.connect(
        host="localhost",
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database="energy_db"
    )
    cursor = mysql_conn.cursor()

    # Build SQL query
    set_clause = ", ".join([f"{key} = %s" for key in data.keys()])
    sql = f"UPDATE clean_energy SET {set_clause} WHERE id = %s"
    
    # Execute query
    cursor.execute(sql, tuple(data.values()) + (id,))
    mysql_conn.commit()
    
    cursor.close()
    mysql_conn.close()
    
    return {"message": "Data updated successfully"}