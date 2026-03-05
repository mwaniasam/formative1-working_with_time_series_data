import mysql.connector
from dotenv import load_dotenv
import os

# Function to get a connection to MySQL database
load_dotenv()
def get_mysql_connection():
    connection = mysql.connector.connect(
        host="localhost",         
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database="energy_db"       
    )
    return connection
