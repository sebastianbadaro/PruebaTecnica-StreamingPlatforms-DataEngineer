# Prueba Técnica — Data Engineer (Streaming Platforms)

Este repositorio contiene la resolución de una **prueba técnica para una empresa de datos**.  
El desafío está orientado a evaluar habilidades de **ingesta**, **calidad de datos (QA)**, **modelado relacional** y **SQL** usando datasets de plataformas de streaming (por ejemplo, Netflix / Disney+).

🎥 **Video explicativo (demo):**  
https://drive.google.com/file/d/1X_zmN9vV1U1HuEgsI8ADVh1B8zqqkNzi/view?usp=drive_link

---

## Objetivo

Construir un flujo **end-to-end** que:

1. **Extraiga** los datasets (descarga desde un repositorio tipo S3 u origen equivalente).
2. Ejecute un proceso de **QA** para identificar y corregir problemas comunes (nulos, formatos, duplicados, normalización).
3. Modele y cargue la información en una **base relacional** (PostgreSQL local).
4. Responda consultas **SQL** del negocio (actores con más apariciones, top rankings por año, etc.).

---

## Consigna (resumen)

> La consigna original se resume en 4 bloques (en términos funcionales):

### 1) Programático (Python + descarga desde storage)
- Implementar una función/runner en Python para **descargar archivos CSV** desde un repositorio (por ejemplo S3).
- Debe permitir **cambiar bucket/ubicación** y **rutas/archivos** sin tocar el código (parametrizable).

### 2) QA / Data Quality (Python)
- Realizar análisis descriptivo y controles de calidad sobre los CSV.
- Documentar hallazgos (y correcciones) en un **Notebook**.

### 3) Modelado + DDL
- Proponer un **modelo de datos** a partir del dataset normalizado.
- Crear el **DDL** para tablas e índices.
- Cargar los datos en una base relacional.

### 4) SQL
Resolver consultas sobre el modelo cargado, incluyendo:
- Actor con más apariciones en una plataforma (por ejemplo Netflix).
- Top 10 actores considerando ambas plataformas para un año objetivo (idealmente el año actual o parametrizable).
- Stored Procedure/función que reciba un **año** y devuelva las **5 películas** de mayor duración.

---

## Stack utilizado

- **Python** (Pandas / Numpy / SQLAlchemy)
- **Jupyter** (notebooks para QA + ejecución guiada)
- **PostgreSQL** (local, vía Docker Compose)
- **SQL / PLpgSQL** (consultas + stored procedure/función)
- **dotenv** para configuración por variables de entorno

> Nota: el repo está preparado para ejecución local y reproducible.

---

## Solución propuesta (cómo está armado)

### 1) Ingesta (storage → `data/`)
- Descarga de archivos CSV desde un origen tipo S3 (parametrizable).
- Persistencia local en carpeta `data/` como “raw inputs”.

**Por qué:** separa claramente “raw” de “transformado” y permite reproducir y auditar.

### 2) QA / Limpieza (Notebook → `data/` / staging)
En notebooks se realiza:
- Perfilado (nulos, duplicados, cardinalidad, estadísticos)
- Estandarización de tipos (fechas, duración, años)
- Normalización de campos tipo lista (cast, categorías/géneros) cuando aplica
- Reglas de calidad (mínimas) y reporte de hallazgos

**Salida:** dataset listo para modelar/cargar (staging).

### 3) Modelado relacional (DDL → Postgres)
Se define un modelo relacional (dimensiones + tablas puente cuando hay relaciones muchos-a-muchos), por ejemplo:
- títulos (películas/series)
- personas (actores/directores)
- relación título–persona con rol
- géneros/categorías (opcional según necesidad)

Se incluyen scripts en `sql/` para:
- crear tablas e índices (DDL)
- cargar datos (si aplica)
- consultas de la consigna
- stored procedure/función parametrizada por año

### 4) Respuestas SQL (consultas reproducibles)
Las consultas se dejan en archivos `.sql` para ejecución y verificación rápida:
- métricas por plataforma
- ranking de actores
- top de duración por año

---

## Estructura del repositorio

```
.
├─ data/                # insumos y/o salidas (raw/stage según implementación)
├─ docs/                # documentación extra (consigna, notas, diagramas, etc.)
├─ notebooks/           # QA + ejecución guiada
├─ sql/                 # DDL, queries, stored procedure/función
├─ src/                 # utilidades de ingesta y helpers
├─ docker-compose.yml   # PostgreSQL local
├─ requirements.txt
└─ README.md
```

---

## Cómo ejecutar (local)

### Requisitos
- Python 3.10+
- Docker + Docker Compose

### 1) Crear entorno e instalar dependencias
```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# Linux/Mac: source .venv/bin/activate

pip install -r requirements.txt
```

### 2) Levantar Postgres local
```bash
docker compose up -d
```

### 3) Configuración (sin secrets)
Este repo **no incluye credenciales**. Usá variables de entorno o un archivo `.env` local **NO versionado**.

Ejemplo `.env.example` (solo plantilla):
```ini
# Storage (si aplica)
AWS_PROFILE=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=

# Database (local)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=
DB_USER=
DB_PASSWORD=
```

> Tip: si usás `python-dotenv`, podés cargar el `.env` automáticamente en tus notebooks/scripts.

### 4) Ejecutar QA (notebooks)
1. Abrí Jupyter:
```bash
jupyter lab
```
2. Ejecutá notebooks en `notebooks/` en orden:
   - primero QA/profiling
   - luego transformación/staging
   - finalmente carga a DB (si el flujo lo incluye en notebooks)

### 5) Ejecutar DDL y queries
- Ejecutar `sql/` en Postgres (DDL → carga → queries).
- También podés correrlos desde un cliente (DBeaver/psql) o vía SQLAlchemy.

---

## Decisiones de diseño

- **Staging local**: simple, auditable y fácil de inspeccionar.
- **PostgreSQL local como data mart**: permite consultas rápidas y facilita mostrar SQL/PLpgSQL.
- **Notebooks como unidad de QA**: en una prueba técnica es el mejor trade-off para explicar hallazgos y decisiones.
- **SQL reproducible**: queries en archivos para facilitar evaluación y revisión.

---

## Limitaciones y próximos pasos

- Empaquetado: migrar la lógica de notebooks a módulos `.py` ejecutables (modo headless).
- Observabilidad: logs estructurados, métricas por etapa, retries/backoff, alertas.
- Testing: unit tests + contract tests (schemas) + data tests (muestras).
- Parametrización: años, paths, endpoints y credenciales via config/env vars.
- Modelado: agregar diagrama ER (en `docs/`) y documentar claves/índices con mayor detalle.

---

## Demo / evidencia

- Video explicativo:  
  https://drive.google.com/file/d/1X_zmN9vV1U1HuEgsI8ADVh1B8zqqkNzi/view?usp=drive_link

---

## Nota de privacidad

Este repositorio está preparado como versión **publicable**:
- Sin mención a la empresa evaluadora
- Sin credenciales ni secretos
- Con foco en el proceso técnico y la reproducibilidad


