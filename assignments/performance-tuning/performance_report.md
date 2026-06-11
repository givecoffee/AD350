# Week 5: Performance Tuning Report

Dataset: 1,000,000 ratings. Query: `WHERE score = 10`. Optimization: B-Tree index on `score`.

---

## Before: No Index

```
SEQ SCAN (cost 18870.0, estimated 101,033 rows)
4.32s / 1,000,000 rows examined / -899,967 removed / 100,033 rows returned
Total time: 4321.66ms
```

No index on `score` meant PostgreSQL had no shortcut. It read all 1,000,000 rows and checked each one against the filter. 899,967 were thrown away. That is the worst case — full sequential scan on a million row table.

---

## The Fix

```sql
CREATE INDEX idx_ratings_score ON ratings(score);
```

B-Tree index on `score`. Took a few seconds to build. No changes to the query.

---

## After: B-Tree Index

```
BITMAP INDEX SCAN on idx_ratings_score (cost 852.8, estimated 101,033 rows)
1.0µs / 100,033 rows
BITMAP HEAP SCAN (cost 8510.9, estimated 101,033 rows)
29.37ms / 100,033 rows
Total time: 38.87ms
```

PostgreSQL used the index to locate matching rows immediately instead of scanning the full table. The scan type changed from Seq Scan to Bitmap Index Scan — a two-step process where the index finds the row locations first, then the heap scan fetches only those rows.

---

## Results

| Metric | Before | After |
|---|---|---|
| Scan type | Seq Scan | Bitmap Index Scan |
| Rows examined | 1,000,000 | 100,033 |
| Rows removed by filter | 899,967 | 0 |
| Execution time | 4321.66ms | 38.87ms |
| Improvement | baseline | 99.1% faster / 111x speedup |

---

## Why Bitmap Index Scan and not Index Scan

PostgreSQL chose Bitmap Index Scan instead of a plain Index Scan because about 100,000 rows match the filter — roughly 10% of the table. For large result sets, a bitmap scan is more efficient. It builds a bitmap of matching row locations from the index first, then fetches all of them from the heap in one pass. A plain Index Scan fetches rows one at a time and gets slower as the result set grows. Both use the index. PostgreSQL picked the better strategy for this data distribution.

---

## Why Performance Improved

Without the index, PostgreSQL had no way to know which rows had `score = 10`. It read everything. With a B-Tree index, the score values are stored in a sorted tree structure. PostgreSQL traverses the tree to find the `score = 10` branch and reads only those rows. Time complexity drops from O(n) to O(log n).
