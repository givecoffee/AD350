# Week 8: StreamFlix User Engagement Analytics

SQL JOIN queries connecting the movies catalog to user review data.

## Setup

The movies table had a column named `category` instead of `genre` from prior schema work, and the ratings table had been rebuilt for Week 5 performance testing with a different schema. Both were reset before this lab.

Movies ended up with IDs 4-8 due to sequence state from prior truncates. Ratings reference those actual IDs.

## Tasks

### Task 1: INNER JOIN — Active Reviews Feed

Returns only reviews for movies that currently exist in the catalog.

```sql
SELECT m.title, r.user_email, r.user_rating, r.review_text
FROM movies m
INNER JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title, r.user_rating DESC;
```

Result: 4 rows. Excludes `ghost@email.com` (orphan, no matching movie) and Gladiator II (no ratings).

### Task 2: LEFT JOIN — Unreviewed Movies Audit

Returns all movies, filters for those with no ratings. Used by marketing to find catalog gaps.

```sql
SELECT m.title, m.category, m.release_year, r.user_rating
FROM movies m
LEFT JOIN ratings r ON m.id = r.movie_id
WHERE r.user_rating IS NULL
ORDER BY m.title;
```

Result: Gladiator II and Jurassic Park — both in catalog with no reviews.

### Task 3: FULL OUTER JOIN — System Integrity Audit

Returns everything from both tables. Reveals orphan ratings and unreviewed movies together.

```sql
SELECT m.title AS movie_title, r.user_email, r.user_rating, r.review_text
FROM movies m
FULL OUTER JOIN ratings r ON m.id = r.movie_id
ORDER BY m.title NULLS LAST, r.user_email;
```

Result: 7 rows. Gladiator II and Jurassic Park show NULL ratings; `ghost@email.com` shows NULL movie title.

## JOIN Type Comparison

| JOIN Type | Left Table | Right Table | Orphans | Use Case |
|-----------|------------|-------------|---------|----------|
| INNER | Matched only | Matched only | Excluded | Active data feeds |
| LEFT | All rows | Matched only | Excluded | Find catalog gaps |
| FULL OUTER | All rows | All rows | Included | System integrity audit |

## Core Structural Difference

INNER JOIN returns only rows where a match exists in both tables. If either side has no match, that row is dropped entirely.

LEFT JOIN returns every row from the left table regardless of whether a match exists on the right. Where no match is found, the right table columns come back as NULL. This is what makes it useful for finding gaps — the NULLs mark the missing relationships.

In practice: INNER JOIN shows complete relationships only; LEFT JOIN shows complete relationships plus everything from the left that has nothing on the right.

## Files

- `01_seed.sql` — reset movies and ratings, insert test data
- `02_queries.sql` — all three JOIN queries with comments

## Closes

- #27 User engagement analytics with INNER, LEFT, and FULL JOINs
- #28 Document structural differences between JOIN types
- #43 Reset and seed StreamFlix tables for analytics lab
