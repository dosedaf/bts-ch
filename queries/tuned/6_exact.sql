# 6. Distribution of departure delay (min, max, avg, p50, p90, p99) by day of week.
# exact quantile states: full accuracy, no speed win, the states hold every value
# served by dow_summary, see sql/02_aggregates.sql

SELECT
  day_of_week,
  min(min_dep_delay) as min_dep_delay,
  max(max_dep_delay) as max_dep_delay,
  avgIfMerge(avg_dep_delay) as avg_dep_delay,
  quantileExactIfMerge(0.50)(p50e) as p50e,
  quantileExactIfMerge(0.90)(p90e) as p90e,
  quantileExactIfMerge(0.99)(p99e) as p99e
FROM dow_summary
GROUP BY day_of_week;
