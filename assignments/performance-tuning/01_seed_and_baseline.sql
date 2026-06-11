-- 01_seed_and_baseline.sql
-- Generates 1,000,000 ratings and records baseline query performance.
-- Run each section in order. Record execution times for the report.


-- STEP 1: ensure table exists with correct structure
CREATE TABLE IF NOT EXISTS ratings (
    id         SERIAL      PRIMARY KEY,
    movie_id   INT,
    user_id    INT,
    score      INT         NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- STEP 2: clear existing data
TRUNCATE TABLE ratings;


-- STEP 3: seed 1,000,000 rows with random data
INSERT INTO ratings (movie_id, user_id, score, created_at)
SELECT
    floor(random() * 100  + 1)::int                        AS movie_id,
    floor(random() * 5000 + 1)::int                        AS user_id,
    floor(random() * 10   + 1)::int                        AS score,
    now() - (random() * interval '365 days')               AS created_at
FROM generate_series(1, 1000000);


-- STEP 4: verify row count (should return 1000000)
SELECT count(*) FROM ratings;


-- STEP 5: verify score distribution (should be roughly even across 1-10)
SELECT score, count(*) AS total
FROM ratings
GROUP BY score
ORDER BY score;


-- STEP 6: baseline query — NO INDEX
-- Record the Execution Time from the output. This is your before number.
EXPLAIN ANALYZE
SELECT * FROM ratings
WHERE score = 10;
