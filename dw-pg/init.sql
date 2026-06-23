-- ============================================
--  La Barca — Data Warehouse PostgreSQL
--  Separación lógica en 3 schemas
-- ============================================

-- Schema RAW: aterrizaje desde Airbyte (sin tocar)
CREATE SCHEMA IF NOT EXISTS raw;

-- Schema STAGING: limpieza y tipado con dbt
CREATE SCHEMA IF NOT EXISTS staging;

-- Schema MARTS: esquema estrella final (DataMart → Power BI)
CREATE SCHEMA IF NOT EXISTS marts;

-- Usuario para dbt
CREATE USER dbt_user WITH PASSWORD 'dbt1234';
GRANT ALL PRIVILEGES ON DATABASE labarca_dw TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA raw TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA staging TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA marts TO dbt_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA raw TO dbt_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO dbt_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA marts TO dbt_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA raw GRANT ALL ON TABLES TO dbt_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA staging GRANT ALL ON TABLES TO dbt_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA marts GRANT ALL ON TABLES TO dbt_user;
