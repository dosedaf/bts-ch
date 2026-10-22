# 4. Number and percentage of flights cancelled, broken down by cancellation reason, by quarter.
# cancellation_reason_dict lives in sql/03_dictionaries.sql

SELECT
  quarter,
  countIf(cancelled) as total_cancelled_flights,
  countIf(cancelled) * 100 / count() as cancel_rate,
  countIf(cancellation_code = 'A') as A,
  countIf(cancellation_code = 'B') as B,
  countIf(cancellation_code = 'C') as C,
  countIf(cancellation_code = 'D') as D
  # dictGet('cancellation_reason_dict', 'reason', cancellation_code) as cancellation_reason
FROM flights
GROUP BY quarter
