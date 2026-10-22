drop table daily_summary;

CREATE TABLE daily_summary (
  flight_date Date,
  total_confirmed_flights UInt64,
  total_flights UInt64
)
ENGINE = SummingMergeTree()
ORDER BY flight_date;

INSERT INTO daily_summary
SELECT
  flight_date,
  countIf(cancelled = false),
  count() as total_flights
FROM flights
GROUP BY 1;

SELECT 
  flight_date,
  sum(total_confirmed_flights) as total_confirmed_flights,
  sum(total_flights) as total_flights
FROM daily_summary
GROUP BY 1
ORDER BY flight_date DESC;