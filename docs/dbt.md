# Transformación — dbt

## Descripción

dbt (data build tool) gestiona todas las transformaciones del Data Warehouse. Convierte los datos del schema `raw` en modelos limpios en `staging` y finalmente en el esquema estrella en `marts`.

## Instalación

```bash
pip install dbt-postgres
dbt deps
```

## Configuración — profiles.yml

```yaml
labarca_dw:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5433
      user: dbt_user
      password: dbt1234
      dbname: labarca_dw
      schema: staging
      threads: 4
```

## Modelos

### staging/stg_ventas.sql

Vista de limpieza sobre `raw.ventas`. Aplica tipado correcto, renombrado y filtros básicos.

```sql
SELECT
    CAST(id_venta AS INTEGER)         AS id_venta,
    fecha::DATE                        AS fecha,
    hora,
    TRIM(turno)                        AS turno,
    TRIM(producto)                     AS producto,
    CAST(total_venta AS NUMERIC(10,2)) AS total_venta,
    ...
FROM {{ source('raw', 'ventas') }}
WHERE id_venta IS NOT NULL
  AND fecha IS NOT NULL
```

### marts/dim_tiempo.sql

Dimensión temporal con una fila por fecha única.

```sql
SELECT DISTINCT
    TO_CHAR(fecha, 'YYYYMMDD')::INTEGER AS id_tiempo,
    fecha,
    EXTRACT(YEAR FROM fecha)::INTEGER   AS anio,
    EXTRACT(MONTH FROM fecha)::INTEGER  AS mes,
    TO_CHAR(fecha, 'TMMonth')           AS nombre_mes,
    EXTRACT(QUARTER FROM fecha)::INTEGER AS trimestre,
    EXTRACT(WEEK FROM fecha)::INTEGER   AS semana_anio
FROM {{ ref('stg_ventas') }}
```

### marts/dim_producto.sql

Dimensión de productos con 27 productos únicos.

```sql
SELECT DISTINCT
    md5(producto)    AS id_producto,
    producto,
    categoria,
    precio_unitario
FROM {{ ref('stg_ventas') }}
```

### marts/dim_cliente.sql

Dimensión de clientes con 1,400 clientes únicos.

```sql
SELECT DISTINCT
    md5(cliente_nombre) AS id_cliente,
    cliente_nombre,
    tipo_cliente
FROM {{ ref('stg_ventas') }}
```

### marts/dim_pedido.sql

Dimensión de pedidos con 269 combinaciones únicas.

```sql
SELECT DISTINCT
    md5(tipo_pedido || metodo_pago || caja) AS id_pedido,
    tipo_pedido,
    metodo_pago,
    caja,
    estado_pedido,
    nivel_demanda
FROM {{ ref('stg_ventas') }}
```

### marts/fact_ventas.sql

Tabla de hechos central con 155,057 filas y claves hacia todas las dimensiones.

```sql
SELECT
    id_venta,
    TO_CHAR(fecha, 'YYYYMMDD')::INTEGER         AS id_tiempo,
    md5(producto)                                AS id_producto,
    md5(cliente_nombre)                          AS id_cliente,
    md5(tipo_pedido || metodo_pago || caja)      AS id_pedido,
    cantidad,
    precio_unitario,
    subtotal,
    total_venta,
    tiempo_preparacion,
    diferencia_caja,
    CASE WHEN error_caja = 'Sí' THEN 1 ELSE 0 END AS tiene_error_caja
FROM {{ ref('stg_ventas') }}
```

## Ejecución

```bash
dbt run
```

Resultado:

```
1 of 6 OK  stg_ventas     CREATE VIEW   [staging]
2 of 6 OK  dim_cliente    SELECT 1400   [marts]
3 of 6 OK  dim_pedido     SELECT 269    [marts]
4 of 6 OK  dim_producto   SELECT 27     [marts]
5 of 6 OK  dim_tiempo     SELECT 821    [marts]
6 of 6 OK  fact_ventas    SELECT 155057 [marts]

PASS=6  ERROR=0
```

## Tests

```bash
dbt test
```

Resultado:

```
PASS source_not_null_raw_ventas_fecha
PASS source_not_null_raw_ventas_id_venta
PASS source_not_null_raw_ventas_total_venta
PASS source_unique_raw_ventas_id_venta

PASS=4  WARN=0  ERROR=0
```
