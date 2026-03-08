from fastapi import APIRouter
from ..mysql_db import get_mysql_connection
from typing import List
from ..models.schemas import SnapshotCreate
from dateutil import parser as date_parser
from datetime import datetime
from dateutil.relativedelta import relativedelta
from fastapi import HTTPException

router = APIRouter(prefix="/sql")

# GET: All snapshots (default limit 500)

@router.get("/snapshots")
def get_snapshots(limit: int = 500):
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
def records_range(start: str, end: str, limit: int = 500):
    def parse_date(input_str: str, is_start=True) -> str:
        """
        Convert user input to MySQL DATETIME string
        Accepts:
        - Year (YYYY)
        - Year-Month (YYYY-MM)
        - Full date (YYYY-MM-DD)
        - Full ISO8601 (YYYY-MM-DDTHH:MM:SS.sss±TZ)
        """
        try:
            dt = date_parser.isoparse(input_str)
        except ValueError:
            # Fallback for year or year-month or date-only
            parts = input_str.split("-")
            if len(parts) == 1: 
                dt = datetime(
                    int(parts[0]), 1 if is_start else 12, 1 if is_start else 31)
            elif len(parts) == 2:
                year, month = int(parts[0]), int(parts[1])
                if is_start:
                    dt = datetime(year, month, 1)
                else:
                    dt = datetime(year, month, 1) + \
                        relativedelta(months=1, days=-1)
            elif len(parts) == 3: 
                year, month, day = map(int, parts)
                dt = datetime(year, month, day)
            else:
                raise HTTPException(
                    status_code=400, detail=f"Invalid date format: {input_str}")

        # Adjust time to start or end of day
        if is_start:
            dt = dt.replace(hour=0, minute=0, second=0)
        else:
            dt = dt.replace(hour=23, minute=59, second=59)

        return dt.strftime("%Y-%m-%d %H:%M:%S")

    start_mysql = parse_date(start, is_start=True)
    end_mysql = parse_date(end, is_start=False)

    if start_mysql > end_mysql:
        raise HTTPException(
            status_code=400, detail="Start date must be before end date")

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    query = f"""
        SELECT * FROM hourly_snapshot
        WHERE timestamp BETWEEN %s AND %s
        ORDER BY timestamp
        LIMIT {limit}
    """
    cursor.execute(query, (start_mysql, end_mysql))
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
