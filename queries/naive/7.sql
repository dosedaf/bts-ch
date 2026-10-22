# 7. Total flights and average delay by airport and by carrier, joined with airport metadata (state, city, name).

# avg delay pasti arr_del15, arrival, tapi airpot bisa aja arrival, bisa aja ngga, kata gua 2 2 nya ngefek ga sih. kek rute gitu. brati kita ambil 2 airport? 
# atau emg nyari metrik delay arrival di airport A dgn reporting airline aja, ambigu jujur
# ato bisa aja juga, carrier A, berangkat dri airport A delaynya biasanya brapa si? git uapa ya

# assumptions, ordered by what i think is most right. 
# 1. dep airport only -> carrier A that dep-ed from airport A usually arr del x minutes, could be dep delay too.
# 2. arr airport only -> carrier A that arr-ed to airport A usually arr del x minutes
# 3. both, so more of a router airport a to airport b -> for a carrier, that dep from airport a to airport b. what's the delay usually look like

# i'll go with num 2
# SOURCE(CLICKHOUSE(QUERY 'SELECT PostId, countIf(VoteTypeId = 2) AS UpVotes, countIf(VoteTypeId = 3) AS DownVotes FROM votes GROUP BY PostId'))

# risky kalo pake source origin doang. let's say ada airport yg emg dia ga dep tapi ambil arr aja. tp buat skrg keknya aman deh.
CREATE DICTIONARY airport_dict (
  id String,
  city String,
  state String
)
PRIMARY KEY id
SOURCE(CLICKHOUSE(
  user 'default'
  password ''
  QUERY 'select distinct origin_airport_id as id, origin_city_name as city, origin_state_name as state from flights'
))
LAYOUT(HASHED())
LIFETIME(0);

select dictGet('airport_dict', 'city', '10135');

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

/*
SELECT 
  origin_airport_id,
  dot_id_reporting_airline,
  sum(total_not_cancelled_flights), # re sum 
  sum(avg_arr_delay),
  sum(avg_arr_delay * total_not_cancelled_flights) / sum(total_not_cancelled_flights) as ovr_avg_arr_delay
FROM (
    SELECT
        origin_airport_id,
        dot_id_reporting_airline,
        avgIf(arr_delay, cancelled = false) as avg_arr_delay,
        countIf(cancelled = false) as total_not_cancelled_flights
    FROM
        flights
    GROUP BY (origin_airport_id, dot_id_reporting_airline)
    )
GROUP BY (origin_airport_id, dot_id_reporting_airline)
ORDER BY ovr_avg_arr_delay DESC
