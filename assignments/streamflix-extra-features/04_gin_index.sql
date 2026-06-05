-- 04_gin_index.sql
-- Creates a GIN index on the JSONB details column and verifies it.

CREATE INDEX idx_movies_details ON movies USING GIN (details);

-- Verify index creation
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'movies';

-- Check query plan
EXPLAIN ANALYZE
SELECT title
FROM movies
WHERE details->'voice_cast' @> '["James Earl Jones"]';
