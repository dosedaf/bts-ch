CREATE TABLE dest_airport_rolling_delay (
  dest_airport_id UInt32,
  flight_volume SimpleAggregateFunction(sum, UInt64),
  avg_delay_7_days AggregateFunction(avgIf, Float32, Bool)
)
ENGINE = AggregatingMergeTree()
ORDER BY dest_airport_id;

INSERT INTO dest_airport_rolling_delay
SELECT
  dest_airport_id,
  countIf(cancelled = false) as flight_volume,
  avgIfState(arr_delay, cancelled = false AND flight_date >= '2023-09-27' - INTERVAL 7 DAY) as avg_delay_7_days
FROM
  flights
GROUP BY dest_airport_id;

SELECT 
  dest_airport_id,
  sum(flight_volume) as flight_volume,
  avgIfMerge(avg_delay_7_days) as avg_delay_7_days
FROM
  dest_airport_rolling_delay
GROUP BY dest_airport_id
ORDER BY flight_volume DESC
LIMIT 10;
