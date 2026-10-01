# 5. All flights for a specific tail number (aircraft) on a specific date.
# projection aja
# benchmark storage juga
KILL MUTATION WHERE mutation_id = '0000000001';

ALTER TABLE flights DROP PROJECTION prj_aircraft_date;

ALTER TABLE flights 
ADD PROJECTION prj_aircraft_date (
  SELECT *
  ORDER BY flight_date
);

ALTER TABLE flights MATERIALIZE PROJECTION prj_aircraft_date;

EXPLAIN PLAN indexes = 1
SELECT 
  *
FROM flights
WHERE tail_number = 'N933AM' AND flight_date = '2023-09-27'
