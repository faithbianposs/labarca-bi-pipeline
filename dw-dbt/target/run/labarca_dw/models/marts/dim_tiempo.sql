
  
    

  create  table "labarca_dw"."staging_marts"."dim_tiempo__dbt_tmp"
  
  
    as
  
  (
    -- models/marts/dim_tiempo.sql


SELECT DISTINCT
    TO_CHAR(fecha, 'YYYYMMDD')::INTEGER         AS id_tiempo,
    fecha,
    EXTRACT(YEAR  FROM fecha)::INTEGER          AS anio,
    EXTRACT(MONTH FROM fecha)::INTEGER          AS mes,
    TO_CHAR(fecha, 'TMMonth')                   AS nombre_mes,
    EXTRACT(DAY   FROM fecha)::INTEGER          AS dia,
    EXTRACT(DOW   FROM fecha)::INTEGER          AS dia_semana_num,
    TO_CHAR(fecha, 'TMDay')                     AS dia_semana_nombre,
    EXTRACT(QUARTER FROM fecha)::INTEGER        AS trimestre,
    EXTRACT(WEEK    FROM fecha)::INTEGER        AS semana_anio

FROM "labarca_dw"."staging_staging"."stg_ventas"
  );
  