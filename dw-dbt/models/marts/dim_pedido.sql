-- models/marts/dim_pedido.sql
{{ config(materialized='table', schema='marts') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['tipo_pedido', 'metodo_pago', 'caja']) }} AS id_pedido,
    tipo_pedido,
    metodo_pago,
    caja,
    estado_pedido,
    nivel_demanda

FROM {{ ref('stg_ventas') }}
