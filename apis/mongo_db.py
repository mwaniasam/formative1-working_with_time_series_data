from pymongo import MongoClient

# Connect to local MongoDB
client = MongoClient("mongodb://localhost:27017")

# Access database and collection
db = client["energy_db"]
collection = db["hourly_snapshot"]
