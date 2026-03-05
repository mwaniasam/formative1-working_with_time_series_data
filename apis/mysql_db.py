import mysql.connector

# Function to get a connection to MySQL database

def get_mysql_connection():
    connection = mysql.connector.connect(
        host="localhost",         
        user="os.getenv(MYSQL_USER)",
        password="os.getenv(MYSQL_PASSWORD)",
        database="energy_db"       
    )
    return connection
