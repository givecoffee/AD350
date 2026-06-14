-- Week 8: Seed data for StreamFlix joins lab
-- Issues: #43, #27

-- Reset tables
TRUNCATE TABLE ratings CASCADE;
TRUNCATE TABLE movies CASCADE;

-- Insert movies with explicit IDs
INSERT INTO movies (id, title, category, release_year) VALUES
(4, 'Star Wars: A New Hope', 'Sci-Fi', 1977),
(5, 'Interstellar', 'Sci-Fi', 2014),
(6, 'The Matrix', 'Sci-Fi', 1999),
(7, 'Jurassic Park', 'Adventure', 1993),
(8, 'Gladiator II', 'Action', 2024);

-- Create ratings table with user engagement schema
DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    movie_id INT,
    user_email TEXT,
    user_rating DECIMAL(3,1),
    review_text TEXT
);

-- Seed ratings including one orphan (NULL movie_id)
INSERT INTO ratings (movie_id, user_email, user_rating, review_text) VALUES
(4, 'alex@email.com', 9.0, 'An absolute classic!'),
(4, 'sam@email.com', 8.0, 'Great world building.'),
(5, 'alex@email.com', 9.5, 'Mind-bending masterpiece.'),
(6, 'taylor@email.com', 8.5, 'Changed cinema forever.'),
(NULL, 'ghost@email.com', 7.0, 'An anonymous review for a deleted movie.');

-- Verify
SELECT 'movies' AS table_name, COUNT(*) AS row_count FROM movies
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings;
