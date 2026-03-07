-- Data Loading and Cleaning Script
-- Its better to run this this after schema.sql

USE energy_db;

-- STEP 1: Load raw CSV into staging table
-- File must be copied to /var/lib/mysql-files/ first:
-- sudo cp data/energy_dataset.csv /var/lib/mysql-files/
-- All columns are VARCHAR to handle empty cells without errors
LOAD DATA INFILE 'C:/Users/LENOVO/ALU/formative1-working_with_time_series_data/data/energy_dataset.csv'
INTO TABLE raw_energy
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- STEP 2: Create clean table from raw
-- Changes made:
-- - Strip timezone offset from timestamp using SUBSTRING
-- - Convert timestamp string to proper DATETIME using STR_TO_DATE
-- - Convert empty strings to NULL using NULLIF
-- - Drop generation_hydro_pumped_storage_agg (100% empty)
-- - Drop forecast_wind_offshore_eday_ahead (100% empty)
INSERT INTO clean_energy (
    timestamp, generation_biomass, generation_fossil_brown_coal,
    generation_fossil_coal_derived_gas, generation_fossil_gas,
    generation_fossil_hard_coal, generation_fossil_oil,
    generation_fossil_oil_shale, generation_fossil_peat,
    generation_geothermal, generation_hydro_pumped_storage_cons,
    generation_hydro_run_of_river, generation_hydro_water_reservoir,
    generation_marine, generation_nuclear, generation_other,
    generation_other_renewable, generation_solar, generation_waste,
    generation_wind_offshore, generation_wind_onshore,
    forecast_solar_day_ahead, forecast_wind_onshore_day_ahead,
    total_load_forecast, total_load_actual, price_day_ahead, price_actual
)
SELECT
    STR_TO_DATE(SUBSTRING(time_str, 1, 19), '%Y-%m-%d %H:%i:%s'),
    NULLIF(generation_biomass, ''),
    NULLIF(generation_fossil_brown_coal, ''),
    NULLIF(generation_fossil_coal_derived_gas, ''),
    NULLIF(generation_fossil_gas, ''),
    NULLIF(generation_fossil_hard_coal, ''),
    NULLIF(generation_fossil_oil, ''),
    NULLIF(generation_fossil_oil_shale, ''),
    NULLIF(generation_fossil_peat, ''),
    NULLIF(generation_geothermal, ''),
    NULLIF(generation_hydro_pumped_storage_cons, ''),
    NULLIF(generation_hydro_run_of_river, ''),
    NULLIF(generation_hydro_water_reservoir, ''),
    NULLIF(generation_marine, ''),
    NULLIF(generation_nuclear, ''),
    NULLIF(generation_other, ''),
    NULLIF(generation_other_renewable, ''),
    NULLIF(generation_solar, ''),
    NULLIF(generation_waste, ''),
    NULLIF(generation_wind_offshore, ''),
    NULLIF(generation_wind_onshore, ''),
    NULLIF(forecast_solar_day_ahead, ''),
    NULLIF(forecast_wind_onshore_day_ahead, ''),
    NULLIF(total_load_forecast, ''),
    NULLIF(total_load_actual, ''),
    NULLIF(price_day_ahead, ''),
    NULLIF(price_actual, '')
FROM raw_energy;

-- STEP 3: Convert VARCHAR columns to FLOAT
ALTER TABLE clean_energy
    MODIFY generation_biomass                   FLOAT,
    MODIFY generation_fossil_brown_coal         FLOAT,
    MODIFY generation_fossil_coal_derived_gas   FLOAT,
    MODIFY generation_fossil_gas                FLOAT,
    MODIFY generation_fossil_hard_coal          FLOAT,
    MODIFY generation_fossil_oil                FLOAT,
    MODIFY generation_fossil_oil_shale          FLOAT,
    MODIFY generation_fossil_peat               FLOAT,
    MODIFY generation_geothermal                FLOAT,
    MODIFY generation_hydro_pumped_storage_cons FLOAT,
    MODIFY generation_hydro_run_of_river        FLOAT,
    MODIFY generation_hydro_water_reservoir     FLOAT,
    MODIFY generation_marine                    FLOAT,
    MODIFY generation_nuclear                   FLOAT,
    MODIFY generation_other                     FLOAT,
    MODIFY generation_other_renewable           FLOAT,
    MODIFY generation_solar                     FLOAT,
    MODIFY generation_waste                     FLOAT,
    MODIFY generation_wind_offshore             FLOAT,
    MODIFY generation_wind_onshore              FLOAT,
    MODIFY forecast_solar_day_ahead             FLOAT,
    MODIFY forecast_wind_onshore_day_ahead      FLOAT,
    MODIFY total_load_forecast                  FLOAT,
    MODIFY total_load_actual                    FLOAT,
    MODIFY price_day_ahead                      FLOAT,
    MODIFY price_actual                         FLOAT;

-- STEP 4: Populate normalized tables
-- energy_source
INSERT INTO energy_source (source_name, is_renewable) VALUES
    ('biomass', TRUE), ('fossil brown coal', FALSE),
    ('fossil coal derived gas', FALSE), ('fossil gas', FALSE),
    ('fossil hard coal', FALSE), ('fossil oil', FALSE),
    ('fossil oil shale', FALSE), ('fossil peat', FALSE),
    ('geothermal', TRUE), ('hydro pumped storage cons', FALSE),
    ('hydro run of river', TRUE), ('hydro water reservoir', TRUE),
    ('marine', TRUE), ('nuclear', FALSE), ('other', FALSE),
    ('other renewable', TRUE), ('solar', TRUE), ('waste', FALSE),
    ('wind offshore', TRUE), ('wind onshore', TRUE);

-- hourly_snapshot (skip DST duplicate timestamps, keep first occurrence)
INSERT INTO hourly_snapshot
    (timestamp, total_load_actual, total_load_forecast, price_actual, price_day_ahead)
SELECT timestamp, total_load_actual, total_load_forecast, price_actual, price_day_ahead
FROM clean_energy
WHERE id IN (
    SELECT MIN(id) FROM clean_energy GROUP BY timestamp
);

-- generation_record (one row per source per hour)
INSERT INTO generation_record (snapshot_id, source_id, generation_mw, forecast_mw)
SELECT h.snapshot_id, 1,  c.generation_biomass,                NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 2,  c.generation_fossil_brown_coal,      NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 3,  c.generation_fossil_coal_derived_gas,NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 4,  c.generation_fossil_gas,             NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 5,  c.generation_fossil_hard_coal,       NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 6,  c.generation_fossil_oil,             NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 7,  c.generation_fossil_oil_shale,       NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 8,  c.generation_fossil_peat,            NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 9,  c.generation_geothermal,             NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 10, c.generation_hydro_pumped_storage_cons, NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 11, c.generation_hydro_run_of_river,     NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 12, c.generation_hydro_water_reservoir,  NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 13, c.generation_marine,                 NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 14, c.generation_nuclear,                NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 15, c.generation_other,                  NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 16, c.generation_other_renewable,        NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 17, c.generation_solar,    c.forecast_solar_day_ahead        FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 18, c.generation_waste,                  NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 19, c.generation_wind_offshore,          NULL FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp UNION ALL
SELECT h.snapshot_id, 20, c.generation_wind_onshore, c.forecast_wind_onshore_day_ahead FROM clean_energy c JOIN hourly_snapshot h ON h.timestamp = c.timestamp;
