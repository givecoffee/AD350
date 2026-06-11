# Week 9: Executive Insights and Catalog Cleanup

This week covers aggregation with `GROUP BY` and `HAVING`, plus conditional logic with `CASE` and `COALESCE`. The goal is building useful business reports directly in Supabase.

---

## Data Setup

Before running the queries, the tables were truncated and reseeded with consistent mock data simulating messy user registrations.

```sql
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
(7, 'taylor@email.com', 7.5, 'Just okay');
```

> **Note:** The first truncate run left IDs starting at 11 instead of 1 — the sequence wasn't reset. Fixed by using `TRUNCATE TABLE ratings RESTART IDENTITY CASCADE` before reinserting.

---

## Content Strategy Report

Query: categories with more than one review and an average score above 7.0.

```sql
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

![Content strategy report results](images/content-strategy-report.png)

`HAVING` filters groups after aggregation. Comedy initially dropped below the threshold due to a 5.5 seed value from stale data — resolved after resetting the sequence and reinserting.

---

## Homepage UI Cleanup

The front-end team flagged that the review feed breaks when a user skips email during quick sign-up. `COALESCE` replaces `NULL` emails with a fallback display name.

```sql
SELECT
    m.title,
    COALESCE(r.user_email, 'Anonymous Streamer') AS reviewer,
    r.user_rating
FROM movies m
JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title;
```

![COALESCE query results — 8 rows, Jurassic Park and Office Space show Anonymous Streamer](images/coalesce-anonymous-streamer.png)

Jurassic Park and Office Space both had `NULL` emails in the seed data. Both display `Anonymous Streamer` in the output.

---

## Marketing Tier Segmentation

Marketing wanted sentiment labels on the dashboard. A `CASE` expression buckets each review into one of three tiers based on score.

```sql
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

![CASE sentiment labels — 8 rows ordered by rating](images/case-sentiment-labels.png)

Returns 8 rows. `CASE` evaluates top-down, so the `>= 8.5` branch catches highly-rated rows before the `>= 7.0` branch runs.
