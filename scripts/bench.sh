#!/usr/bin/env bash
# Rerun the naive vs tuned benchmark locally with clickhouse-benchmark.
# Method matches results/flights_benchmark.txt: 3 warmup runs, 20 measured
# iterations per query, naive and tuned executed under identical conditions.
#
# Usage: scripts/bench.sh
set -euo pipefail

cd "$(dirname "$0")/.."

WARMUP=${WARMUP:-3}
ITERS=${ITERS:-20}
BENCH="docker compose exec -T clickhouse clickhouse-benchmark -w $WARMUP -i $ITERS"

# print the headline stats of one benchmark run, compact
run() {
  $BENCH -q "$(cat "$1")" 2>/dev/null \
    | grep -E '^(QPS|median|90th percentile):' \
    | sed 's/,.*RPS.*//' \
    | tr '\n' ' '
  echo
}

echo "bts-ch local benchmark: $WARMUP warmup, $ITERS measured runs"
echo

for n in 1 2 3 4 5 6 7 8 9 10; do
  echo "query $n"
  printf '  naive  '
  run "queries/naive/$n.sql"
  for tuned in queries/tuned/$n*.sql; do
    printf '  tuned  '
    run "$tuned"
  done
done
