# Building StreamFlix BigData

Week 3: Building a schema that can track movies, handle data column rebranding, and manage massive influxes of temporary "watch-session" data.

## Overview

You have been hired as the lead Data Engineer for **StreamFlix**. Your first task is to build a schema that can track movies, handle a sudden rebranding of your data columns, and demonstrate how you would manage a massive influx of temporary "watch-session" data.

Right off the bat, I wanted to have some decent best practices in play. Since this assignment uses Supabase, I had to experiment with it a little and see what some of the newer features could do since I had last seen it a couple years ago. I appreciate that it is open-source and it has been a great experience learning to use it this quarter. Right out of the box, I had to make sure (even for small assignments) to get in the habit of enabling RLS and other security features. I also noticed when creating a table 'movies' for the streamflix database, that you can press CTRL+SHIFT+K to generate a query using plain language which was interesting to point out.

## Task 1: Creating the Movies Table

Build a table named `movies` with columns for `id` (Serial/UUID), `title` (Text), `release_year` (Integer), and `genre` (Text).

I created a movies table with some titles I really enjoy: Interstellar, Lion King, and Fight Club. A good mix for this sample set:

![Creating movies table](images/Pasted%20image%2020260516231225.png)

![Table structure](images/Pasted%20image%2020260516231154.png)

movies has been created:

![Movies table created](images/Pasted%20image%2020260516231302.png)

## Task 2: Altering and Renaming Columns

After creating the table with the appropriate columns, it is time to start altering and renaming the table to ensure we do it properly.

Added a new column called viewer_rating (Numeric) and renamed the 'genre' column to 'category'. Sometimes people want to change things up and we need to be able to add things that didn't exist or alter it.

Queries are automatically named through Supabase based on the context which I find really helpful. Here is the query for the alterations made:

![Altering table structure](images/Pasted%20image%2020260516231750.png)

Using ratings from IMDB, I altered the new category to reflect the viewer ratings, similar to most major websites like Rotten Tomatoes. I also tried to 'prettify' SQL in the three-dot dropdown which I preferred personally. For screenshot purposes though, I will keep it as is.

The changes have been reflected on the table:

![Updated table with ratings](images/Pasted%20image%2020260516232054.png)

## Task 3: Temporary Tables for Session Tracking

A temporary table works exactly like a regular table except it only exists for the duration of your current database session. The moment you close the connection, it's gone automatically. No cleanup, no DROP needed.

This makes temp tables a good fit for data that is only relevant right now. In StreamFlix's case, tracking who is actively watching at this moment is pointless to keep forever. You don't need a record from six months ago of who was online at 2pm on a Tuesday. You just need to know who is online right now, and when they leave, that data has no value.

`gen_random_uuid()` generates a unique ID for each session automatically. `DEFAULT NOW()` stamps the exact time the row was inserted without you having to pass it in manually.

The SQL for creating a temporary table named current_session_users to track users online at this moment:

![Creating temporary table](images/Pasted%20image%2020260516232500.png)

This is incredibly useful for anything that isn't really requiring persistent storage, especially in a web app.

## Task 4: TRUNCATE vs DROP

Next, I am to demonstrate the differences between TRUNCATE and DROP when dealing with tables. TRUNCATE removes all the rows but the actual structure such as the columns, data types, etc all stay intact. I saw an analogy referring to it as a filing cabinet that you emptied out. Whereas DROP would remove the entire filing cabinet itself so the columns, indexes, absolutely everything. When the table should be removed entirely, this would be the better choice.

For StreamFlix, the scenario is the monthly_log_test to track events for the month. We could TRUNCATE it to update it every month and start fresh but keep the column definitions and frame of it. The second table we are going to build something we don't need at all anymore, which we would then use DROP.

When doing this, I was prompted with a warning from Supabase, which is useful to ensure you don't make major mistakes and lose schemas.

![Supabase warning](images/Pasted%20image%2020260516232933.png)

I proceeded to create a new table with junk data:

![Creating test table](images/Pasted%20image%2020260516233309.png)

![Test table data](images/Pasted%20image%2020260516233221.png)

Now, to DROP the table that is no longer needed:

![DROP command](images/Pasted%20image%2020260516233415.png)

![DROP confirmation](images/Pasted%20image%2020260516233423.png)

The dropped table is completely gone:

![Table removed](images/Pasted%20image%2020260516233443.png)

## Key Takeaways

- **ALTER TABLE** lets you modify existing table structures without rebuilding from scratch
- **Temporary tables** are perfect for session-based data that doesn't need to persist
- **TRUNCATE** empties a table but keeps the structure (fast, reusable)
- **DROP** removes the entire table and all its data (permanent deletion)
- Supabase provides helpful warnings and auto-generated query names based on context
