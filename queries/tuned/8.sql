# 8. Rolling 7-day average delay per major airport.
# served by dest_airport_rolling_delay, see sql/02_aggregates.sql

SELECT
  dest_airport_id,
  sum(flight_volume) as flight_volume,
  avgIfMerge(avg_delay_7_days) as avg_delay_7_days
FROM
  dest_airport_rolling_delay
GROUP BY dest_airport_id
ORDER BY flight_volume DESC
LIMIT 10;
