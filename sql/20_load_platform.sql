-- Carga dimension platform desde staging (idempotente)
BEGIN;

INSERT INTO platform(platform_name)
SELECT DISTINCT platform
FROM stg_titles
WHERE platform IS NOT NULL AND platform <> ''
ON CONFLICT (platform_name) DO NOTHING;

COMMIT;