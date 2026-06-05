-- 02_seed.sql
-- Updates movies with heterogeneous JSONB data.

-- Interstellar: technical specs
UPDATE movies
SET details = '{"resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}'::jsonb
WHERE title = 'Interstellar';

-- Fight Club: director, cast, rating (using jsonb_build_object)
UPDATE movies
SET details = jsonb_build_object(
    'director', 'David Fincher',
    'cast', jsonb_build_array('Brad Pitt', 'Edward Norton', 'Helena Bonham Carter'),
    'rating', 'R'
)
WHERE title = 'Fight Club';

-- Add director to Interstellar
UPDATE movies
SET details = '{"director": "Christopher Nolan", "resolution": "4K", "audio": "Dolby Atmos", "cast": ["Matthew McConaughey", "Anne Hathaway"]}'
WHERE title = 'Interstellar';

-- The Lion King: voice cast and studio info
UPDATE movies
SET details = jsonb_build_object(
    'studio', 'Disney',
    'voice_cast', jsonb_build_array('Matthew Broderick', 'James Earl Jones', 'Jeremy Irons', 'Moira Kelly'),
    'is_animated', true,
    'animation_style', 'Traditional 2D',
    'composer', 'Hans Zimmer'
)
WHERE title = 'The Lion King';
