# 5. All flights for a specific tail number (aircraft) on a specific date.
# same SELECT as the naive side: served by the prj_aircraft_date projection on flights
# see sql/02_aggregates.sql

SELECT
  *
FROM flights
WHERE tail_number = 'N933AM' AND flight_date = '2023-09-27';
