-- 02_index.sql
-- Creates a B-Tree index on the score column and verifies the improvement.
-- Run after 01_seed_and_baseline.sql.


-- STEP 1: create B-Tree index on score
CREATE INDEX idx_ratings_score ON ratings(score);


-- STEP 2: re-run the same query with index in place
-- Compare execution time to the baseline.
EXPLAIN ANALYZE
SELECT * FROM ratings
WHERE score = 10;
