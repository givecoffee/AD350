-- Week 9 Task 3: Marketing sentiment tier segmentation
-- Classifies each review with a label based on user_rating
SELECT
    m.title,
    r.user_rating,
    CASE
        WHEN r.user_rating >= 8.5 THEN 'Highly Acclaimed'
        WHEN r.user_rating >= 7.0 THEN 'Positive'
        ELSE 'Mixed/Negative'
    END AS sentiment_label
FROM movies m
JOIN ratings r ON m.id = r.movie_id
ORDER BY r.user_rating DESC;
