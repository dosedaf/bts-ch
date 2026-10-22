# 2. Top 20 routes (origin–destination pairs) by total flight volume and by average delay.
# avg delay tuh ga fair men. kyk 1 pesawat bisa overshadow pesawat yg volumenya gede bgt. eh ngga deh, krn di sort bvia volume dulu.
# TODO BAWAAN : # buat map untuk airport id ke airport name.

SELECT
    origin_airport_id,
    dest_airport_id,
    count() as total_flights,
    countIf(cancelled = false) as total_confirmed_flights,
    avgIf(arr_delay, cancelled = false) as avg_delay
FROM flights
GROUP BY origin_airport_id, dest_airport_id
ORDER BY (total_confirmed_flights, avg_delay) DESC
LIMIT 20;