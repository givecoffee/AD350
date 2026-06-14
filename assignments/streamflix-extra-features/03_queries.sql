-- 03_queries.sql
-- Queries JSONB data using arrow and containment operators.

-- Find movies with a named director
SELECT title, details->>'director' AS director
FROM movies
WHERE details->>'director' IS NOT NULL;

-- Find movies with Brad Pitt in cast
SELECT title
FROM movies
WHERE details->'cast' @> '["Brad Pitt"]';

-- Pull Lion King studio and voice cast
SELECT title, details->>'studio' AS studio, details->'voice_cast' AS voice_cast
FROM movies
WHERE title = 'The Lion King';

-- Find movies with James Earl Jones in voice cast
SELECT title, details->'voice_cast' AS voice_cast
FROM movies
WHERE details->'voice_cast' @> '["James Earl Jones"]';

-- Type check: verify column stores as JSONB
SELECT title, details, pg_typeof(details) AS data_type
FROM movies
WHERE title = 'Interstellar';
