CREATE DATABASE IF NOT EXISTS market;
USE market; 
SELECT * FROM mytable LIMIT 10;
-- Insepect the columns
SHOW COLUMNS from mytable;
/*
SELECT = which columns do I want to see?
FROM = which table is the data in?
WHERE = which rows do I want to filter?
GROUP BY = how do I want to summarize?
ORDER BY = how do I want to sort?
LIMIT = how many rows do I want to show?
*/

-- Which market has the highest average price?
SELECT
	AVG(pjmc_rt_lmp) as avg_pjm_price,
    AVG(miso_rt_lmp) as avg_miso_price
FROM mytable;
-- pjm (34.83139128849164) and miso (33.46769516559171)

-- Which market is more volatile 
-- Volatility means how much prices swing up and down

SELECT 
	STDDEV(pjmc_rt_lmp) as pjm_volatility,
	STDDEV(miso_rt_lmp) as miso_volatility
FROM mytable;
-- pjm (31.732708068320544) and miso (28.26933824905419)

-- How do prices vary by hour of day
USE market;

SELECT
    date_time,
    STR_TO_DATE(TRIM(date_time), '%c/%e/%Y %H:%i') AS date_time_converted
FROM mytable
LIMIT 20;

UPDATE mytable
SET date_time_clean = STR_TO_DATE(TRIM(date_time), '%c/%e/%Y %H:%i');
SELECT
    HOUR(date_time_clean) AS hour_of_day,
    AVG(pjmc_rt_lmp) AS avg_pjm_price,
    AVG(miso_rt_lmp) AS avg_miso_price
FROM mytable
GROUP BY HOUR(date_time_clean)
ORDER BY hour_of_day;

-- Are ON-peak hours more expensive than OFF-peak hours?
SELECT
    on_off,
    AVG(pjmc_rt_lmp) AS avg_pjm_price,
    AVG(miso_rt_lmp) AS avg_miso_price
FROM mytable
GROUP BY on_off;

-- How do prices vary by month
SELECT
    YEAR(date_time_clean) AS year_num,
    MONTH(date_time_clean) AS month_num,
    AVG(pjmc_rt_lmp) AS avg_pjm_price,
    AVG(miso_rt_lmp) AS avg_miso_price
FROM mytable
GROUP BY YEAR(date_time_clean), MONTH(date_time_clean)
ORDER BY year_num, month_num;

-- Which season is most expensive and volatile
SELECT
    CASE
        WHEN MONTH(date_time_clean) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(date_time_clean) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(date_time_clean) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    AVG(pjmc_rt_lmp) AS avg_pjm_price,
    AVG(miso_rt_lmp) AS avg_miso_price,
    STDDEV(pjmc_rt_lmp) AS pjm_volatility,
    STDDEV(miso_rt_lmp) AS miso_volatility
FROM mytable
GROUP BY season;

-- When do prices jump the most from one hour to the next?
-- pjm
SELECT *
FROM (
    SELECT
        date_time_clean,
        pjmc_rt_lmp,
        pjmc_rt_lmp - LAG(pjmc_rt_lmp) OVER (ORDER BY date_time_clean) AS pjm_hourly_change
    FROM mytable
) t
WHERE pjm_hourly_change IS NOT NULL
ORDER BY pjm_hourly_change DESC
LIMIT 10;

-- miso
SELECT *
FROM (
    SELECT
        date_time_clean,
        miso_rt_lmp,
        miso_rt_lmp - LAG(miso_rt_lmp) OVER (ORDER BY date_time_clean) AS miso_hourly_change
    FROM mytable
) t
WHERE miso_hourly_change IS NOT NULL
ORDER BY miso_hourly_change DESC
LIMIT 10;

-- average for pjm
SELECT
    HOUR(date_time_clean) AS hour_of_day,
    AVG(pjm_hourly_change) AS avg_pjm_hourly_change,
    AVG(miso_hourly_change) AS avg_miso_hourly_change
FROM (
    SELECT
        date_time_clean,
        pjmc_rt_lmp - LAG(pjmc_rt_lmp) OVER (ORDER BY date_time_clean) AS pjm_hourly_change,
        miso_rt_lmp - LAG(miso_rt_lmp) OVER (ORDER BY date_time_clean) AS miso_hourly_change
    FROM mytable
) t
WHERE pjm_hourly_change IS NOT NULL
  AND miso_hourly_change IS NOT NULL
GROUP BY HOUR(date_time_clean)
ORDER BY avg_pjm_hourly_change DESC;

-- Are higher loads associated with higher prices
-- pjm
SELECT
    CASE
        WHEN pjm_rtload < 500 THEN 'Low Load'
        WHEN pjm_rtload < 1000 THEN 'Medium Load'
        ELSE 'High Load'
    END AS pjm_load_bucket,
    AVG(pjmc_rt_lmp) AS avg_pjm_price,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY pjm_load_bucket;

-- How do real-time prices compare to predicted prices by month
SELECT
    YEAR(date_time_clean) AS year_num,
    MONTH(date_time_clean) AS month_num,
    AVG(CAST(pjmc_rt_lmp AS DECIMAL(10,2)) - pjmc_da_lmp) AS avg_pjm_rt_minus_da,
    AVG(CAST(miso_rt_lmp AS DECIMAL(10,2)) - miso_da_lmp) AS avg_miso_rt_minus_da
