# 9. Count of flights per day across the entire dataset's history.

SELECT
  flight_date,
  countIf(cancelled = false) as total_confirmed_flights,
  count() as total_flights
FROM flights
GROUP BY flight_date
ORDER BY flight_date DESC;