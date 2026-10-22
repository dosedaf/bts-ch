# 5. All flights for a specific tail number (aircraft) on a specific date.
SELECT 
  *
FROM flights
WHERE tail_number = 'N933AM' AND flight_date = '2023-09-27';

# Elapsed: 0.026s Read: 16,384 rows (2.33 MB)