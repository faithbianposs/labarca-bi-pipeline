
  
    

  create  table "labarca_dw"."staging_marts"."dim_cliente__dbt_tmp"
  
  
    as
  
  (
    -- models/marts/dim_cliente.sql


SELECT DISTINCT
    md5(cast(coalesce(cast(cliente_nombre as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))  AS id_cliente,
    cliente_nombre,
    tipo_cliente

FROM "labarca_dw"."staging_staging"."stg_ventas"
  );
  