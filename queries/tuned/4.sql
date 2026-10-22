drop table quarterly_summary;

# make sure row count nya sama di source tablenya.

CREATE TABLE quarterly_summary (
  quarter UInt8,
  total_cancelled_flights UInt64,
  total_flights UInt64,
  A UInt64,
  B UInt64,
  C UInt64,
  D UInt64
)
ENGINE = SummingMergeTree()
ORDER BY quarter;

# find better schemma cuz this looks terrible

INSERT INTO quarterly_summary
SELECT
  quarter,
  countIf(cancelled) as total_cancelled_flights,
  count() as total_flights,
  countIf(cancellation_code = 'A') as A,
  countIf(cancellation_code = 'B') as B,
  countIf(cancellation_code = 'C') as C,
  countIf(cancellation_code = 'D') as D
FROM flights
GROUP BY quarter;

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


