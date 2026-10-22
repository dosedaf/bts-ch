# 4. Number and percentage of flights cancelled, broken down by cancellation reason, by quarter.
# served by quarterly_summary, see sql/02_aggregates.sql

SELECT
  quarter,
  sum(total_cancelled_flights) as total_cancelled_flights,
  total_cancelled_flights * 100 / sum(total_flights) as cancel_rate,
  sum(A) as A,
  sum(B) as B,
  sum(C) as C,
  sum(D) as D
FROM
  quarterly_summary
GROUP BY quarter
ORDER BY total_cancelled_flights DESC
