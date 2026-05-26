CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  release_year INTEGER,
  genre TEXT
);

INSERT INTO movies (title, release_year, genre) VALUES
  ('Interstellar', 2014, 'Sci-Fi'),
  ('Lion King', 1994, 'Animated'),
  ('Fight Club', 1999, 'Action');

SELECT * FROM movies;

ALTER TABLE movies ADD COLUMN viewer_rating NUMERIC(3, 1);
ALTER TABLE movies RENAME COLUMN genre TO category;

UPDATE movies SET viewer_rating = 8.6 WHERE title = 'Interstellar';
UPDATE movies SET viewer_rating = 8.5 WHERE title = 'Lion King';
UPDATE movies SET viewer_rating = 8.8 WHERE title = 'Fight Club';

SELECT * FROM movies;

CREATE TEMPORARY TABLE current_session_users (
  session_id UUID DEFAULT gen_random_uuid(),
  user_id INTEGER,
  logged_in_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO current_session_users (user_id) VALUES (101), (102), (103);

SELECT * FROM current_session_users;

CREATE TABLE monthly_log_test (
  log_id SERIAL PRIMARY KEY,
  event_note TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO monthly_log_test (event_note) VALUES
  ('user opened app'),
  ('user clicked play'),
  ('user paused'),
  ('user logged out');

SELECT COUNT(*) AS rows_before_truncate FROM monthly_log_test;

TRUNCATE TABLE monthly_log_test;

SELECT COUNT(*) AS rows_after_truncate FROM monthly_log_test;

CREATE TABLE test_table_no_longer_needed (
  id SERIAL PRIMARY KEY,
  junk_data TEXT
);

-- DROP TABLE test_table_no_longer_needed;

ALTER TABLE movies ADD COLUMN details JSONB DEFAULT '{}';

UPDATE movies
SET details = '{"resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}'::jsonb
WHERE title = 'Interstellar';

UPDATE movies
SET details = jsonb_build_object(
  'director', 'David Fincher',
  'cast', jsonb_build_array('Brad Pitt', 'Edward Norton', 'Helena Bonham Carter'),
  'rating', 'R'
)
WHERE title = 'Fight Club';

SELECT title FROM movies WHERE details->'cast' @> '["Brad Pitt"]';

UPDATE movies
SET details = jsonb_build_object(
  'studio', 'Disney',
  'voice_cast', jsonb_build_array('Matthew Broderick', 'James Earl Jones', 'Jeremy Irons', 'Moira Kelly'),
  'is_animated', true,
  'animation_style', 'Traditional 2D',
  'composer', 'Hans Zimmer'
)
WHERE title = 'Lion King';

SELECT title, details->>'studio' AS studio, details->'voice_cast' AS voice_cast
FROM movies
WHERE title = 'Lion King';

SELECT title, details->'voice_cast' AS voice_cast
FROM movies
WHERE details->'voice_cast' @> '["James Earl Jones"]';

EXPLAIN ANALYZE
SELECT title FROM movies WHERE details->'voice_cast' @> '["James Earl Jones"]';