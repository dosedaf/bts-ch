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
