-- Base table: BTS On-Time Performance (Air OnTime), 2017-2024, 51,642,689 rows.
-- Reconstructed from query usage and measured read patterns; the original
-- cloud schema was not committed. Types follow rules/data-type-rules.txt.
-- No partitioning: the full date range is scanned on purpose (see query 1).

DROP TABLE IF EXISTS flights;

CREATE TABLE flights
(
    -- calendar
    flight_date Date,
    year UInt16,
    quarter UInt8,
    day_of_week UInt8,

    -- carrier
    dot_id_reporting_airline UInt32,

    -- airports (codes and ids)
    origin LowCardinality(String),
    origin_airport_id UInt32,
    origin_city_name LowCardinality(String),
    origin_state_name LowCardinality(String),
    dest_airport_id UInt32,
    origin_wac UInt16 COMMENT 'WAC could exceed UInt8, carried from the overflow check',
    dest_wac UInt16,
    dest_city_name LowCardinality(String),
    dest_state_name LowCardinality(String),

    -- aircraft
    tail_number String COMMENT 'borderline cardinality, stays plain String',

    -- measures
    dep_delay Float32,
    arr_delay Float32,

    -- flags
    cancelled Bool,
    diverted Bool,
    div_reached_dest Bool,
    dep_del15 Bool,
    arr_del15 Bool,

    -- cancellation
    cancellation_code LowCardinality(String) DEFAULT ''
)
ENGINE = MergeTree
ORDER BY (tail_number, flight_date)
COMMENT 'query 5 reads 2 granules for one tail+date: tail_number must lead the key';
