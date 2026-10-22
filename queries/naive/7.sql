# 7. Total flights and average delay by airport and by carrier, joined with airport metadata (state, city, name).
# airport_dict lives in sql/03_dictionaries.sql, it is built from flights itself

# avg delay pasti arr_del15, arrival, tapi airpot bisa aja arrival, bisa aja ngga, kata gua 2 2 nya ngefek ga sih. kek rute gitu. brati kita ambil 2 airport? 
# atau emg nyari metrik delay arrival di airport A dgn reporting airline aja, ambigu jujur
# ato bisa aja juga, carrier A, berangkat dri airport A delaynya biasanya brapa si? git uapa ya

# assumptions, ordered by what i think is most right. 
# 1. dep airport only -> carrier A that dep-ed from airport A usually arr del x minutes, could be dep delay too.
# 2. arr airport only -> carrier A that arr-ed to airport A usually arr del x minutes
# 3. both, so more of a router airport a to airport b -> for a carrier, that dep from airport a to airport b. what's the delay usually look like

# i'll go with num 2

# airport metadata
SELECT 
  dest_airport_id,
  dot_id_reporting_airline,
  dictGet('airport_dict', 'state', dest_airport_id) as state,
  dictGet('airport_dict', 'city', dest_airport_id) as city,
  countIf(cancelled = false) as total_confirmed_flights,
  avgIf(arr_delay, cancelled = false) as avg_delay # if for safety net
FROM flights
GROUP BY (dest_airport_id, dot_id_reporting_airline)
HAVING total_confirmed_flights > 1000
ORDER BY avg_delay DESC
