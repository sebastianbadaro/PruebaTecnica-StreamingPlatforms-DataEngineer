BEGIN;

-- 1) Insertar géneros
INSERT INTO genre(genre_name)
SELECT DISTINCT TRIM(g) AS genre_name
FROM stg_titles s
CROSS JOIN LATERAL unnest(string_to_array(COALESCE(s.listed_in,''), ',')) AS gg(g)
WHERE TRIM(g) <> ''
ON CONFLICT (genre_name) DO NOTHING;

-- 2) Relación title_genre
INSERT INTO title_genre(title_id, genre_id)
SELECT t.title_id, g.genre_id
FROM stg_titles s
JOIN platform pl ON pl.platform_name = s.platform
JOIN title t ON t.platform_id = pl.platform_id AND t.show_id = s.show_id
CROSS JOIN LATERAL unnest(string_to_array(COALESCE(s.listed_in,''), ',')) AS gg(name)
JOIN genre g ON g.genre_name = TRIM(gg.name)
WHERE TRIM(gg.name) <> ''
ON CONFLICT DO NOTHING;

COMMIT;