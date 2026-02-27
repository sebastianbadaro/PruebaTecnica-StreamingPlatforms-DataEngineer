-- =========================
-- 0) STAGING (RAW)
-- =========================
DROP TABLE IF EXISTS stg_titles;

CREATE TABLE stg_titles (
  platform        text NOT NULL,
  source_file     text NOT NULL,

  show_id         text NOT NULL,
  type            text,
  title           text,
  director        text,
  cast_members    text,
  country         text,
  date_added      text,     -- raw (string)
  release_year    text,
  rating          text,
  duration        text,     -- raw (string)
  listed_in       text,
  description     text
);

CREATE INDEX IF NOT EXISTS ix_stg_titles_platform_showid
  ON stg_titles(platform, show_id);


-- =========================
-- 1) CORE DIMENSIONS
-- =========================
DROP TABLE IF EXISTS platform CASCADE;

CREATE TABLE platform (
  platform_id   bigserial PRIMARY KEY,
  platform_name text NOT NULL UNIQUE
);

DROP TABLE IF EXISTS title CASCADE;

CREATE TABLE title (
  title_id          bigserial PRIMARY KEY,
  platform_id       bigint NOT NULL REFERENCES platform(platform_id),

  show_id           text NOT NULL,
  type              text NOT NULL,
  title             text NOT NULL,

  -- parsed/clean fields (los llenamos desde Python)
  date_added_raw    text,
  date_added        date,

  release_year      int,
  rating            text,

  duration_raw      text,
  duration_minutes  int,
  seasons           int,

  description       text,

  CONSTRAINT uq_title_platform_show UNIQUE(platform_id, show_id)
);

CREATE INDEX IF NOT EXISTS ix_title_release_year ON title(release_year);
CREATE INDEX IF NOT EXISTS ix_title_duration_minutes ON title(duration_minutes);