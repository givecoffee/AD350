The timing of this assignment came at a time where I was actually rewatching 90s classics like The Matrix and Pulp Fiction so these movies were fresh on my mind. Before we filter the data for demonstration purposes, though, we will need to import the same movie catalog as everyone else working on this project. We will TRUNCATE so that we can wipe the slate clean (but obviously keeping the slate itself) and we will insert the standardized dataset to test on:

```
TRUNCATE TABLE movies CASCADE;
```

```
INSERT INTO movies (title, genre, release_year, rating) VALUES  
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
```

After confirming that the movies are successfully updated in the database, we can move on to making changes and working with it. 

![](images/Screenshot%202026-06-10%20174945.png)

After inserting:

![](images/Pasted%20image%2020260610175233.png)

Received an error, because back in Week 3 we renamed the 'genre' column to 'category'. To be safe, let's run a check on what columns we currently have in our movies table:

![](images/Pasted%20image%2020260610175332.png)
The script needs to be adjusted to change genre to category and rating to viewer_rating: 

```
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
```

This was successful and 12 records were added:

![](images/Pasted%20image%2020260610175534.png)

Now, we are going to perform task 1, which will be to add the 90s Classics row:

```
SELECT title, release_year, viewer_rating
FROM movies
WHERE release_year BETWEEN 1990 AND 1999
  AND viewer_rating > 7.5;
```

Which returns:

![](images/Pasted%20image%2020260610175646.png)

This will basically catch anything that is exactly between 1990 and 1999 (and includes both ends of that range) plus the second conditional of the viewer rating being greater than 7.5. This means if it is 7.5 it will not be inclusive of that rating and need to be higher. Any row where either of the conditions cannot be met, they will be excluded.

For Task 2, we will be doing a keyword search for franchises:

```
SELECT title, category
FROM movies
WHERE title ILIKE '%star%';
```

We used ILIKE which isn't case-sensitive, whereas using LIKE would be and would miss everything where the casing wasn't matching exactly. ILIKE is PostgreSQL's case-insensitive pattern match and on both sides of the search term is a %. This basically means "anything before, anything after" which will match any title that includes star anywhere in the title. 

We got Star Wars: A New Hope and A Star is Born:

![](images/Pasted%20image%2020260610180436.png)

Everything looks good, let's look do a data quality audit:

```
SELECT title, category
FROM movies
WHERE viewer_rating IS NULL;
```

We will be checking for missing values, and using WHERE viewer_rating = NULL would not work because it will compare to an unknown value. Anything being compared to NULL or an unknown value will produce UNKNOWN. WHERE clauses only keep the rows that evaluate to TRUE, so every row will get excluded. IS NULL checks for the absence of a value and bypasses the three-valued logic issue entirely. 

![](images/Pasted%20image%2020260610181151.png)

Despite naming conventions for two column names, everything is the same. Here is that SQL script with those changes:

```
-- Week 7: The StreamFlix "Curation & Clean-up" Challenge
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
```
