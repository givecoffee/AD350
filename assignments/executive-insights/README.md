This week will be using aggregation (GROUP BY, HAVING) and using conditional logic (CASE, COALESCE). We are making useful business reports in Supabase, and this is where some of the real fun begins. 

First, we are going to practice good data hygiene and prepare the datasets. We will update the database itself with specific mock data provided to use and it will simulate messy user registrations and real problems that causes mismatches. 


## Content Strategy Report

First, we will paste the script below:

```
TRUNCATE TABLE ratings CASCADE;
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
(7, 'taylor@email.com', 5.5, 'Just okay');
```

Successful, no rows were returned (of course I had to adjust for 'category' instead of 'genre')

Now, for the content strategy report: 

```
SELECT
    m.category,
    COUNT(*) AS review_count,
    ROUND(AVG(r.user_rating), 2) AS avg_score
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.category
HAVING COUNT(*) > 1 AND AVG(r.user_rating) > 7.0
ORDER BY avg_score DESC;
```

After running this query, we received the following category, its review count, and the average review score:

![](images/Pasted%20image%2020260611144556.png)

Comedy fell below the 7.0 threshold because it received a 5.5 rating. Because of this, it was excluded. I went to check and see if this was an error, and it looked like thee TRUNCRATE and re-insert of the seed data ran against old data or didn't run at all. The IDs were set from 11-18 so previous rows were not cleared. To fix this, we are going to use RESTART IDENTITY to reset the ID sequence back to 1 so it can match up with the seed data correctly: 

```
TRUNCATE TABLE ratings RESTART IDENTITY CASCADE;

INSERT INTO ratings (movie_id, user_email, user_rating, review_text) VALUES
(1, 'alex@email.com', 9.0, 'Masterpiece'),
(1, 'sam@email.com', 8.2, 'Classic'),
(2, 'alex@email.com', 9.5, 'Incredible visuals'),
(3, 'taylor@email.com', 8.5, 'Iconic cinema'),
(4, NULL, 8.2, 'Great dinosaur effects!'),
(5, 'sam@email.com', 8.5, 'Nostalgic'),
(6, NULL, 7.7, 'Very funny'),
(7, 'taylor@email.com', 7.5, 'Just okay');
```

This fixed the IDs back to 1, instead of the reviews starting from 11. 

![](images/Pasted%20image%2020260611145004.png)

Now, I am going to re-run the query:

```
SELECT
    m.category,
    COUNT(*) AS review_count,
    ROUND(AVG(r.user_rating), 2) AS avg_score
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.category
HAVING COUNT(*) > 1 AND AVG(r.user_rating) > 7.0
ORDER BY avg_score DESC;
```

Which returns me with the expected output of Sci-Fi and Comedy according to the project instructions. 

![](images/Pasted%20image%2020260611145118.png)

### Homepage UI Cleanup

Front-end team gave us feedback that the review feed appears broken when a user doesn't provide an email address during the quick sign-up. We need to write a query that displays the movie title and the reviewer's identifier. 

COALESCE to check user_email column, and is it empty or NULL? Display an anonymous streamer name if so. 

We are looking for 8 rows in the output: rows in Jurassic Park and Office Space will have anonymous streamer in place of an empty space. 

```
SELECT
    m.title,
    COALESCE(r.user_email, 'Anonymous Streamer') AS reviewer,
    r.user_rating
FROM movies m
JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title;
```

![](images/Pasted%20image%2020260611145401.png)

### Marketing Tier Segmentation 

Marketing team wants us to tag reviews on the dashboard with labels that help users sort through good and bad press/reviews on movies. We will write a query to use a CASE expression that evaluates the user_rating to meet the conditions:

- rating 8.5 or higher will be 'Highly Acclaimed'
- rating 7.0-8.4 will be 'Positive'
- rating <7.0 will be "Mixed/Negative"

Query for CASE sentiment labels:

```
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
```

Returns 8 rows:

![](images/Pasted%20image%2020260611145647.png)
