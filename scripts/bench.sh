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
BENCH="docker compose exec -T clickhouse clickhouse-benchmark"

# print the headline stats of one benchmark run, compact
# clickhouse-benchmark has no warmup flag, so warmup is its own run
run() {
  $BENCH -i "$WARMUP" -q "$(cat "$1")" >/dev/null 2>&1 || true
  $BENCH -i "$ITERS" -q "$(cat "$1")" 2>/dev/null \
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
