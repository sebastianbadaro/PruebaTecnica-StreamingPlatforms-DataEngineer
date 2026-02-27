BEGIN;

-- PERSON
DROP TABLE IF EXISTS title_person;
DROP TABLE IF EXISTS person;

CREATE TABLE person (
  person_id bigserial PRIMARY KEY,
  full_name text NOT NULL UNIQUE
);

CREATE TABLE title_person (
  title_id  bigint NOT NULL REFERENCES title(title_id) ON DELETE CASCADE,
  person_id bigint NOT NULL REFERENCES person(person_id) ON DELETE CASCADE,
  role      text NOT NULL CHECK (role IN ('actor','director')),
  PRIMARY KEY (title_id, person_id, role)
);

CREATE INDEX IF NOT EXISTS ix_title_person_role ON title_person(role);

-- GENRE
DROP TABLE IF EXISTS title_genre;
DROP TABLE IF EXISTS genre;

CREATE TABLE genre (
  genre_id   bigserial PRIMARY KEY,
  genre_name text NOT NULL UNIQUE
);

CREATE TABLE title_genre (
  title_id bigint NOT NULL REFERENCES title(title_id) ON DELETE CASCADE,
  genre_id bigint NOT NULL REFERENCES genre(genre_id) ON DELETE CASCADE,
  PRIMARY KEY (title_id, genre_id)
);

-- COUNTRY
DROP TABLE IF EXISTS title_country;
DROP TABLE IF EXISTS country_dim;

CREATE TABLE country_dim (
  country_id   bigserial PRIMARY KEY,
  country_name text NOT NULL UNIQUE
);

CREATE TABLE title_country (
  title_id   bigint NOT NULL REFERENCES title(title_id) ON DELETE CASCADE,
  country_id bigint NOT NULL REFERENCES country_dim(country_id) ON DELETE CASCADE,
  PRIMARY KEY (title_id, country_id)
);

COMMIT;