-- Tuned structures: summary tables, materialized views, projection, backfills.
-- Extracted from the original tuned queries, unchanged semantically.
-- Apply after data load (load.sh does 01, then data, then 02 and 03).

-- ====================================================================
-- 1. Average delay by carrier by month
--    serves queries/tuned/1.sql
-- ====================================================================
DROP TABLE IF EXISTS mv_avg_delays_by_carrier_month;
DROP TABLE IF EXISTS avg_delays_by_carrier_month;

CREATE TABLE avg_delays_by_carrier_month
(
    dot_id_reporting_airline UInt32,
    month Date,
    avg_dep_delay AggregateFunction(avgIf, Float32, Bool),
    avg_arr_delay AggregateFunction(avgIf, Float32, Bool)
)
ENGINE = AggregatingMergeTree
ORDER BY (dot_id_reporting_airline, month);

CREATE MATERIALIZED VIEW mv_avg_delays_by_carrier_month TO avg_delays_by_carrier_month AS
SELECT
    dot_id_reporting_airline,
    toStartOfMonth(flight_date) AS month,
    avgIfState(dep_delay, cancelled = false) AS avg_dep_delay,
    avgIfState(arr_delay, cancelled = false) AS avg_arr_delay
FROM flights
GROUP BY 1, 2;

-- backfill history; the MV covers inserts from now on
INSERT INTO avg_delays_by_carrier_month
SELECT
    dot_id_reporting_airline,
    toStartOfMonth(flight_date) AS month,
    avgIfState(dep_delay, cancelled = false) AS avg_dep_delay,
    avgIfState(arr_delay, cancelled = false) AS avg_arr_delay
FROM flights
GROUP BY 1, 2;

-- ====================================================================
-- 2. Route and carrier yearly summary
--    serves queries/tuned/2.sql, 3.sql, 7.sql
-- ====================================================================
DROP TABLE IF EXISTS airport_routes_yearly_summary;

CREATE TABLE airport_routes_yearly_summary
(
    origin_airport_id UInt32,
    dest_airport_id UInt32,
    year UInt16,
    dot_id_reporting_airline UInt32,
    total_flights SimpleAggregateFunction(sum, UInt64),
    total_confirmed_flights SimpleAggregateFunction(sum, UInt64),
    avg_delay AggregateFunction(avg, Float32),
    total_ontime_flights UInt64
)
ENGINE = AggregatingMergeTree
ORDER BY (origin_airport_id, dest_airport_id, year, dot_id_reporting_airline);

INSERT INTO airport_routes_yearly_summary
SELECT
    origin_airport_id,
    dest_airport_id,
    year,
    dot_id_reporting_airline,
    count() AS total_flights,
    countIf(cancelled = false) AS total_confirmed_flights,
    avgIfState(arr_delay, cancelled = false) AS avg_delay,
    countIf(arr_del15 = false AND cancelled = false) AS total_ontime_flights
FROM flights
GROUP BY 1, 2, 3, 4;

-- ====================================================================
-- 4. Cancellations by reason by quarter
--    serves queries/tuned/4.sql
-- ====================================================================
DROP TABLE IF EXISTS quarterly_summary;

CREATE TABLE quarterly_summary
(
    quarter UInt8,
    total_cancelled_flights UInt64,
    total_flights UInt64,
    A UInt64,
    B UInt64,
    C UInt64,
    D UInt64
)
ENGINE = SummingMergeTree
ORDER BY quarter;

INSERT INTO quarterly_summary
SELECT
    quarter,
    countIf(cancelled) AS total_cancelled_flights,
    count() AS total_flights,
    countIf(cancellation_code = 'A') AS A,
    countIf(cancellation_code = 'B') AS B,
    countIf(cancellation_code = 'C') AS C,
    countIf(cancellation_code = 'D') AS D
FROM flights
GROUP BY quarter;

-- ====================================================================
-- 5. Aircraft lookup on a date
--    projection on flights, serves queries/tuned/5.sql
-- ====================================================================
ALTER TABLE flights DROP PROJECTION IF EXISTS prj_aircraft_date;
ALTER TABLE flights ADD PROJECTION prj_aircraft_date
(
    SELECT *
    ORDER BY flight_date
);
ALTER TABLE flights MATERIALIZE PROJECTION prj_aircraft_date;

-- ====================================================================
-- 6. Departure delay distribution by day of week
--    carries both quantile families: reservoir (fast) and exact
--    serves queries/tuned/6_approx.sql and 6_exact.sql
-- ====================================================================
DROP TABLE IF EXISTS dow_summary;

CREATE TABLE dow_summary
(
    day_of_week UInt8,
    min_dep_delay SimpleAggregateFunction(min, Float32),
    max_dep_delay SimpleAggregateFunction(max, Float32),
    avg_dep_delay AggregateFunction(avgIf, Float32, Bool),
    p50 AggregateFunction(quantileIf(0.50), Float32, Bool),
    p90 AggregateFunction(quantileIf(0.90), Float32, Bool),
    p99 AggregateFunction(quantileIf(0.99), Float32, Bool),
    p50e AggregateFunction(quantileExactIf(0.50), Float32, Bool),
    p90e AggregateFunction(quantileExactIf(0.90), Float32, Bool),
    p99e AggregateFunction(quantileExactIf(0.99), Float32, Bool)
)
ENGINE = AggregatingMergeTree
ORDER BY day_of_week;

INSERT INTO dow_summary
SELECT
    day_of_week,
    minIf(dep_delay, cancelled = false) AS min_dep_delay,
    maxIf(dep_delay, cancelled = false) AS max_dep_delay,
    avgIfState(dep_delay, cancelled = false) AS avg_dep_delay,
    quantileIfState(0.50)(dep_delay, cancelled = false) AS p50,
    quantileIfState(0.90)(dep_delay, cancelled = false) AS p90,
    quantileIfState(0.99)(dep_delay, cancelled = false) AS p99,
    quantileExactIfState(0.50)(dep_delay, cancelled = false) AS p50e,
    quantileExactIfState(0.90)(dep_delay, cancelled = false) AS p90e,
    quantileExactIfState(0.99)(dep_delay, cancelled = false) AS p99e
FROM flights
GROUP BY day_of_week;

-- ====================================================================
-- 8. Rolling 7-day delay per destination airport
--    serves queries/tuned/8.sql
-- ====================================================================
DROP TABLE IF EXISTS dest_airport_rolling_delay;

CREATE TABLE dest_airport_rolling_delay
(
    dest_airport_id UInt32,
    flight_volume SimpleAggregateFunction(sum, UInt64),
    avg_delay_7_days AggregateFunction(avgIf, Float32, Bool)
)
ENGINE = AggregatingMergeTree
ORDER BY dest_airport_id;

INSERT INTO dest_airport_rolling_delay
SELECT
    dest_airport_id,
    countIf(cancelled = false) AS flight_volume,
    avgIfState(arr_delay, cancelled = false AND flight_date >= '2023-09-27' - INTERVAL 7 DAY) AS avg_delay_7_days
FROM flights
GROUP BY dest_airport_id;

-- ====================================================================
-- 9. Flight counts per day
--    serves queries/tuned/9.sql
-- ====================================================================
DROP TABLE IF EXISTS daily_summary;

CREATE TABLE daily_summary
(
    flight_date Date,
    total_confirmed_flights UInt64,
    total_flights UInt64
)
ENGINE = SummingMergeTree
ORDER BY flight_date;

INSERT INTO daily_summary
SELECT
    flight_date,
    countIf(cancelled = false),
    count() AS total_flights
FROM flights
GROUP BY 1;
