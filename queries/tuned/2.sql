# 2. Top 20 routes (origin and destination pairs) by total flight volume and by average delay.
# served by airport_routes_yearly_summary, see sql/02_aggregates.sql

SELECT
  origin_airport_id,
  dest_airport_id,
  sum(total_flights) as total_flights,
  sum(total_confirmed_flights) as total_confirmed_flights,
  avgMerge(avg_delay) as avg_delay
FROM airport_routes_yearly_summary
GROUP BY 1, 2
ORDER BY (total_confirmed_flights, avg_delay) DESC
LIMIT 20;
