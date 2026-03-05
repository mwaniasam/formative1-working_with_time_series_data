from pydantic import BaseModel

# SQL snapshot POST request

class SnapshotCreate(BaseModel):
    timestamp: str        
    total_load_actual: float

# Mongo record POST request

class MongoRecordCreate(BaseModel):
    timestamp: str
    load_actual: float
    price_actual: float
