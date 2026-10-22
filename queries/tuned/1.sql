# drop table avg_delays_by_carrier_month
# drop table mv_avg_delays_by_carrier_month;

# over full date range, makanya gua ga partition by
# terlalu spesifik ga? kita bener2 jawab kek tiap pertanyaan pake table gitu. reasonable ga ya?

# drop table avg_delays_by_carrier_month

CREATE TABLE avg_delays_by_carrier_month (
  dot_id_reporting_airline UInt32,
  month Date,
  avg_dep_delay AggregateFunction(avgIf, Float32, Bool),
  avg_arr_delay AggregateFunction(avgIf, Float32, Bool)
)
ENGINE AggregatingMergeTree()
ORDER BY (dot_id_reporting_airline, month);

CREATE MATERIALIZED VIEW mv_avg_delays_by_carrier_month TO avg_delays_by_carrier_month AS
SELECT
    dot_id_reporting_airline,
    toStartOfMonth(flight_date) as month,
    avgIfState(dep_delay, cancelled = false) as avg_dep_delay,
    avgIfState(arr_delay, cancelled = false) as avg_arr_delay
FROM flights
GROUP BY 1, 2;

INSERT INTO avg_delays_by_carrier_month 
SELECT
    dot_id_reporting_airline,
    toStartOfMonth(flight_date) as month,
    avgIfState(dep_delay, cancelled = false) as avg_dep_delay,
    avgIfState(arr_delay, cancelled = false) as avg_arr_delay
FROM flights
GROUP BY 1, 2;

SELECT 
    dot_id_reporting_airline,
    month,
    avgIfMerge(avg_dep_delay) as avg_dep_delay,
    avgIfMerge(avg_arr_delay) as avg_arr_delay
FROM avg_delays_by_carrier_month
GROUP BY 1, 2
ORDER BY avg_arr_delay DESC;
