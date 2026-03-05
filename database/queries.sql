USE energy_db;

-- Query 1: Energy source reliability (variability analysis)
-- Higher variability % = less reliable/predictable output
SELECT
    'solar'          AS source,
    ROUND(AVG(generation_solar), 2) AS avg_output_mw,
    ROUND(STDDEV(generation_solar), 2) AS std_dev,
    ROUND((STDDEV(generation_solar) / NULLIF(AVG(generation_solar), 0)) * 100, 2) AS variability_pct
FROM clean_energy
UNION ALL
SELECT 'wind onshore',
    ROUND(AVG(generation_wind_onshore), 2),
    ROUND(STDDEV(generation_wind_onshore), 2),
    ROUND((STDDEV(generation_wind_onshore) / NULLIF(AVG(generation_wind_onshore), 0)) * 100, 2)
FROM clean_energy
UNION ALL
SELECT 'fossil gas',
    ROUND(AVG(generation_fossil_gas), 2),
    ROUND(STDDEV(generation_fossil_gas), 2),
    ROUND((STDDEV(generation_fossil_gas) / NULLIF(AVG(generation_fossil_gas), 0)) * 100, 2)
FROM clean_energy
UNION ALL
SELECT 'fossil hard coal',
    ROUND(AVG(generation_fossil_hard_coal), 2),
    ROUND(STDDEV(generation_fossil_hard_coal), 2),
    ROUND((STDDEV(generation_fossil_hard_coal) / NULLIF(AVG(generation_fossil_hard_coal), 0)) * 100, 2)
FROM clean_energy
UNION ALL
SELECT 'nuclear',
    ROUND(AVG(generation_nuclear), 2),
    ROUND(STDDEV(generation_nuclear), 2),
    ROUND((STDDEV(generation_nuclear) / NULLIF(AVG(generation_nuclear), 0)) * 100, 2)
FROM clean_energy
ORDER BY variability_pct DESC;

-- Query 2: Monthly average price trend (2015-2018)
SELECT
    YEAR(timestamp)  AS year,
    MONTH(timestamp) AS month,
    ROUND(AVG(price_actual), 2)  AS avg_price,
    ROUND(MIN(price_actual), 2)  AS min_price,
    ROUND(MAX(price_actual), 2)  AS max_price
FROM clean_energy
GROUP BY year, month
ORDER BY year, month;

-- Query 3: Demand forecast accuracy by year
SELECT
    YEAR(timestamp) AS year,
    ROUND(AVG(ABS(total_load_actual - total_load_forecast)), 2)         AS avg_error_mw,
    ROUND(AVG(total_load_actual), 2)                                    AS avg_actual_load,
    ROUND((AVG(ABS(total_load_actual - total_load_forecast)) /
           AVG(total_load_actual)) * 100, 2)                            AS error_pct
FROM clean_energy
WHERE total_load_actual IS NOT NULL
AND total_load_forecast IS NOT NULL
GROUP BY year
ORDER BY year;

-- Query 4: Average output per energy source (ranked)
SELECT
    'biomass'               AS source, ROUND(AVG(generation_biomass), 2)             AS avg_mw FROM clean_energy UNION ALL
SELECT 'fossil brown coal',             ROUND(AVG(generation_fossil_brown_coal), 2)   FROM clean_energy UNION ALL
SELECT 'fossil gas',                    ROUND(AVG(generation_fossil_gas), 2)           FROM clean_energy UNION ALL
SELECT 'fossil hard coal',              ROUND(AVG(generation_fossil_hard_coal), 2)     FROM clean_energy UNION ALL
SELECT 'fossil oil',                    ROUND(AVG(generation_fossil_oil), 2)            FROM clean_energy UNION ALL
SELECT 'nuclear',                       ROUND(AVG(generation_nuclear), 2)               FROM clean_energy UNION ALL
SELECT 'solar',                         ROUND(AVG(generation_solar), 2)                 FROM clean_energy UNION ALL
SELECT 'wind onshore',                  ROUND(AVG(generation_wind_onshore), 2)          FROM clean_energy UNION ALL
SELECT 'hydro run of river',            ROUND(AVG(generation_hydro_run_of_river), 2)    FROM clean_energy UNION ALL
SELECT 'hydro water reservoir',         ROUND(AVG(generation_hydro_water_reservoir), 2) FROM clean_energy UNION ALL
SELECT 'other renewable',               ROUND(AVG(generation_other_renewable), 2)       FROM clean_energy
ORDER BY avg_mw DESC;

-- Query 5: Renewable vs fossil generation comparison by year
SELECT
    YEAR(timestamp) AS year,
    ROUND(AVG(
        generation_solar + generation_wind_onshore +
        generation_hydro_run_of_river + generation_hydro_water_reservoir +
        generation_other_renewable + generation_biomass
    ), 2) AS avg_renewable_mw,
    ROUND(AVG(
        generation_fossil_gas + generation_fossil_hard_coal +
        generation_fossil_brown_coal + generation_fossil_oil
    ), 2) AS avg_fossil_mw
FROM clean_energy
GROUP BY year
ORDER BY year;
