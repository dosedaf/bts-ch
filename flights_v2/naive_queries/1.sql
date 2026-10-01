# 1. Average departure and arrival delay by carrier, by month, over the full date range.
# TODO BAWAAN : map buat reporting airline

SELECT 
    dot_id_reporting_airline,
    toStartOfMonth(flight_date) as month,
    # gabisa average karna ada cancelled
    # sumIf(dep_delay, cancelled = false) / countIf(cancelled = false) as avg_dep_delay,
    # sumIf(arr_delay, cancelled = false) / countIf(cancelled = false) as avg_arr_delay # diverted gimana?
    # we learn everyday bro. baru atau ada avgIF
    avgIf(dep_delay, cancelled = false) as avg_dep_delay,
    avgIf(arr_delay, cancelled = false) as avg_arr_delay
FROM flights
GROUP BY dot_id_reporting_airline, month
ORDER BY avg_arr_delay DESC

# Elapsed: 0.675s Read: 51,642,689 rows (727.33 MB) CACHED Elapsed: 0.688s Read: 51,642,689 rows (727.33 MB)
# Elapsed: 5.154s Read: 51,642,689 rows (727.33 MB) DEFAULT # Elapsed: 2.541s Read: 51,642,689 rows (727.33 MB)
# Elapsed: 8.496s Read: 51,642,689 rows (727.33 MB) COLD filesystem n uncompressed.