# Week 5: Baseline Performance

Before adding any indexes, we need a benchmark. This documents the query plan and execution time against 1,000,000 unindexed ratings rows.

---

## Dataset

```sql
SELECT count(*) FROM ratings;
-- 1000000
```

Randomly distributed across:
- `movie_id` 1 to 100
- `user_id` 1 to 5000
- `score` 1 to 10
- `created_at` spread across the past 365 days

---

## Baseline Query

```sql
EXPLAIN ANALYZE
SELECT * FROM ratings
WHERE score = 10;
```

---

## Query Plan Output

```
Seq Scan on ratings  (cost=0.00..18334.00 rows=100000 width=28)
                     (actual time=0.XXX..XXX.XXX rows=XXXXX loops=1)
  Filter: (score = 10)
  Rows Removed by Filter: XXXXXX
Planning Time: X.XXX ms
Execution Time: XXX.XXX ms
```

> Replace the `X` values with your actual output after running Step 6 in `01_seed_and_baseline.sql`.

---

## Metrics to Record

| Metric | Value |
|---|---|
| Scan type | Seq Scan |
| Rows examined | 1,000,000 |
| Rows removed by filter | ~900,000 |
| Rows returned | ~100,000 |
| Execution time | _____ ms |

---

## Why Sequential Scan

There is no index on the `score` column yet. PostgreSQL has no shortcut to find rows where `score = 10`, so it reads every single row in the table and checks each one against the filter. With 1,000,000 rows, about 900,000 get discarded.

This is the number to beat. After adding a B-Tree index in the next step, the same query should switch to an Index Scan and execution time should drop significantly.
