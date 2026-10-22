-- Dictionaries used by the analytical queries.
-- airport_dict is built FROM flights itself, so apply after the data load
-- (load.sh runs this file right after 02_aggregates.sql).

DROP DICTIONARY IF EXISTS airport_dict;

-- airport metadata (city, state) for query 7
CREATE DICTIONARY airport_dict
(
    id String,
    city String,
    state String
)
PRIMARY KEY id
SOURCE(CLICKHOUSE(
    user 'default'
    password ''
    QUERY 'select distinct origin_airport_id as id, origin_city_name as city, origin_state_name as state from flights'
))
LAYOUT(HASHED())
LIFETIME(0);

-- sanity check:
-- select dictGet('airport_dict', 'city', '10135');

DROP DICTIONARY IF EXISTS cancellation_reason_dict;

-- cancellation letter to human reason, explored for query 4
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
