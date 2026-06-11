-- Week 9 Task 1: Content strategy report
-- Groups by category, filters with HAVING for review count > 1 and avg score > 7.0
SELECT
    m.category,
    COUNT(*) AS review_count,
    ROUND(AVG(r.user_rating), 2) AS avg_score
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.category
HAVING COUNT(*) > 1 AND AVG(r.user_rating) > 7.0
ORDER BY avg_score DESC;
