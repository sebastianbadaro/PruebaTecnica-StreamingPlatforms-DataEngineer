\# Rocking Data Challenge — Data Engineer



Solución end-to-end del desafío: QA + modelado en Postgres + queries + stored procedure.



\## Cómo correrlo (rápido)

1\) Levantar Postgres:

docker compose up -d



2\) Crear tablas:

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/ddl.sql



3\) Cargar staging (lee data/\*\_titles.csv):

python src/load\_staging.py



4\) Poblar modelo (SQL):

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/20\_load\_platform.sql

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/21\_load\_title.sql

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/30\_ddl\_dimensions.sql

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/31\_load\_person.sql

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/32\_load\_genre.sql

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/33\_load\_country.sql



5\) Queries + Stored Procedure:

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/40\_queries.sql

docker exec -i rkd\_postgres psql -U rkd -d rkd < sql/41\_sp\_top5\_longest\_movies.sql



QA está documentado en notebooks/.



\## Decisiones principales (por qué está así)

\- STAGING RAW + modelo clean: primero cargo `stg\_titles` sin forzar tipos (robusto ante datos raros), después lleno `title` ya limpio/parseado.

\- Parse según QA:

&nbsp; - `duration` mezcla "min" y "Seasons" → en `title`: `duration\_raw`, `duration\_minutes`, `seasons`.

&nbsp; - `date\_added` puede traer valores anómalos → en `title`: `date\_added\_raw` + `date\_added` parseado.

\- Snowflake por columnas multi-valued:

&nbsp; - `cast\_members`, `director`, `listed\_in`, `country` vienen como listas con cardinalidad variable → se normaliza a dimensiones y tablas puente.

&nbsp; - `person` + `title\_person` (con `role` actor/director), `genre` + `title\_genre`, `country\_dim` + `title\_country`.

\- Personas con rol: unifico actores y directores en `person` y distingo con `role` en `title\_person` (evita duplicación y simplifica consultas).

\- Clave natural: 1 fila por título por plataforma usando `platform + show\_id` (UNIQUE en `title`).



\## Nota

\- En `data/` los archivos deben llamarse `<platform>\_titles.csv` (ej: `netflix\_titles.csv`, `disney\_plus\_titles.csv`).

