# 9. Count of flights per day across the entire dataset's history.
# served by daily_summary, see sql/02_aggregates.sql

SELECT
  flight_date,
  sum(total_confirmed_flights) as total_confirmed_flights,
  sum(total_flights) as total_flights
FROM daily_summary
GROUP BY 1
ORDER BY flight_date DESC;
