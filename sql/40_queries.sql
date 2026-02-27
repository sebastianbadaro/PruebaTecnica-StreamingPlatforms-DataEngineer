-- =========================
-- 4) QUERIES
-- =========================

-- Q1) Netflix: actor que aparece más veces
SELECT
  p.full_name AS actor,
  COUNT(*)    AS appearances
FROM title_person tp
JOIN person p   ON p.person_id = tp.person_id
JOIN title t    ON t.title_id = tp.title_id
JOIN platform pl ON pl.platform_id = t.platform_id
WHERE pl.platform_name = 'netflix'
  AND tp.role = 'actor'
GROUP BY p.full_name
ORDER BY appearances DESC, actor
LIMIT 1;


-- Q2) Top 10 actores (todas las plataformas) en el año actual (por release_year)


WITH counts AS (
  SELECT
    p.full_name AS actor,
    COUNT(*) AS appearances
  FROM title_person tp
  JOIN person p ON p.person_id = tp.person_id
  JOIN title t  ON t.title_id = tp.title_id
  WHERE tp.role = 'actor'
    AND t.release_year = 2021
     --AND t.release_year = EXTRACT(YEAR FROM CURRENT_DATE)::int
  GROUP BY p.full_name
),
ranked AS (
  SELECT
    actor,
    appearances,
    RANK() OVER (ORDER BY appearances DESC) AS rnk
  FROM counts
)
SELECT *
FROM ranked
WHERE rnk <= 10
ORDER BY appearances DESC, actor;