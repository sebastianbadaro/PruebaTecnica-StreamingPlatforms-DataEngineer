-- Carga tabla title (clean) desde staging (idempotente)
-- Nota: asume stg_titles.release_year es TEXT (raw) y stg_titles.duration es TEXT (raw)

BEGIN;

INSERT INTO title (
  platform_id, show_id, type, title,
  date_added_raw, date_added,
  release_year, rating,
  duration_raw, duration_minutes, seasons,
  description
)
SELECT
  p.platform_id,
  s.show_id,
  COALESCE(s.type, '') AS type,
  COALESCE(s.title, '') AS title,

  s.date_added AS date_added_raw,
  CASE
    -- Formato esperado: "September 9, 2019"
    WHEN s.date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$'
      THEN to_date(s.date_added, 'Month DD, YYYY')
    ELSE NULL
  END AS date_added,

  CASE
    WHEN s.release_year ~ '^[0-9]{4}$' THEN s.release_year::int
    ELSE NULL
  END AS release_year,

  s.rating,

  s.duration AS duration_raw,

  CASE
    WHEN trim(s.duration) ~ '^[0-9]+[[:space:]]+min$'
      THEN split_part(trim(s.duration), ' ', 1)::int
    ELSE NULL
  END AS duration_minutes,

  CASE
    WHEN trim(s.duration) ~ '^[0-9]+[[:space:]]+Season(s)?$'
      THEN split_part(trim(s.duration), ' ', 1)::int
    ELSE NULL
  END AS seasons,

  s.description
FROM stg_titles s
JOIN platform p ON p.platform_name = s.platform
WHERE s.show_id IS NOT NULL AND s.show_id <> ''
ON CONFLICT (platform_id, show_id) DO NOTHING;

COMMIT;