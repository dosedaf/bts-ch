#!/usr/bin/env bash
# Download BTS On-Time Performance monthly zips and load them into the
# local ClickHouse container, then build the tuned structures.
# Default range: 2017-2024, the benchmarked subset.
#
# Usage: scripts/load.sh [first_year] [last_year]
set -euo pipefail

cd "$(dirname "$0")/.."

FIRST_YEAR=${1:-2017}
LAST_YEAR=${2:-2024}
DATA_DIR=data

CH="docker compose exec -T clickhouse clickhouse-client"

echo "waiting for clickhouse"
until $CH --query 'SELECT 1' >/dev/null 2>&1; do sleep 1; done

# base table
$CH --multiquery < sql/01_flights.sql
echo "flights table ready"

mkdir -p "$DATA_DIR"

# BTS renames: strip header quotes, lowercase header names to match the
# table, strip the .00 float suffix so Bool columns parse (0.00 -> 0, 1.00 -> 1).
HEADER_SED=(
  -e '1s/"//g'
  -e '1s/^Year,/year,/'
  -e '1s/,FlightDate,/,flight_date,/'
  -e '1s/,Quarter,/,quarter,/'
  -e '1s/,DayOfWeek,/,day_of_week,/'
  -e '1s/,DOT_ID_Reporting_Airline,/,dot_id_reporting_airline,/'
  -e '1s/,Origin,/,origin,/'
  -e '1s/,OriginAirportID,/,origin_airport_id,/'
  -e '1s/,OriginCityName,/,origin_city_name,/'
  -e '1s/,OriginStateName,/,origin_state_name,/'
  -e '1s/,OriginWac,/,origin_wac,/'
  -e '1s/,DestAirportID,/,dest_airport_id,/'
  -e '1s/,DestCityName,/,dest_city_name,/'
  -e '1s/,DestStateName,/,dest_state_name,/'
  -e '1s/,DestWac,/,dest_wac,/'
  -e '1s/,Tail_Number,/,tail_number,/'
  -e '1s/,DepDelay,/,dep_delay,/'
  -e '1s/,ArrDelay,/,arr_delay,/'
  -e '1s/,Cancelled,/,cancelled,/'
  -e '1s/,Diverted,/,diverted,/'
  -e '1s/,DivReachedDest,/,div_reached_dest,/'
  -e '1s/,DepDel15,/,dep_del15,/'
  -e '1s/,ArrDel15,/,arr_del15,/'
  -e '1s/,CancellationCode,/,cancellation_code,/'
)

for year in $(seq "$FIRST_YEAR" "$LAST_YEAR"); do
  for month in $(seq 1 12); do
    name="On_Time_Reporting_Carrier_On_Time_Performance_${year}_${month}"
    # transtats names the current series 1987_present_...
    for pattern in "1987_present_${name}" "501_${name}"; do
      url="https://transtats.bts.gov/PREZIP/${pattern}.zip"
      if wget --no-check-certificate --continue -q -O "$DATA_DIR/$pattern.zip" "$url" 2>/dev/null; then
        unzip -cq "$DATA_DIR/$pattern.zip" '*.csv' \
          | sed "${HEADER_SED[@]}" -e 's/\.00//g' \
          | $CH --input_format_csv_empty_as_default 1 --input_format_skip_unknown_fields 1 \
                --query 'INSERT INTO flights FORMAT CSVWithNames'
        echo "loaded $year-$month"
        break
      fi
      rm -f "$DATA_DIR/$pattern.zip"
    done
  done
done

echo
$CH --query "SELECT count() AS rows, min(flight_date), max(flight_date) FROM flights FORMAT PrettyCompact"

# tuned structures and dictionaries, after the data exists
$CH --multiquery < sql/02_aggregates.sql
$CH --multiquery < sql/03_dictionaries.sql
echo "aggregates, projection and dictionaries ready"
