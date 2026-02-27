-- Energy Database Schema
-- Dataset: ENTSO-E Hourly Energy Generation, Load and Price

CREATE DATABASE IF NOT EXISTS energy_db;
USE energy_db;

-- STAGING TABLE
-- Mirrors the CSV exactly, all columns are VARCHAR to avoid
-- import failures caused by empty cells in numeric columns
CREATE TABLE IF NOT EXISTS raw_energy (
    time_str                                VARCHAR(50),
    generation_biomass                      VARCHAR(20),
    generation_fossil_brown_coal            VARCHAR(20),
    generation_fossil_coal_derived_gas      VARCHAR(20),
    generation_fossil_gas                   VARCHAR(20),
    generation_fossil_hard_coal             VARCHAR(20),
    generation_fossil_oil                   VARCHAR(20),
    generation_fossil_oil_shale             VARCHAR(20),
    generation_fossil_peat                  VARCHAR(20),
    generation_geothermal                   VARCHAR(20),
    generation_hydro_pumped_storage_agg     VARCHAR(20),
    generation_hydro_pumped_storage_cons    VARCHAR(20),
    generation_hydro_run_of_river           VARCHAR(20),
    generation_hydro_water_reservoir        VARCHAR(20),
    generation_marine                       VARCHAR(20),
    generation_nuclear                      VARCHAR(20),
    generation_other                        VARCHAR(20),
    generation_other_renewable              VARCHAR(20),
    generation_solar                        VARCHAR(20),
    generation_waste                        VARCHAR(20),
    generation_wind_offshore                VARCHAR(20),
    generation_wind_onshore                 VARCHAR(20),
    forecast_solar_day_ahead                VARCHAR(20),
    forecast_wind_offshore_eday_ahead       VARCHAR(20),
    forecast_wind_onshore_day_ahead         VARCHAR(20),
    total_load_forecast                     VARCHAR(20),
    total_load_actual                       VARCHAR(20),
    price_day_ahead                         VARCHAR(20),
    price_actual                            VARCHAR(20)
);

-- CLEAN TABLE
-- Derived from raw_energy with the following changes:
-- 1. timestamp properly parsed from VARCHAR to DATETIME
-- 2. Empty strings converted to NULL using NULLIF
-- 3. Two fully empty columns dropped:
--    - generation_hydro_pumped_storage_agg (100% empty)
--    - forecast_wind_offshore_eday_ahead   (100% empty)
-- 4. All numeric columns converted from VARCHAR to FLOAT
CREATE TABLE IF NOT EXISTS clean_energy (
    id                                    INT AUTO_INCREMENT PRIMARY KEY,
    timestamp                             DATETIME,
    generation_biomass                    FLOAT,
    generation_fossil_brown_coal          FLOAT,
    generation_fossil_coal_derived_gas    FLOAT,
    generation_fossil_gas                 FLOAT,
    generation_fossil_hard_coal           FLOAT,
    generation_fossil_oil                 FLOAT,
    generation_fossil_oil_shale           FLOAT,
    generation_fossil_peat                FLOAT,
    generation_geothermal                 FLOAT,
    generation_hydro_pumped_storage_cons  FLOAT,
    generation_hydro_run_of_river         FLOAT,
    generation_hydro_water_reservoir      FLOAT,
    generation_marine                     FLOAT,
    generation_nuclear                    FLOAT,
    generation_other                      FLOAT,
    generation_other_renewable            FLOAT,
    generation_solar                      FLOAT,
    generation_waste                      FLOAT,
    generation_wind_offshore              FLOAT,
    generation_wind_onshore               FLOAT,
    forecast_solar_day_ahead              FLOAT,
    forecast_wind_onshore_day_ahead       FLOAT,
    total_load_forecast                   FLOAT,
    total_load_actual                     FLOAT,
    price_day_ahead                       FLOAT,
    price_actual                          FLOAT
);
