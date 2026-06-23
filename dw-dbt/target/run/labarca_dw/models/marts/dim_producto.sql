
  
    

  create  table "labarca_dw"."staging_marts"."dim_producto__dbt_tmp"
  
  
    as
  
  (
    -- models/marts/dim_producto.sql


SELECT DISTINCT
    md5(cast(coalesce(cast(producto as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))   AS id_producto,
    producto,
    categoria,
    precio_unitario

FROM "labarca_dw"."staging_staging"."stg_ventas"
  );
  