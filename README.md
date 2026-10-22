# bts-ch

<div align="center">
  <br>
  <img src="results/lineage/bts_flights_lineage_minimal.png" alt="lineage: flights to tuned structures to queries" width="100%">
  <p>naive vs tuned US flight delays in ClickHouse</p>
  <br>
</div>

## dataset

<p align="center">
  BTS On-Time Performance (Air OnTime) · 2017-2024 · 51,642,689 rows · monthly CSVs · single node, ClickHouse 26.4.1
</p>

## benchmark

| | |
|---|---|
| ![naive vs tuned p50 latency, log scale](results/charts/latency.png) | ![speedup p50, log scale](results/charts/speedup.png) |

## questions

<div align="center">
  <img src="queries/bts_flights_benchmark_questions.png" alt="the ten questions" width="100%">
</div>

## run it yourself

```bash
docker compose up -d
scripts/load.sh      # BTS 2017-2024 from transtats, builds everything in sql/
scripts/bench.sh     # 3 warmup, 20 runs per query
```
