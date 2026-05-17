# StreamFlix Database Demo
```
You have been hired as the lead Data Engineer for StreamFlix. Your first task is to build a schema that can track movies, handle a sudden rebranding of your data columns, and demonstrate how you would manage a massive influx of temporary "watch-session" data.
```
Right off the bat, I wanted to have some decent best practices in play. Since this assignment uses Supabase, I had to experiment a little and see what some of the newer features could do since I had last seen it a couple years ago. I appreciate that it is open-source and it has been a great experience learning to use it this quarter. Right out of the box, I had to make sure, even for small assignments, to get in the habit of enabling RLS and other security features. I also noticed when creating a table for the streamflix database that you can press CTRL+SHIFT+K to generate a query using plain language, which was interesting to point out.
---
## Step 1: CREATE
`Build a table named movies with columns for id (Serial/UUID), title (Text), release_year (Integer), and genre (Text).`
I created a movies table with some titles I really enjoy: Interstellar, Lion King, and Fight Club. A good mix for this sample set.
Show Image
Show Image
movies has been created:
Show Image
---
## Step 2: ALTER and RENAME
After creating the table with the appropriate columns, it was time to start altering and renaming. Added a new column called viewer_rating (Numeric) and renamed the genre column to category. Sometimes things change and we need to be able to add things that didn't exist or rename what does.
Queries are automatically named through Supabase based on context, which I find really helpful. Here is the query for the alterations:
Show Image
Using ratings from IMDB, I filled in the viewer_rating values, similar to how most major platforms like Rotten Tomatoes display them. I also tried the prettify SQL option in the three-dot dropdown, which I preferred personally.
The changes reflected on the table:
Show Image
---
## Step 3: Temporary Tables
A temporary table works exactly like a regular table except it only exists for the duration of your current database session. The moment you close the connection, it's gone automatically. No cleanup, no DROP needed.
This makes temp tables a good fit for data that is only relevant right now. In StreamFlix's case, tracking who is actively watching at this moment is pointless to keep forever. You don't need a record from six months ago of who was online at 2pm on a Tuesday. You just need to know who is online right now, and when they leave, that data has no value.
gen_random_uuid() generates a unique ID for each session automatically. DEFAULT NOW() stamps the exact time the row was inserted without you having to pass it in manually.
Show Image
This is incredibly useful for anything that doesn't require persistent storage, especially in a web app.
---
## Step 4: TRUNCATE vs DROP
TRUNCATE removes all the rows but the structure stays intact. The columns, data types, indexes, all of it remains. Think of it like emptying a filing cabinet. The cabinet is still there, ready to be filled again.
DROP removes the entire filing cabinet. Columns, indexes, everything. Gone. You use this when the table should not exist at all anymore, not just when it should be empty.
For StreamFlix, the scenario is a monthly_log_test table to track events for the current month. At the end of the month we TRUNCATE it to start fresh while keeping the structure. The second table is something we built for testing that we don't need anymore, so we DROP it entirely.
When running the DROP, Supabase prompted a warning, which is useful to make sure you don't lose something important by accident.
Show Image
Creating the junk table to demonstrate DROP:
Show Image
Show Image
Dropping it:
Show Image
Show Image
The table is completely gone:
Show Image
---
## The Big Data Pitch
StreamFlix just went viral. Half a billion play and pause events per hour, which works out to about 139,000 events per second sustained.
Postgres can handle that with the right setup, partitioned tables, good indexing, a well-tuned server. But at that scale your whole engineering team is spending their time keeping the database alive instead of building product. That's the real signal.
The answer isn't to replace Postgres. Postgres stays for anything transactional, movies, users, subscriptions. The event stream goes to Kafka for ingestion, Spark picks it up and processes it across a cluster, and writes aggregates back to a warehouse or back to Postgres for the app to read.
Vertical scaling means making one machine bigger. More RAM, faster CPU, better disk. Works up to a point, then you hit a wall and the cost goes steep.
Horizontal scaling means adding more machines that share the work. Spark distributes across a cluster. Traffic doubles, you add nodes. The ceiling is much higher and the cost stays manageable.
Postgres is one really strong person lifting a heavy box. Spark is twenty people each carrying a smaller piece at the same time. At 500 million events an hour, you stop looking for a stronger person and start hiring more of them.
