# 1. Average departure and arrival delay by carrier, by month, over the full date range.
# served by avg_delays_by_carrier_month, see sql/02_aggregates.sql

SELECT
    dot_id_reporting_airline,
    month,
    avgIfMerge(avg_dep_delay) as avg_dep_delay,
    avgIfMerge(avg_arr_delay) as avg_arr_delay
FROM avg_delays_by_carrier_month
GROUP BY 1, 2
ORDER BY avg_arr_delay DESC;
