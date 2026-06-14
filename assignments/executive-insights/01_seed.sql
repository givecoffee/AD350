-- Week 9: Seed movies and ratings for aggregation lab
TRUNCATE TABLE ratings RESTART IDENTITY CASCADE;
TRUNCATE TABLE movies CASCADE;

INSERT INTO movies (id, title, category, release_year) VALUES
(1, 'Star Wars: A New Hope', 'Sci-Fi', 1977),
(2, 'Interstellar', 'Sci-Fi', 2014),
(3, 'The Matrix', 'Sci-Fi', 1999),
(4, 'Jurassic Park', 'Adventure', 1993),
(5, 'The Lion King', 'Animated', 1994),
(6, 'Office Space', 'Comedy', 1999),
(7, 'Clueless', 'Comedy', 1995),
(8, 'Gladiator II', 'Action', 2024);

INSERT INTO ratings (movie_id, user_email, user_rating, review_text) VALUES
(1, 'alex@email.com', 9.0, 'Masterpiece'),
(1, 'sam@email.com', 8.2, 'Classic'),
(2, 'alex@email.com', 9.5, 'Incredible visuals'),
(3, 'taylor@email.com', 8.5, 'Iconic cinema'),
(4, NULL, 8.2, 'Great dinosaur effects!'),
(5, 'sam@email.com', 8.5, 'Nostalgic'),
(6, NULL, 7.7, 'Very funny'),
(7, 'taylor@email.com', 7.5, 'Just okay');
