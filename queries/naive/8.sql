# 8. Rolling 7-day average delay per major airport.
# by major i assume flight volume.
# cuz data is 2017-2024 then current date is let's say something like 2023-09-27
# what airport?  i assume arr delay for dest airport

# top 10 major airport by volume
# avg delay tiap airport, di 7 hari kemarin, brati rollingnya tiap row

# susah sih

SELECT
  dest_airport_id,
  countIf(cancelled = false) as flight_volume,
  avgIf(arr_delay, cancelled = false AND flight_date >= '2023-09-27' - INTERVAL 7 DAY) as avg_delay_7_days
FROM flights
GROUP BY dest_airport_id
ORDER BY flight_volume DESC
LIMIT 10;