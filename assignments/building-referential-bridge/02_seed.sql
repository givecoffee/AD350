INSERT INTO ratings (movie_id, user_id, rating_value)
VALUES (1, 101, 9.0);

SELECT m.title, r.user_id, r.rating_value
FROM movies m
JOIN ratings r ON m.id = r.movie_id;
