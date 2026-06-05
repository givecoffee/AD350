-- TEST 1: illegal insert
-- Expected error: violates foreign key constraint "fk_movie"
INSERT INTO ratings (movie_id, user_id, rating_value)
VALUES (9999, 104, 7.5);


-- TEST 2: protected delete
-- Expected error: Key (id)=(1) is still referenced from table "ratings"
DELETE FROM movies WHERE id = 1;


-- CORRECT deletion order
DELETE FROM ratings WHERE movie_id = 1;
DELETE FROM movies WHERE id = 1;
