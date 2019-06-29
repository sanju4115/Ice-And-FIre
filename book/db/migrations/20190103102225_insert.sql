-- migrate:up

--
-- Description
-- This table holds books information
--
-- Is the source of truth: Yes
-- Is mutable: Yes
--
CREATE TABLE public.books (
    id SERIAL PRIMARY KEY,
    name character varying(255),
    isbn character varying(14),
    authors json,
    country character varying(50),
    number_of_pages integer not null,
    publisher character varying(25),
    release_date timestamp without time zone
);

-- migrate:down
