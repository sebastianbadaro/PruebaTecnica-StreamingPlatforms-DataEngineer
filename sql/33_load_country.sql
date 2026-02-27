BEGIN;

-- 1) Insertar países
INSERT INTO country_dim(country_name)
SELECT DISTINCT TRIM(c) AS country_name
FROM stg_titles s
CROSS JOIN LATERAL unnest(string_to_array(COALESCE(s.country,''), ',')) AS cc(c)
WHERE TRIM(c) <> ''
ON CONFLICT (country_name) DO NOTHING;

-- 2) Relación title_country
INSERT INTO title_country(title_id, country_id)
SELECT t.title_id, c.country_id
FROM stg_titles s
JOIN platform pl ON pl.platform_name = s.platform
JOIN title t ON t.platform_id = pl.platform_id AND t.show_id = s.show_id
CROSS JOIN LATERAL unnest(string_to_array(COALESCE(s.country,''), ',')) AS cc(name)
JOIN country_dim c ON c.country_name = TRIM(cc.name)
WHERE TRIM(cc.name) <> ''
ON CONFLICT DO NOTHING;

COMMIT;