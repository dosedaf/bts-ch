DROP TABLE IF EXISTS flights;

CREATE TABLE flights
(
    flight_date Date,
    year UInt16,
    quarter UInt8,
    day_of_week UInt8,
    dot_id_reporting_airline UInt32,
    origin LowCardinality(String),
    origin_airport_id UInt32,
    origin_city_name LowCardinality(String),
    origin_state_name LowCardinality(String),
    dest_airport_id UInt32,
    origin_wac UInt16,
    dest_wac UInt16,
    dest_city_name LowCardinality(String),
    dest_state_name LowCardinality(String),
    tail_number String,
    dep_delay Float32,
    arr_delay Float32,
    cancelled Bool,
    diverted Bool,
    div_reached_dest Bool,
    dep_del15 Bool,
    arr_del15 Bool,
    cancellation_code LowCardinality(String) DEFAULT ''
)
ENGINE = MergeTree
ORDER BY (tail_number, flight_date);
