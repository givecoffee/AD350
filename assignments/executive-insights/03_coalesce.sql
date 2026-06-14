-- Week 9 Task 2: Homepage display cleanup
-- Replaces NULL user_email with 'Anonymous Streamer' using COALESCE
SELECT
    m.title,
    COALESCE(r.user_email, 'Anonymous Streamer') AS reviewer,
    r.user_rating
FROM movies m
JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title;
