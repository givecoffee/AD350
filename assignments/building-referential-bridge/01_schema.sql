-- Creates the movies (parent) and ratings (child) tables.

DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS movies  CASCADE;


CREATE TABLE movies (
    id            SERIAL       PRIMARY KEY,
    title         TEXT         NOT NULL,
    release_year  INTEGER,
    category      TEXT,
    viewer_rating NUMERIC(3,1) CHECK (viewer_rating BETWEEN 0 AND 10),
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


CREATE TABLE ratings (
    id           SERIAL       PRIMARY KEY,
    movie_id     INT          NOT NULL,
    user_id      INT          NOT NULL,
    rating_value NUMERIC(3,1) NOT NULL CHECK (rating_value BETWEEN 0 AND 10),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_movie
        FOREIGN KEY (movie_id)
        REFERENCES movies (id)
        ON DELETE RESTRICT
);
