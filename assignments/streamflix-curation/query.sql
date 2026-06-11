-- Week 7: StreamFlix "Curation & Clean-up" Challenge
-- AD350 Database Technology

-- Step 0: Seed the catalog
TRUNCATE TABLE movies CASCADE;

INSERT INTO movies (title, category, release_year, viewer_rating) VALUES
('Star Wars: A New Hope', 'Sci-Fi', 1977, 8.6),
('Interstellar', 'Sci-Fi', 2014, 8.6),
('The Matrix', 'Sci-Fi', 1999, 8.7),
('Jurassic Park', 'Adventure', 1993, 8.2),
('Pulp Fiction', 'Crime', 1994, 8.9),
('A Star Is Born', 'Drama', 2018, 7.6),
('The Lion King', 'Animated', 1994, 8.5),
('Office Space', 'Comedy', 1999, 7.7),
('Clueless', 'Comedy', 1995, 6.9),
('Avatar: The Way of Water', 'Sci-Fi', 2022, 7.6),
('Gladiator II', 'Action', 2024, NULL),
('Future Indie Film', 'Drama', 2026, NULL);

-- Task 1: 90s Classics (BETWEEN + AND)
SELECT title, release_year, viewer_rating
FROM movies
WHERE release_year BETWEEN 1990 AND 1999
  AND viewer_rating > 7.5;

-- Task 2: Franchise Keyword Search (ILIKE)
SELECT title, category
FROM movies
WHERE title ILIKE '%star%';

-- Task 3: Data Quality Audit (IS NULL)
SELECT title, category
FROM movies
WHERE viewer_rating IS NULL;

-- Demo: why WHERE viewer_rating = NULL always returns 0 rows
SELECT title, category
FROM movies
WHERE viewer_rating = NULL;
