from fastapi import FastAPI
from pymongo import MongoClient
import os

app = FastAPI()

@app.get("/mongodb_data")
def get_mongodb_data():
    # Connect to MongoDB
    mongo_client = MongoClient("mongodb://localhost:27017/")
    collection = mongo_client["energy_db"]["energy_hourly"]

    # Fetch all documents
    results = list(collection.find({}, {"_id": 0}))  # Exclude _id field
    
    return results

@app.post("/mongodb_data")
def insert_mongodb_data(data: dict):
    # Connect to MongoDB
    mongo_client = MongoClient("mongodb://localhost:27017/")
    collection = mongo_client["energy_db"]["energy_hourly"]

    # Insert document
    collection.insert_one(data)
    
    return {"message": "Data inserted successfully"}

@app.delete("/mongodb_data")
def delete_mongodb_data():
    # Connect to MongoDB
    mongo_client = MongoClient("mongodb://localhost:27017/")
    collection = mongo_client["energy_db"]["energy_hourly"]

    # Delete all documents
    collection.delete_many({})
    
    return {"message": "All data deleted successfully"}


