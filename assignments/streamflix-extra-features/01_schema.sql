-- 01_schema.sql
-- Adds a flexible JSONB column to the movies table.

ALTER TABLE movies
ADD COLUMN details JSONB DEFAULT '{}';
