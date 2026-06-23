-- models/marts/dim_producto.sql
{{ config(materialized='table', schema='marts') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['producto']) }}   AS id_producto,
    producto,
    categoria,
    precio_unitario

FROM {{ ref('stg_ventas') }}
