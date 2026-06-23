-- models/marts/fact_ventas.sql
{{ config(materialized='table', schema='marts') }}

SELECT
    id_venta,
    TO_CHAR(fecha, 'YYYYMMDD')::INTEGER                              AS id_tiempo,
    md5(producto)                                                     AS id_producto,
    md5(cliente_nombre)                                               AS id_cliente,
    md5(tipo_pedido || metodo_pago || caja)                          AS id_pedido,
    hora,
    turno,
    tipo_dia,
    cantidad,
    precio_unitario,
    subtotal,
    total_venta,
    tiempo_preparacion,
    diferencia_caja,
    CASE WHEN error_caja = 'Sí' THEN 1 ELSE 0 END                   AS tiene_error_caja

FROM {{ ref('stg_ventas') }}