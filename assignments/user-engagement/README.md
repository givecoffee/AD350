## The StreamFlix "User Engagement" Analytics Challenge

We will be using JOINS (Inner, Left, and Full) to connect our movie catalog with user review data.

Given the script, we create a new table with explicit IDs:

```
-- 1. Reset the movies table with explicit IDs for reliable joining
TRUNCATE TABLE movies CASCADE;

INSERT INTO movies (id, title, genre, release_year) VALUES
(1, 'Star Wars: A New Hope', 'Sci-Fi', 1977),
(2, 'Interstellar', 'Sci-Fi', 2014),
(3, 'The Matrix', 'Sci-Fi', 1999),
(4, 'Jurassic Park', 'Adventure', 1993),
(5, 'Gladiator II', 'Action', 2024); -- This movie has no user ratings yet!

-- 2. Create the brand new user ratings table
CREATE TABLE IF NOT EXISTS ratings (
    id SERIAL PRIMARY KEY,
    movie_id INT,
    user_email TEXT,
    user_rating DECIMAL(3,1),
    review_text TEXT
);

-- 3. Seed the ratings table with sample user activity
TRUNCATE TABLE ratings;
INSERT INTO ratings (movie_id, user_email, user_rating, review_text) VALUES
(1, 'alex@email.com', 9.0, 'An absolute classic!'),
(1, 'sam@email.com', 8.0, 'Great world building.'),
(2, 'alex@email.com', 9.5, 'Mind-bending masterpiece.'),
(3, 'taylor@email.com', 8.5, 'Changed cinema forever.'),
(NULL, 'ghost@email.com', 7.0, 'An anonymous review for a deleted movie.'); -- Orphan rating (No movie matches)
```

After pasting the query, I ran into an issue where my movies table has different column names so I adjusted it: after checking what the 'movies' table without having to tab back over to the Table view. 

```
SELECT column_name FROM information_schema.columns WHERE table_name = 'movies';
```

I kept the rebranding from earlier assignments and let's just assume we kept that change. Marketing teams can affect development as well, so I just left it in. I have an existing Week 5 Ratings table that needs to be dropped so that we can build with the new schema.
Adjusted truncate/insert script with re-branded column names:

```
DROP TABLE ratings;

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    movie_id INT,
    user_email TEXT,
    user_rating DECIMAL(3,1),
    review_text TEXT
);

INSERT INTO ratings (movie_id, user_email, user_rating, review_text) VALUES
(1, 'alex@email.com', 9.0, 'An absolute classic!'),
(1, 'sam@email.com', 8.0, 'Great world building.'),
(2, 'alex@email.com', 9.5, 'Mind-bending masterpiece.'),
(3, 'taylor@email.com', 8.5, 'Changed cinema forever.'),
(NULL, 'ghost@email.com', 7.0, 'An anonymous review for a deleted movie.');
```

![](images/Pasted%20image%2020260610194242.png)

We have five ratings now, an orphan rating on row 5 tied to a NULL movie_id. Let's run the INNER JOIN given to us:

```
SELECT 
    m.title,
    r.user_email,
    r.user_rating
FROM movies m
INNER JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title, r.user_rating DESC;
```

![](images/Pasted%20image%2020260610202956.png)

However, it did not join because the TRUNCATE from earlier did not reset so the ratings do not match the movie IDs. Reset and match them to the right movies:

```
TRUNCATE TABLE movies CASCADE;
ALTER SEQUENCE movies_id_seq RESTART WITH 1;

INSERT INTO movies (id, title, category, release_year) VALUES
(4, 'Star Wars: A New Hope', 'Sci-Fi', 1977),
(5, 'Interstellar', 'Sci-Fi', 2014),
(6, 'The Matrix', 'Sci-Fi', 1999),
(7, 'Jurassic Park', 'Adventure', 1993),
(8, 'Gladiator II', 'Action', 2024);

TRUNCATE TABLE ratings;

INSERT INTO ratings (movie_id, user_email, user_rating, review_text) VALUES
(4, 'alex@email.com', 9.0, 'An absolute classic!'),
(4, 'sam@email.com', 8.0, 'Great world building.'),
(5, 'alex@email.com', 9.5, 'Mind-bending masterpiece.'),
(6, 'taylor@email.com', 8.5, 'Changed cinema forever.'),
(NULL, 'ghost@email.com', 7.0, 'An anonymous review for a deleted movie.');
```

Returns a successful message and there are only 4 rows as expected since it is excluding Orphan and Gladiator II. 

![](images/Pasted%20image%2020260610203716.png)

Running the LEFT JOIN:

```
SELECT 
    m.title,
    m.category,
    m.release_year,
    r.user_rating
FROM movies m
LEFT JOIN ratings r ON m.id = r.movie_id
WHERE r.user_rating IS NULL
ORDER BY m.title;
```

which has 2 rows:

![](images/Pasted%20image%2020260610211320.png)


And for the FULL OUTER JOIN:

```
SELECT 
    m.title AS movie_title,
    r.user_email,
    r.user_rating,
    r.review_text
FROM movies m
FULL OUTER JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title NULLS LAST, r.user_email;
```

![](images/Pasted%20image%2020260610211431.png)

All 7 rows accounted for with two unreviewed titles, ghost@email.com is an orphan rating. 

### Reflection 
INNER JOIN returns only rows where a match exists in both tables. If either side has no match, that row is dropped entirely. LEFT JOIN returns every row from the left table regardless of whether a match exists on the right. Where no match is found, the right table columns come back as NULL. 
