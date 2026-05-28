-- TEST 1: Illegal insert
-- movie_id 9999 does not exist in movies. 
-- Expected error:
--   ERROR: insert or update on table "ratings" violates foreign key
--          constraint "fk_movie"
--   DETAIL: Key (movie_id)=(9999) is not present in table "movies".

INSERT INTO ratings (movie_id, user_id, rating_value)
VALUES (9999, 104, 7.5);


-- TEST 2: Protected delete
-- Inception (id=1) has ratings attached. ON DELETE RESTRICT should block this.
--
-- Expected error:
--   ERROR: update or delete on table "movies" violates foreign key
--          constraint "fk_movie" on table "ratings"
--   DETAIL: Key (id)=(1) is still referenced from table "ratings".

DELETE FROM movies WHERE id = 1;


-- CORRECT PATTERN: delete child rows first, then the parent
BEGIN;
    DELETE FROM ratings WHERE movie_id = 1;
    DELETE FROM movies  WHERE id = 1;
COMMIT;
