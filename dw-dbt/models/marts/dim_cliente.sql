-- models/marts/dim_cliente.sql
{{ config(materialized='table', schema='marts') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['cliente_nombre']) }}  AS id_cliente,
    cliente_nombre,
    tipo_cliente

FROM {{ ref('stg_ventas') }}
