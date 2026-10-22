# 4. Number and percentage of flights cancelled, broken down by cancellation reason, by quarter.

CREATE DICTIONARY cancellation_reason_dict
(
    code String,
    reason String
)
PRIMARY KEY code
SOURCE(CLICKHOUSE(
    user 'default'
    password ''
    QUERY '
        SELECT ''A'' AS code, ''Air Carrier'' AS reason
        UNION ALL SELECT ''B'', ''Weather''
        UNION ALL SELECT ''C'', ''National Aviation System''
        UNION ALL SELECT ''D'', ''Security''
    '
))
LAYOUT(HASHED())
LIFETIME(0);

# 4. Number and percentage of flights cancelled, broken down by cancellation reason, by quarter.
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

