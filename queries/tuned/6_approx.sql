# 6. Distribution of departure delay (min, max, avg, p50, p90, p99) by day of week.
# reservoir quantile states: p50 exact on all 7 days, p90 within ~3 pts, worst p99 +10.1%
# served by dow_summary, see sql/02_aggregates.sql

SELECT
  day_of_week,
  min(min_dep_delay) as min_dep_delay,
  max(max_dep_delay) as max_dep_delay,
  avgIfMerge(avg_dep_delay) as avg_dep_delay,
  quantileIfMerge(0.50)(p50) as p50,
  quantileIfMerge(0.90)(p90) as p90,
  quantileIfMerge(0.99)(p99) as p99
FROM dow_summary
GROUP BY day_of_week;
