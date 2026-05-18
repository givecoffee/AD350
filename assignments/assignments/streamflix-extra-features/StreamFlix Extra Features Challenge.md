```
Our marketing team wants to store "Extra Details" for movies, but they don't want to keep asking the Database Admins to add new columns every time they have a new piece of info. We’re going to give them a **JSONB** "Details" column where they can store whatever they want.
```

Using JSONB we are going to convert the movies table into a hybrid system. There will be an added JSONB "Details" column where they can store whatever they want. This cuts down the workload on database admins as well, as they won't have to keep manually adding new details. 

To add a flexible column to the movies table we will run the SQL below:

`ALTER TABLE movies`   
`ADD COLUMN details JSONB DEFAULT '{}';`

![[Pasted image 20260517204351.png]]

![[Pasted image 20260517204441.png]]

Details (JSONB) has been added to the movies table so now we can update two separate movies with very different types of information. 

These UPDATE commands will add data to the existing movies. which allows us to add the actors/actresses and other video specs: 

```
UPDATE movies
SET details = '{"resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}'::jsonb
WHERE title = 'Interstellar';
```

![[Pasted image 20260517204813.png]]

Interstellar now has updated technical and casting details:

![[Pasted image 20260517204909.png]]

For my second movie, Fight Club, I decided to use a jsonb_build_object to handle type conversion and keep things clean. I wanted to give it a try, and this is the command I used:

```
UPDATE movies

SET details = jsonb_build_object(
  'director', 'David Fincher',
  'cast', jsonb_build_array('Brad Pitt', 'Edward Norton', 'Helena Bonham Carter'),
  'rating', 'R'
)
WHERE title = 'Fight Club';
```

Here is the return after adding extra details like an added rating and cast members.

![[Pasted image 20260517205819.png]]


![[Pasted image 20260517205840.png]]

Now, time to run queries to pull data back out of the JSONB column and see if everything is working properly. Let's try and pull director and cast information separately:

```
SELECT title, details->>'director' AS director
FROM movies
WHERE details->>'director' IS NOT NULL;
```

```
SELECT title
FROM movies
WHERE details->'cast' @> '["Brad Pitt"]';
```

Movies with Named Directors:
![[Pasted image 20260517210057.png]]

And cast members with Brad Pitt in them:

![[Pasted image 20260517210136.png]]

For the first query, the director only returned for Fight Club because that detail wasn't added to the other movies nor was it updated to that type (JSONB) but it still readily reads JSON. Out of curiosity, I tried updating in its original data type form (JSON) then later updating it to a jsonb build object to see the differences. I wanted to see if the output would be different, or less "clean". It seemed they were actually outputted the same after updating the director info to Interstellar. 

First updating the director to Christopher Nolan:

```
UPDATE movies SET details = '{"director": "Christopher Nolan", "resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}' WHERE title = 'Interstellar';
```

![[Pasted image 20260517210641.png]]

When checking what it looks like with the SQL statement below, it appears it came back as the JSONB data type, which reflects the changes we made earlier. This is good! Was an interesting test to make sure everything was the same. 

```
SELECT title, details, pg_typeof(details) AS data_type FROM movies WHERE title = 'Interstellar';
```


![[Pasted image 20260517210846.png]]

  
Updating using json build object (just to be sure)

```
UPDATE movies SET details = jsonb_build_object( 'director', 'Christopher Nolan', 'resolution', '4K', 'audio', 'Dolby Atmos', 'cast', jsonb_build_array('Matthew McConaughey', 'Anne Hathaway') ) WHERE title = 'Interstellar';
```

The output was the same:

![[Pasted image 20260517211158.png]]

Now, I included an animated film so I could add a special detail of voice casters. I will add a few for the Lion King movie, and then build a query to extract some of that info to see if it is working as intended. 

```
UPDATE movies SET details = jsonb_build_object( 'studio', 'Disney', 'voice_cast', jsonb_build_array('Matthew Broderick', 'James Earl Jones', 'Jeremy Irons', 'Moira Kelly'), 'is_animated', true, 'animation_style', 'Traditional 2D', 'composer', 'Hans Zimmer' ) WHERE title = 'The Lion King';
```

