# 7. Total flights and average delay by airport and by carrier, joined with airport metadata (state, city, name).
# served by airport_routes_yearly_summary plus airport_dict
# see sql/02_aggregates.sql and sql/03_dictionaries.sql

SELECT
  dest_airport_id,
  dot_id_reporting_airline,
  dictGet('airport_dict', 'state', dest_airport_id) as state,
  dictGet('airport_dict', 'city', dest_airport_id) as city,
  sum(total_confirmed_flights) as total_confirmed_flights,
  avgMerge(avg_delay) as avg_delay
FROM airport_routes_yearly_summary
GROUP BY 1,2
HAVING total_confirmed_flights > 1000
ORDER BY avg_delay DESC;
