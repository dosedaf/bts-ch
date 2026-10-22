# 3. On-time percentage by airport, by year.
# pake dest, pake arr delay

SELECT
  dest_airport_id,
  year,
  countIf(arr_del15 = false AND cancelled = false) * 100 / countIf(cancelled = false) as ontime_rate,
  countIf(cancelled = false) as total_confirmed_flights
FROM flights
GROUP BY (dest_airport_id, year)
HAVING total_confirmed_flights > 1000
ORDER BY (ontime_rate, dest_airport_id, year) DESC