FROM mytable
GROUP BY YEAR(date_time_clean), MONTH(date_time_clean)
ORDER BY year_num, month_num;

-- weekday vs weekend prices
SELECT
    CASE
        WHEN weekday IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    AVG(CAST(pjmc_rt_lmp AS DECIMAL(10,2))) AS avg_pjm_price,
    AVG(CAST(miso_rt_lmp AS DECIMAL(10,2))) AS avg_miso_price,
    STDDEV(CAST(pjmc_rt_lmp AS DECIMAL(10,2))) AS pjm_volatility,
    STDDEV(CAST(miso_rt_lmp AS DECIMAL(10,2))) AS miso_volatility
FROM mytable
GROUP BY day_type;

-- Does higher gas generation correspond to higher or lower prices?
-- pjm
SELECT
    CASE
        WHEN CAST(REPLACE(PJM_GAS_Gen, ',', '') AS DECIMAL(12,2)) < 20000 THEN 'Low Gas'
        WHEN CAST(REPLACE(PJM_GAS_Gen, ',', '') AS DECIMAL(12,2)) < 30000 THEN 'Medium Gas'
        ELSE 'High Gas'
    END AS gas_bucket,
    AVG(CAST(PJMC_RT_LMP AS DECIMAL(10,2))) AS avg_pjm_price,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY gas_bucket
ORDER BY avg_pjm_price;

-- miso
SELECT
    CASE
        WHEN CAST(REPLACE(MISO_GAS_GEN, ',', '') AS DECIMAL(12,2)) < 15000 THEN 'Low Gas'
        WHEN CAST(REPLACE(MISO_GAS_GEN, ',', '') AS DECIMAL(12,2)) < 25000 THEN 'Medium Gas'
        ELSE 'High Gas'
    END AS gas_bucket,
    AVG(CAST(MISO_RT_LMP AS DECIMAL(10,2))) AS avg_miso_price,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY gas_bucket
ORDER BY avg_miso_price;

-- How do coal, nuclear, and hydro output relate to price levels?
-- miso nuclear
SELECT
    CASE
        WHEN CAST(REPLACE(MISO_Nuclear_Gen, ',', '') AS DECIMAL(12,2)) < 10000 THEN 'Low Nuclear'
        WHEN CAST(REPLACE(MISO_Nuclear_Gen, ',', '') AS DECIMAL(12,2)) < 11000 THEN 'Medium Nuclear'
        ELSE 'High Nuclear'
    END AS nuclear_bucket,
    AVG(CAST(MISO_RT_LMP AS DECIMAL(10,2))) AS avg_miso_price,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY nuclear_bucket
ORDER BY avg_miso_price;

-- pjm hydro
SELECT
    CASE
        WHEN CAST(REPLACE(PJM_Hydro_Gen, ',', '') AS DECIMAL(12,2)) < 300 THEN 'Low Hydro'
        WHEN CAST(REPLACE(PJM_Hydro_Gen, ',', '') AS DECIMAL(12,2)) < 600 THEN 'Medium Hydro'
        ELSE 'High Hydro'
    END AS hydro_bucket,
    AVG(CAST(PJMC_RT_LMP AS DECIMAL(10,2))) AS avg_pjm_price,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY hydro_bucket
ORDER BY avg_pjm_price;

-- Do ramp imports and exports signal price stress?
-- pjm ramp 
SELECT
    CASE
        WHEN CAST(REPLACE(PJM_Ramp_Imports, ',', '') AS DECIMAL(12,2)) < 800 THEN 'Low Ramp Imports'
        WHEN CAST(REPLACE(PJM_Ramp_Imports, ',', '') AS DECIMAL(12,2)) < 1200 THEN 'Medium Ramp Imports'
        ELSE 'High Ramp Imports'
    END AS ramp_import_bucket,
    AVG(CAST(PJMC_RT_LMP AS DECIMAL(10,2))) AS avg_pjm_price,
    STDDEV(CAST(PJMC_RT_LMP AS DECIMAL(10,2))) AS pjm_volatility,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY ramp_import_bucket
ORDER BY avg_pjm_price;

-- miso ramp exports
SELECT
    CASE
        WHEN CAST(REPLACE(MISO_Ramp_Exports, ',', '') AS DECIMAL(12,2)) < 800 THEN 'Low Ramp Exports'
        WHEN CAST(REPLACE(MISO_Ramp_Exports, ',', '') AS DECIMAL(12,2)) < 1200 THEN 'Medium Ramp Exports'
        ELSE 'High Ramp Exports'
    END AS ramp_export_bucket,
    AVG(CAST(MISO_RT_LMP AS DECIMAL(10,2))) AS avg_miso_price,
    STDDEV(CAST(MISO_RT_LMP AS DECIMAL(10,2))) AS miso_volatility,
    COUNT(*) AS hours_count
FROM mytable
GROUP BY ramp_export_bucket
ORDER BY avg_miso_price;

