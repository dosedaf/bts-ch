#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

WARMUP=${WARMUP:-3}
ITERS=${ITERS:-20}
BENCH="docker compose exec -T clickhouse clickhouse-benchmark"

run() {
  local q out
  q="$(cat "$1")"
  $BENCH -i "$WARMUP" -q "$q" >/dev/null 2>&1 || true
  out=$($BENCH -i "$ITERS" -q "$q" 2>&1)
  printf '  p50 %s  p90 %s  qps %s\n' \
    "$(awk '/^\s*50%/ {print $2}' <<<"$out")" \
    "$(awk '/^\s*90%/ {print $2}' <<<"$out")" \
    "$(grep -oE 'QPS: [0-9.]+' <<<"$out" | awk '{print $2}')"
}

echo "bts-ch local benchmark: $WARMUP warmup, $ITERS measured runs"
echo

for n in 1 2 3 4 5 6 7 8 9 10; do
  echo "query $n"
  printf '  naive\n'
  run "queries/naive/$n.sql"
  for tuned in queries/tuned/${n}.sql queries/tuned/${n}_*.sql; do
    [ -e "$tuned" ] || continue
    printf '  tuned (%s)\n' "$(basename "$tuned")"
    run "$tuned"
  done
done
