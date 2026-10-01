SELECT 
  dest_airport_id,
  year,
  sum(total_ontime_flights) * 100 / total_confirmed_flights as ontime_rate,
  sum(total_confirmed_flights) as total_confirmed_flights
FROM airport_routes_yearly_summary
GROUP BY 1, 2
HAVING total_confirmed_flights > 1000
ORDER BY (ontime_rate, dest_airport_id, year) DESC # tie breakers