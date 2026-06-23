# Data Warehouse — PostgreSQL

## Descripción

El Data Warehouse usa PostgreSQL 16 corriendo en Docker. Está organizado en tres schemas que representan las capas del pipeline ELT.

## Configuración del contenedor

```yaml
labarca-dw-pg:
  image: postgres:16
  container_name: labarca-dw-pg
  ports:
    - "5433:5432"
  environment:
    POSTGRES_USER: dw_admin
    POSTGRES_PASSWORD: dw1234
    POSTGRES_DB: labarca_dw
```

## Schemas

| Schema | Capa | Propósito |
|---|---|---|
| raw | Bronze | Datos tal como llegan desde Airbyte sin ninguna transformación |
| staging | Silver | Datos limpiados, renombrados y con tipos de datos correctos |
| marts | Gold | Dimensiones y tabla de hechos listos para Power BI |

## Schema raw

Contiene la tabla `ventas` replicada directamente desde MySQL por Airbyte. Los datos llegan con columnas adicionales de metadatos CDC como `_ab_cdc_cursor` y `_ab_cdc_deleted_at`.

```sql
SELECT COUNT(*) FROM raw.ventas;
-- 155,057 filas
```

## Schema staging

Contiene la vista `stg_ventas` que aplica limpieza básica sobre los datos raw. Es una vista (no una tabla) para evitar duplicar datos.

```sql
SELECT COUNT(*) FROM staging.stg_ventas;
-- 155,057 filas
```

## Schema marts

Contiene el esquema estrella final con la tabla de hechos y las dimensiones.

| Tabla | Tipo | Filas | Descripción |
|---|---|---|---|
| fact_ventas | Hecho | 155,057 | Transacciones con métricas de venta |
| dim_tiempo | Dimensión | 821 | Fechas únicas con atributos temporales |
| dim_producto | Dimensión | 27 | Productos con categoría y precio |
| dim_cliente | Dimensión | 1,400 | Clientes con tipo de cliente |
| dim_pedido | Dimensión | 269 | Combinaciones de tipo pedido, pago y caja |

## Esquema estrella

```
          dim_tiempo
              |
              | id_tiempo
              |
dim_cliente --+-- fact_ventas --+-- dim_producto
              |
              | id_pedido
              |
          dim_pedido
```

La tabla `fact_ventas` está en el centro con claves foráneas hacia cada dimensión. Cada fila de `fact_ventas` representa una transacción de venta.

## Usuario dbt

Se creó un usuario `dbt_user` con permisos sobre los tres schemas para que dbt pueda crear y modificar tablas:

```sql
CREATE USER dbt_user WITH PASSWORD 'dbt1234';
GRANT ALL PRIVILEGES ON DATABASE labarca_dw TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA raw TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA staging TO dbt_user;
GRANT ALL PRIVILEGES ON SCHEMA marts TO dbt_user;
```
