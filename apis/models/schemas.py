from pydantic import BaseModel
from datetime import datetime
from typing import Optional

timestamp = datetime

# SQL snapshot POST request

class SnapshotCreate(BaseModel):
    timestamp: timestamp       
    total_load_actual: float

# Mongo record POST request

class MongoRecordCreate(BaseModel):
    timestamp: str
    load_actual: float
    price_actual: float