After verifying it was added to the table, I will now pull it back to verify through a query:

```
SELECT title, details->>'studio' AS studio, details->'voice_cast' AS voice_cast FROM movies WHERE title = 'The Lion King';
```

And for a specific voice actor:

```
SELECT title, details->'voice_cast' AS voice_cast FROM movies WHERE details->'voice_cast' @> '["James Earl Jones"]';
```

![[Pasted image 20260517211923.png]]

All working! If this video streaming platform grows to millions of movies, we would need to be able to search and do it quickly. TO index the inside of that column, we will create an index for the movie details using GIN:

```
CREATE INDEX idx_movies_details ON movies USING GIN (details);
```

To test it, we will check if the index was created using:

```
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'movies';
```
![[Pasted image 20260517212501.png]]

With only a couple of movies, the EXPLAIN output would only show the GIN Index instead of scanning every row. This speeds up things at scale, when you're in production and the table grows faster than you can keep up with it. However, this can help show the query planner decision when at a larger scale (for later):

```
EXPLAIN ANALYZE
SELECT title
FROM movies
WHERE details->'voice_cast' @> '["James Earl Jones"]';
```


![[Pasted image 20260517212518.png]]


Full SQL script deliverable:

```
-- Week 6: StreamFlix JSONB Upgrade Script

-- Add the JSONB details column
ALTER TABLE movies 
ADD COLUMN details JSONB DEFAULT '{}';

-- Update Interstellar with technical specs
UPDATE movies
SET details = '{"resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}'::jsonb
WHERE title = 'Interstellar';

-- Update Fight Club with director, cast, and rating
UPDATE movies
SET details = jsonb_build_object(
  'director', 'David Fincher',
  'cast', jsonb_build_array('Brad Pitt', 'Edward Norton', 'Helena Bonham Carter'),
  'rating', 'R'
)
WHERE title = 'Fight Club';

-- Add director to Interstellar (testing JSON string vs jsonb_build_object)
UPDATE movies 
SET details = '{"director": "Christopher Nolan", "resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}'
WHERE title = 'Interstellar';

-- Update The Lion King with voice cast and studio info
UPDATE movies 
SET details = jsonb_build_object(
  'studio', 'Disney',
  'voice_cast', jsonb_build_array('Matthew Broderick', 'James Earl Jones', 'Jeremy Irons', 'Moira Kelly'),
  'is_animated', true,
  'animation_style', 'Traditional 2D',
  'composer', 'Hans Zimmer'
)
WHERE title = 'The Lion King';

-- Query: Find movies with directors
SELECT title, details->>'director' AS director
FROM movies
WHERE details->>'director' IS NOT NULL;

-- Query: Find movies with Brad Pitt in the cast
SELECT title
FROM movies
WHERE details->'cast' @> '["Brad Pitt"]';

-- Query: Pull Lion King details
SELECT title, details->>'studio' AS studio, details->'voice_cast' AS voice_cast
FROM movies
WHERE title = 'The Lion King';

-- Query: Find movies with James Earl Jones in voice cast
SELECT title, details->'voice_cast' AS voice_cast
FROM movies
WHERE details->'voice_cast' @> '["James Earl Jones"]';

-- Create GIN index for fast JSONB searches
CREATE INDEX idx_movies_details ON movies USING GIN (details);

-- Verify index creation
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'movies';

-- Check query plan (for future scaling)
EXPLAIN ANALYZE
SELECT title
FROM movies
WHERE details->'voice_cast' @> '["James Earl Jones"]';
```

Final Supabase Data Explorer Screenshot:

![[Pasted image 20260517212833.png]]

Lightbulb Moment:

***"Why is using one JSONB column better for 'Extra Details' than creating 5 separate standard columns for things like 'Studio,' 'Resolution,' and 'Cast'?"***

Using one JSONB column avoids creating tables full of NULL values where most movies don't need most columns, and it lets you add new data types instantly without waiting for database admins to run schema migrations every time someone has a new idea.

