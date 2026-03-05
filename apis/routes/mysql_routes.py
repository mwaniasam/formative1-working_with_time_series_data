from fastapi import APIRouter
from ..mysql_db import get_mysql_connection
from typing import List
from ..models.schemas import SnapshotCreate

router = APIRouter(prefix="/sql")

# GET: All snapshots (default limit 100)

@router.get("/snapshots")
def get_snapshots(limit: int = 100):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)  
    cursor.execute("SELECT * FROM hourly_snapshot ORDER BY timestamp DESC LIMIT %s", (limit,))
    result = cursor.fetchall()
    conn.close()
    return result


# GET: Latest record

@router.get("/latest")
def latest_record(limit: int = 1):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM hourly_snapshot ORDER BY timestamp DESC LIMIT %s", (limit,))
    result = cursor.fetchall()
    conn.close()
    return result


# GET: Date range

@router.get("/range")
def records_range(start: str, end: str):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    query = """
        SELECT * FROM hourly_snapshot
        WHERE timestamp BETWEEN %s AND %s
        ORDER BY timestamp
    """
    cursor.execute(query, (start, end))
    result = cursor.fetchall()
    conn.close()
    return result


# POST: Create snapshot

@router.post("/snapshot")
def create_snapshot(snapshot: SnapshotCreate):
    conn = get_mysql_connection()
    cursor = conn.cursor()
    query = """
        INSERT INTO hourly_snapshot (timestamp, total_load_actual)
        VALUES (%s, %s)
    """
    cursor.execute(query, (snapshot.timestamp, snapshot.total_load_actual))
    conn.commit()
    conn.close()
    return {"message": "Snapshot created successfully"}


# DELETE: Delete snapshot by ID

@router.delete("/snapshot/{snapshot_id}")
def delete_snapshot(snapshot_id: int):
    conn = get_mysql_connection()
    cursor = conn.cursor()
    query = "DELETE FROM hourly_snapshot WHERE snapshot_id = %s"
    cursor.execute(query, (snapshot_id,))
    conn.commit()
    conn.close()
    return {"message": "Snapshot deleted successfully"}

# PUT: Update snapshot by ID

@router.put('/snapshot/{snapshot_id}')
def update_snapshot(snapshot_id: int, snapshot: SnapshotCreate):
    conn = get_mysql_connection()
    cursor = conn.cursor()
    query = """
        UPDATE hourly_snapshot
        SET timestamp = %s, total_load_actual = %s
        WHERE snapshot_id = %s
    """
    cursor.execute(query, (snapshot.timestamp, snapshot.total_load_actual, snapshot_id))
    conn.commit()
    conn.close()
    return {"message": "Snapshot updated successfully"}
