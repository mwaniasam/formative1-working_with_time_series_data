import mysql.connector
from pymongo import MongoClient
from datetime import datetime
from dotenv import load_dotenv
import os

load_dotenv()
# Connect to MySQL
mysql_conn = mysql.connector.connect(
    host="localhost",
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database="energy_db"
)
cursor = mysql_conn.cursor(dictionary=True)

# Connect to MongoDB
mongo_client = MongoClient("mongodb://localhost:27017/")
collection = mongo_client["energy_db"]["energy_hourly"]

# Clear existing documents
collection.delete_many({})
print("Cleared existing documents")

# Fetch all rows from clean_energy
cursor.execute("SELECT * FROM clean_energy")
rows = cursor.fetchall()
print(f"Fetched {len(rows)} rows from MySQL")

# Build and insert documents
docs = []
for row in rows:
    # Calculate summary values
    renewable = (
        (row["generation_biomass"] or 0) +
        (row["generation_geothermal"] or 0) +
        (row["generation_hydro_run_of_river"] or 0) +
        (row["generation_hydro_water_reservoir"] or 0) +
        (row["generation_marine"] or 0) +
        (row["generation_other_renewable"] or 0) +
        (row["generation_solar"] or 0) +
        (row["generation_wind_offshore"] or 0) +
        (row["generation_wind_onshore"] or 0)
    )
    fossil = (
        (row["generation_fossil_brown_coal"] or 0) +
        (row["generation_fossil_coal_derived_gas"] or 0) +
        (row["generation_fossil_gas"] or 0) +
        (row["generation_fossil_hard_coal"] or 0) +
        (row["generation_fossil_oil"] or 0) +
        (row["generation_fossil_oil_shale"] or 0) +
        (row["generation_fossil_peat"] or 0)
    )
    total = renewable + fossil + (row["generation_nuclear"] or 0) + (row["generation_waste"] or 0) + (
        row["generation_other"] or 0) + (row["generation_hydro_pumped_storage_cons"] or 0)

    doc = {
        "timestamp": row["timestamp"],
        "load": {
            "actual":   row["total_load_actual"],
            "forecast": row["total_load_forecast"]
        },
        "price": {
            "actual":    row["price_actual"],
            "day_ahead": row["price_day_ahead"]
        },
        "generation": {
            "biomass":                   {"mw": row["generation_biomass"]},
            "fossil_brown_coal":         {"mw": row["generation_fossil_brown_coal"]},
            "fossil_coal_derived_gas":   {"mw": row["generation_fossil_coal_derived_gas"]},
            "fossil_gas":                {"mw": row["generation_fossil_gas"]},
            "fossil_hard_coal":          {"mw": row["generation_fossil_hard_coal"]},
            "fossil_oil":                {"mw": row["generation_fossil_oil"]},
            "fossil_oil_shale":          {"mw": row["generation_fossil_oil_shale"]},
            "fossil_peat":               {"mw": row["generation_fossil_peat"]},
            "geothermal":                {"mw": row["generation_geothermal"]},
            "hydro_pumped_storage_cons": {"mw": row["generation_hydro_pumped_storage_cons"]},
            "hydro_run_of_river":        {"mw": row["generation_hydro_run_of_river"]},
            "hydro_water_reservoir":     {"mw": row["generation_hydro_water_reservoir"]},
            "marine":                    {"mw": row["generation_marine"]},
            "nuclear":                   {"mw": row["generation_nuclear"]},
            "other":                     {"mw": row["generation_other"]},
            "other_renewable":           {"mw": row["generation_other_renewable"]},
            "solar":                     {"mw": row["generation_solar"], "forecast_mw": row["forecast_solar_day_ahead"]},
            "waste":                     {"mw": row["generation_waste"]},
            "wind_offshore":             {"mw": row["generation_wind_offshore"]},
            "wind_onshore":              {"mw": row["generation_wind_onshore"], "forecast_mw": row["forecast_wind_onshore_day_ahead"]}
        },
        "energy_summary": {
            "total_renewable_mw": round(renewable, 2),
            "total_fossil_mw":    round(fossil, 2),
            "total_generation_mw": round(total, 2)
        }
    }
    docs.append(doc)

# Insert in batches of 1000
batch_size = 1000
for i in range(0, len(docs), batch_size):
    collection.insert_many(docs[i:i+batch_size])
    print(f"Inserted {min(i+batch_size, len(docs))} / {len(docs)}")

print(f"Done. Total documents: {collection.count_documents({})}")

cursor.close()
mysql_conn.close()
mongo_client.close()
