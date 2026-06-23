-- models/marts/dim_pedido.sql


SELECT DISTINCT
    md5(cast(coalesce(cast(tipo_pedido as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(metodo_pago as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(caja as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) AS id_pedido,
    tipo_pedido,
    metodo_pago,
    caja,
    estado_pedido,
    nivel_demanda

FROM "labarca_dw"."staging_staging"."stg_ventas"