# 10. Carriers ranked by on-time performance for a given origin airport, for a given season (e.g. summer months).

# input origin airport, given season, hardcoded months for summer

SELECT
  dot_id_reporting_airline,
  countIf(cancelled = false) as total_confirmed_flights,
  countIf(arr_del15 = false AND cancelled = false) * 100 / countIf(cancelled = false) as on_time_rate
FROM flights
WHERE flight_date >= '2023-05-01' and flight_date <= '2023-08-31' AND origin = 'ATL'  # summer months sama top 1 origin airport by volume
GROUP BY dot_id_reporting_airline 
HAVING total_confirmed_flights >= 1000
ORDER BY on_time_rate DESC