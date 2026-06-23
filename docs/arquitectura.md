# Arquitectura del Pipeline

## Diagrama del flujo

```
CSV (155,057 registros de ventas)
    |
    v  Python — load_csv_to_mysql.py
MySQL 8.0 (OLTP)
    labarca_oltp.ventas
    Puerto: 3307
    |
    v  Airbyte CDC — Change Data Capture
    Binlog MySQL -> Airbyte -> PostgreSQL
    |
    v  PostgreSQL 16 (Data Warehouse)
    labarca_dw — schema: raw
    Tabla: raw.ventas (155,057 filas)
    |
    v  dbt run — modelo stg_ventas
    schema: staging
    Vista: stg_ventas (limpieza y tipado)
    |
    v  dbt run — modelos marts
    schema: marts
    ├── dim_tiempo   (821 filas)
    ├── dim_producto (27 filas)
    ├── dim_cliente  (1,400 filas)
    ├── dim_pedido   (269 filas)
    └── fact_ventas  (155,057 filas)
    |
    v  Power BI Desktop
    Modelo semántico + Medidas DAX
    Dashboard interactivo (3 páginas)
```

## Tipo de pipeline: ELT

El pipeline implementado sigue el patrón **ELT (Extract, Load, Transform)**:

- **Extract:** Los datos se extraen desde el CSV y se cargan al OLTP con Python
- **Load:** Airbyte carga los datos desde MySQL hacia PostgreSQL sin transformar (schema raw)
- **Transform:** dbt aplica las transformaciones sobre los datos ya cargados en PostgreSQL

Este patrón es diferente al ETL clásico porque la transformación ocurre dentro del Data Warehouse, aprovechando la potencia de SQL en PostgreSQL.

## CDC — Change Data Capture

La ingesta usa **CDC** para capturar los cambios en la base transaccional en tiempo real. Airbyte lee el **binlog de MySQL** (registro de operaciones INSERT, UPDATE, DELETE) y replica los cambios hacia PostgreSQL de forma incremental.

Esto permite que el Data Warehouse esté siempre sincronizado con el OLTP sin necesidad de recargar toda la tabla cada vez.

## Capas del Data Warehouse

| Capa | Schema | Propósito |
|---|---|---|
| Bronze / Raw | raw | Datos tal como llegan desde Airbyte, sin transformar |
| Silver / Staging | staging | Datos limpiados, renombrados y con tipos correctos |
| Gold / Marts | marts | Dimensiones y hechos listos para análisis en Power BI |

## Infraestructura

Todo el pipeline corre en contenedores Docker sobre la misma máquina local:

| Contenedor | Imagen | Puerto |
|---|---|---|
| labarca-oltp-mysql | mysql:8.0 | 3307 |
| labarca-dw-pg | postgres:16 | 5433 |
| airbyte-abctl-control-plane | kindest/node | 8000 |

El archivo `docker-compose.yml` levanta MySQL y PostgreSQL. Airbyte se levanta por separado con `abctl local install`.
