drop table airport_routes_yearly_summary;

CREATE TABLE airport_routes_yearly_summary (
  origin_airport_id UInt32,
  dest_airport_id UInt32,
  year UInt16,
  dot_id_reporting_airline UInt32,
  total_flights SimpleAggregateFunction(sum, UInt64),
  total_confirmed_flights SimpleAggregateFunction(sum, UInt64),
  avg_delay AggregateFunction(avg, Float32),
  total_ontime_flights UInt64
)
ENGINE = AggregatingMergeTree()
ORDER BY (origin_airport_id, dest_airport_id, year, dot_id_reporting_airline);

INSERT INTO airport_routes_yearly_summary
SELECT
  origin_airport_id,
  dest_airport_id,
  year,
  dot_id_reporting_airline,
  count() as total_flights,
  countIf(cancelled = false) as total_confirmed_flights,
  avgIfState(arr_delay, cancelled = false) as avg_delay,
  countIf(arr_del15 = false AND cancelled = false) as total_ontime_flights
FROM flights
GROUP BY 1, 2, 3, 4;

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

