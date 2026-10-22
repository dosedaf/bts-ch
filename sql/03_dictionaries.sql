DROP DICTIONARY IF EXISTS airport_dict;

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

DROP DICTIONARY IF EXISTS cancellation_reason_dict;

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
