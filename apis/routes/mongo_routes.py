from fastapi import APIRouter
from ..mongo_db import collection
from ..models.schemas import MongoRecordCreate
from bson import ObjectId

router = APIRouter(prefix="/mongo")

# Helper: convert ObjectId to str


def serialize(doc):
    doc["_id"] = str(doc["_id"])
    return doc

# GET: first 100 records


@router.get("/records")
def get_records():
    records = list(collection.find().limit(100))
    return [serialize(r) for r in records]

# GET: Latest record

@router.get("/latest")
def latest_record():
    record = collection.find().sort("timestamp", -1).limit(1)
    return [serialize(r) for r in record]


# GET: Date range


@router.get("/range")
def records_range(start: str, end: str):
    query = {"timestamp": {"$gte": start, "$lte": end}}
    result = collection.find(query)
    return [serialize(r) for r in result]

# POST: Create a new record

@router.post("/record")
def create_record(record: MongoRecordCreate):
    doc = {
        "timestamp": record.timestamp,
        "load": {"actual": record.load_actual},
        "price": {"actual": record.price_actual}
    }
    collection.insert_one(doc)
    return {"message": "MongoDB record created successfully"}


# DELETE: Delete by ObjectId


@router.delete("/record/{id}")
def delete_record(id: str):
    collection.delete_one({"_id": ObjectId(id)})
    return {"message": "Record deleted successfully"}
