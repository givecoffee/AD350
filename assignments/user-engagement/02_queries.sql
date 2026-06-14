-- Week 8: JOIN queries for StreamFlix user engagement analytics
-- Issue: #27

-- Task 1: INNER JOIN — active reviews feed
-- Returns only reviews that belong to a valid movie in the catalog.
-- Excludes orphan ratings and movies with no reviews.
SELECT
    m.title,
    r.user_email,
    r.user_rating,
    r.review_text
FROM movies m
INNER JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title, r.user_rating DESC;
-- Expected: 4 rows

-- Task 2: LEFT JOIN — unreviewed movies audit
-- Returns all movies; filters for those with no matching rating.
-- Used by marketing to find catalog gaps.
SELECT
    m.title,
    m.category,
    m.release_year,
    r.user_rating
FROM movies m
LEFT JOIN ratings r ON m.id = r.movie_id
WHERE r.user_rating IS NULL
ORDER BY m.title;
-- Expected: 1 row (Gladiator II)

-- Task 3: FULL OUTER JOIN — system integrity audit
-- Returns everything from both tables.
-- Reveals both orphan ratings and unreviewed movies.
SELECT
    m.title AS movie_title,
    r.user_email,
    r.user_rating,
    r.review_text
FROM movies m
FULL OUTER JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title NULLS LAST, r.user_email;
-- Expected: 7 rows (5 movies + 1 orphan, Gladiator II and Jurassic Park unreviewed)
