# Week 4: Building the Referential Bridge

Wiki Info: https://github.com/givecoffee/AD350/wiki#week-4---building-the-referential-bridge

Demo: https://youtu.be/kgHVkP4GGSc

Your "StreamFlix" app is growing. You now need to allow users to rate movies. However, if you delete a movie, you don't want "ghost ratings" (ratings for a movie that no longer exists) cluttering your database. You will implement a Foreign Key to prevent this.

---

## Architecture Breakdown

Before jumping in, we should answer some main questions:

**The Question:** If we were storing millions of raw, unformatted user "click-stream" logs, would we put them in this Supabase PostgreSQL table (Data Warehouse) or a Data Lake? Why?

**The Expert Answer:** We would use a Data Lake. Raw logs are high-velocity and "messy." A PostgreSQL Data Warehouse requires Schema-on-Write, meaning the data must be perfectly formatted before it's saved. A Data Lake allows for Schema-on-Read, letting us ingest massive amounts of raw data immediately and figure out how to format it only when we are ready to analyze it.

Why does data storage architecture matter in the first place? When working with PostgreSQL or a Data Warehouse, the data should be cleaned before it comes in and every row must match the schema. If it doesn't, it is rejected. That is the difference between schema-on-write and schema-on-read. If the schema is written, it has already been enforced before the data came in and must match.

On the other side of the coin, we have Data Lakes. These can be AWS S3 or HDFS, which essentially are "dump now, sort it out later" systems. Raw data, messy and crazy JSON with inconsistent fields are all stored immediately. When it comes time to actually analyze it, you have to define the structure at read time. That is how schema-on-read works. They are both good for solving different problems. Certain data formats are really messy and will change over time and don't need to be queried immediately, such as the click-stream logs (where the user is logged for every play, pause, etc) so this data can go to the Data Lake.

Now, if you need something queried constantly or the structure is already known and stable and doesn't need to be sorted out later, then you can store something such as movie reviews or the movies themselves in a Data Warehouse. The foundation is different, and referential integrity is too. For this assignment, we are also going to implement a foreign key which can be very useful.

---

## Creating the Ratings Table

Starting off, we will be running this script:

```sql
CREATE TABLE ratings (
    id           SERIAL       PRIMARY KEY,
    movie_id     INT          NOT NULL,
    user_id      INT          NOT NULL,
    rating_value NUMERIC(3,1) CHECK (rating_value >= 0 AND rating_value <= 10),
    created_at   TIMESTAMPTZ  DEFAULT NOW(),

    CONSTRAINT fk_movie
        FOREIGN KEY (movie_id)
        REFERENCES movies (id)
        ON DELETE RESTRICT
);
```

![Created ratings table](images/Pasted%20image%2020260601225947.png)

Best practice right off the bat by naming the CONSTRAINT. By naming the constraint `fk_movie`, it can help in larger or growing codebases where debugging multiple constraints can make it hard to track down specific issues. Going to try my best to remember this going forward and get in the habit of doing it. When this error fires, it will say "violates foreign key constraint fk_movie".

`FOREIGN KEY (movie_id)` - column in child table is the one being constrained

`REFERENCES movies (id)` - every value in movie_id must exist in movies.id. The parent table and the specific column it points to

`ON DELETE RESTRICT` - If you try to delete a row from movies, check if any ratings reference the id. If yes, block the delete entirely.

`ON DELETE CASCADE` (alternative) - can automatically delete all ratings when a movie is deleted. Can be really dangerous as you are losing user data. By using RESTRICT, you are forcing a deliberate cleanup.

`CHECK (rating_value BETWEEN 0 AND 10)` - constraint where you can reject any rating outside of 0-10. Adds another layer of protection.

`TIMESTAMPTZ` rather than `TIMESTAMP` - this can store timezone information and help if you ever plan on having international users (and I definitely will). Depending on if you are making a domestic or locally-focused app, then it probably wouldn't matter.

PostgreSQL is great when you need structured data where the relationships actually matter. The foreign key is enforcing the relationship between those pieces of data. Always test the data, kick the tires, ensure those relationships are being enforced. When you are referencing from so many tables, you are going to want to make sure this is sure-proof.

---

## Adding a Movie and Linking a Rating

```sql
INSERT INTO ratings (movie_id, user_id, rating_value)
VALUES (1, 101, 9.0);
```

We are going to insert a rating linked to user ID#101 for movie ID#1 (for Interstellar) and with a rating of 9.0.

Now we can verify the relationship with a JOIN:

```sql
SELECT m.title, r.user_id, r.rating_value
FROM movies m
JOIN ratings r ON m.id = r.movie_id;
```

![JOIN query showing relationship](images/Pasted%20image%2020260603151121.png)

Foreign key relationship is intact. Let's try to break it on purpose and put in an illegal insert to test it.

---

## Testing Referential Integrity

### Test 1: Illegal Insert

```sql
INSERT INTO ratings (movie_id, user_id, rating_value)
VALUES (9999, 104, 7.5);
```

![Illegal insert error](images/Pasted%20image%2020260603151311.png)

The error tells us (with the named constraint earlier "fk_movie") that the foreign key constraint has been violated. Movie id 9999 does not exist, thus not being present in the table "movies" so it is giving a helpful error message that knows exactly why it is being rejected.

### Test 2: Protected Delete

Moving on, we can test ON DELETE RESTRICT. We have a rating attached to Interstellar, so let's test it:

```sql
DELETE FROM movies WHERE id = 1;
```

![Destructive operation warning](images/Pasted%20image%2020260603151618.png)

We get a warning that this query has destructive operations. But after running it, we get this error:

![Protected delete error](images/Pasted%20image%2020260603151652.png)

Same constraint, but opposite direction. Think about how we were testing the ratings table earlier and how it holds a reference. Key id = 1 is referenced from table "ratings" and so when you try to orphan the child rows, it stops it.

### Correct Deletion Order

If you wanted to correctly delete these two, you would run the following query to delete the children and then the parent. Constraints are not an end all be all but just a guardrail to enforce the right order of parent/child relationships.

```sql
DELETE FROM ratings WHERE movie_id = 1;
DELETE FROM movies WHERE id = 1;
```
