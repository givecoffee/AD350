-- Inserts test movies and ratings, then verifies the relationship.

INSERT INTO movies (title, release_year, category, viewer_rating) VALUES
    ('Inception',       2010, 'Sci-Fi', 8.8),
    ('The Dark Knight', 2008, 'Action', 9.0),
    ('Interstellar',    2014, 'Sci-Fi', 8.7);

INSERT INTO ratings (movie_id, user_id, rating_value) VALUES
    (1, 101, 9.0),
    (1, 102, 8.5),
    (2, 101, 9.5),
    (3, 103, 8.8);

-- Verify: confirm the foreign key relationship is intact
SELECT
    m.title,
    r.user_id,
    r.rating_value
FROM movies m
JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title;
