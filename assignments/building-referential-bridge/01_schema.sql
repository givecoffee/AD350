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
