# 6. Distribution of departure delay (min, max, avg, p50, p90, p99) by day of week.

SELECT
    day_of_week,
    minIf(dep_delay, cancelled = false) as min_dep_delay,
    # min(CASE WHEN dep_delay > 0 THEN dep_delay END) as min_dep_delay,
    maxIf(dep_delay, cancelled = false) as max_dep_delay,
    # avg(dep_delay),
    # sumIf(dep_delay, cancelled = false) / countIf(cancelled = false) as avg_dep_delay,
    avgIf(dep_delay, cancelled = false) as avg_dep_delay,
    # apa yang dipercentile in hah? dep delay GOBLOK
    quantileExactIf(0.50)(dep_delay, cancelled = false) as p50,
    quantileExactIf(0.90)(dep_delay, cancelled = false) as p90,
    quantileExactIf(0.99)(dep_delay, cancelled = false) as p99
FROM flights
GROUP BY day_of_week