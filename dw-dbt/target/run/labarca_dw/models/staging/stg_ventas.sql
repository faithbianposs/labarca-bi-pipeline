
  create view "labarca_dw"."staging_staging"."stg_ventas__dbt_tmp"
    
    
  as (
    -- models/staging/stg_ventas.sql
-- Vista de limpieza sobre el raw que llega de Airbyte



SELECT
    CAST(id_venta          AS INTEGER)          AS id_venta,
    fecha::DATE                AS fecha,
    hora,
    TRIM(turno)                                 AS turno,
    TRIM(caja)                                  AS caja,
    TRIM(tipo_pedido)                           AS tipo_pedido,
    TRIM(metodo_pago)                           AS metodo_pago,
    TRIM(cliente_nombre)                        AS cliente_nombre,
    TRIM(tipo_cliente)                          AS tipo_cliente,
    TRIM(producto)                              AS producto,
    TRIM(categoria)                             AS categoria,
    CAST(cantidad          AS INTEGER)          AS cantidad,
    CAST(precio_unitario   AS NUMERIC(10,2))    AS precio_unitario,
    CAST(subtotal          AS NUMERIC(10,2))    AS subtotal,
    CAST(total_venta       AS NUMERIC(10,2))    AS total_venta,
    CAST(tiempo_preparacion AS INTEGER)         AS tiempo_preparacion,
    TRIM(estado_pedido)                         AS estado_pedido,
    TRIM(tipo_dia)                              AS tipo_dia,
    TRIM(nivel_demanda)                         AS nivel_demanda,
    TRIM(error_caja)                            AS error_caja,
    CAST(diferencia_caja   AS NUMERIC(10,2))    AS diferencia_caja

FROM "labarca_dw"."raw"."ventas"

WHERE id_venta IS NOT NULL
  AND fecha    IS NOT NULL
  );