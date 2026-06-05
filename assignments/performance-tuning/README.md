# Week 5: Supabase Performance Tuning

So we are going to be undergoing a schema change right off the bat since we are going to be optimizing for performance. In our previous Referential Bridge assignment, I initially set rating_value to be a numeric, and used a foreign key to link back to the 'movies' table.

This week, however, we are going to be using score INT without a foreign key. This is because instead of demonstrating referential integrity, we are testing raw query performance. We can also drop the foreign key. We are generating randomly at scale, and a lot of those movies won't exist with IDs in our table so it would ultimately reject every single insert.

Let's get started and run a query, with CREATE TABLE IF NOT EXISTS meaning if the table already exists then it won't error. It can just move on and TRUNCATE, which will clear it clean.

```sql
CREATE TABLE IF NOT EXISTS ratings (
    id         SERIAL      PRIMARY KEY,
    movie_id   INT,
    user_id    INT,
    score      INT         NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

TRUNCATE TABLE ratings;
```

Since we are tackling performance issues (GitHub Issues #19-21) we will start with the seed + baseline, then move to the index + verification portion, and finally make a final report document to tie everything together.

We ran the schema and truncated, so let's run the seed. We will be inserting a million rows so it can take some time.

```sql
INSERT INTO ratings (movie_id, user_id, score, created_at)
SELECT
    floor(random() * 100  + 1)::int AS movie_id,
    floor(random() * 5000 + 1)::int AS user_id,
    floor(random() * 10   + 1)::int AS score,
    now() - (random() * interval '365 days') AS created_at
FROM generate_series(1, 1000000);
```

I ran into an error, because of the changes from Week 4's assignment not fully going through (still has rating_value) which was a numeric, instead of 'score' which is an integer. We will run the following to force the replacement:

```sql
DROP TABLE ratings;

CREATE TABLE ratings (
    id         SERIAL      PRIMARY KEY,
    movie_id   INT,
    user_id    INT,
    score      INT         NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

After rerunning it and changing the ratings structure, we were able to run the seed. It generated surprisingly fast, only a few seconds.

Says at the bottom, 1.0M records estimated:

![1.0M records estimated in table editor](images/Pasted%20image%2020260604013103.png)

To be safe, let's verify the exact count:

```sql
SELECT count(*) FROM ratings;
```

Exact count:

![Exact count query returning 1000000](images/Pasted%20image%2020260604013139.png)

We have exactly 1,000,000 ratings. Now, we can work on the baseline query:

```sql
EXPLAIN ANALYZE
SELECT * FROM ratings
WHERE score = 10;
```

Our baseline, which was a Sequential Scan (it read every single row) had examined 1,000,000 rows and removed 899,967 using a filter. It then returned 100,033 rows. It took over 4.32 seconds for a simple filter query. We need to document that, this is the "BEFORE" we are tracking after we make changes.

Let's run a fix:

```sql
CREATE INDEX idx_ratings_score ON ratings(score);
```

Let's now try and analyze the same query from before:

```sql
EXPLAIN ANALYZE
SELECT * FROM ratings
WHERE score = 10;
```

As a result, we were able to use a bitmap scan which is more efficient for larger result sets. It used the index, but was a lot quicker because a lot of rows already match. The results returned were:

![EXPLAIN ANALYZE output showing Bitmap Index Scan at 38.87ms](images/Pasted%20image%2020260604013719.png)

Which is 38.87ms instead of the 4.32s before. We still returned the same 100,033 rows but just much faster.

Math below:

```
(4321.66 - 38.87) / 4321.66 * 100 = 99.1% faster
```
