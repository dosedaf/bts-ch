drop table dow_summary;

CREATE TABLE dow_summary (
  day_of_week UInt8,
  min_dep_delay SimpleAggregateFunction(min, Float32),
  max_dep_delay SimpleAggregateFunction(max, Float32),
  avg_dep_delay AggregateFunction(avgIf, Float32, Bool),
  p50 AggregateFunction(quantileIf(0.50), Float32, Bool),
  p90 AggregateFunction(quantileIf(.90), Float32, Bool),
  p99 AggregateFunction(quantileIf(0.99), Float32, Bool),
  p50e AggregateFunction(quantileExactIf(0.50), Float32, Bool),
  p90e AggregateFunction(quantileExactIf(.90), Float32, Bool),
  p99e AggregateFunction(quantileExactIf(0.99), Float32, Bool)
)
ENGINE AggregatingMergeTree()
ORDER BY day_of_week;

INSERT INTO dow_summary
SELECT
    day_of_week,
    minIf(dep_delay, cancelled = false) as min_dep_delay,
    maxIf(dep_delay, cancelled = false) as max_dep_delay,
    avgIfState(dep_delay, cancelled = false) as avg_dep_delay,
    quantileIfState(0.50)(dep_delay, cancelled = false) as p50,
    quantileIfState(0.90)(dep_delay, cancelled = false) as p90,
    quantileIfState(0.99)(dep_delay, cancelled = false) as p99,
    quantileExactIfState(0.50)(dep_delay, cancelled = false) as p50e,
    quantileExactIfState(0.90)(dep_delay, cancelled = false) as p90e,
    quantileExactIfState(0.99)(dep_delay, cancelled = false) as p99e
FROM flights
GROUP BY day_of_week;

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
