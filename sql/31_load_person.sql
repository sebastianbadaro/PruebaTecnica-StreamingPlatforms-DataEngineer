BEGIN;

-- 1) Insertar personas desde cast_members + director (deduplicado)
INSERT INTO person(full_name)
SELECT DISTINCT TRIM(x) AS full_name
FROM (
  SELECT unnest(string_to_array(COALESCE(cast_members,''), ',')) AS x
  FROM stg_titles
  UNION ALL
  SELECT unnest(string_to_array(COALESCE(director,''), ',')) AS x
  FROM stg_titles
) t
WHERE TRIM(x) <> ''
ON CONFLICT (full_name) DO NOTHING;

-- 2) Relación title_person: ACTORS
INSERT INTO title_person(title_id, person_id, role)
SELECT t.title_id, p.person_id, 'actor'
FROM stg_titles s
JOIN platform pl ON pl.platform_name = s.platform
JOIN title t ON t.platform_id = pl.platform_id AND t.show_id = s.show_id
CROSS JOIN LATERAL unnest(string_to_array(COALESCE(s.cast_members,''), ',')) AS a(name)
JOIN person p ON p.full_name = TRIM(a.name)
WHERE TRIM(a.name) <> ''
ON CONFLICT DO NOTHING;

-- 3) Relación title_person: DIRECTORS
INSERT INTO title_person(title_id, person_id, role)
SELECT t.title_id, p.person_id, 'director'
FROM stg_titles s
JOIN platform pl ON pl.platform_name = s.platform
JOIN title t ON t.platform_id = pl.platform_id AND t.show_id = s.show_id
CROSS JOIN LATERAL unnest(string_to_array(COALESCE(s.director,''), ',')) AS d(name)
JOIN person p ON p.full_name = TRIM(d.name)
WHERE TRIM(d.name) <> ''
ON CONFLICT DO NOTHING;

COMMIT;