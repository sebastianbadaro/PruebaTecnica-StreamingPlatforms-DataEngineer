-- =========================
-- 3) STORED PROCEDURE
-- =========================
-- Devuelve un cursor con las 5 películas más largas (por minutos) para un año dado

CREATE OR REPLACE PROCEDURE sp_top5_longest_movies(p_year int, INOUT out_cur refcursor)
LANGUAGE plpgsql
AS $$
BEGIN
  OPEN out_cur FOR
    SELECT
      pl.platform_name,
      t.title,
      t.release_year,
      t.duration_minutes
    FROM title t
    JOIN platform pl ON pl.platform_id = t.platform_id
    WHERE t.type = 'Movie'
      AND t.release_year = p_year
      AND t.duration_minutes IS NOT NULL
    ORDER BY t.duration_minutes DESC, t.title
    LIMIT 5;
END;
$$;

-- Ejemplo de uso:
 BEGIN;
 CALL sp_top5_longest_movies(2020, 'cur');
 FETCH ALL FROM cur;
 COMMIT;