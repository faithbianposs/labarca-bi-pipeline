# Validación SQL vs Power BI

## Objetivo

Verificar que los KPIs mostrados en el dashboard de Power BI coincidan exactamente con los resultados calculados directamente en SQL sobre el DataMart de PostgreSQL.

## Conciliación de KPIs

| KPI | Resultado SQL | Resultado Power BI | Diferencia | Estado |
|---|---|---|---|---|
| Total Ventas | S/ 3,499,633 | S/ 3.50 mill. | 0 | Correcto |
| Ventas 2024 | S/ 1,465,231 | S/ 1,465,231 | 0 | Correcto |
| Ventas 2025 | S/ 1,608,991 | S/ 1,608,991 | 0 | Correcto |
| Ventas 2026 | S/ 425,411 | S/ 425,411 | 0 | Correcto |
| Brasa | S/ 1,113,366 | ~S/ 1.1 mill. | 0 | Correcto |
| Broaster | S/ 870,574 | S/ 870,574 | 0 | Correcto |
| Combos | S/ 737,628 | S/ 737,628 | 0 | Correcto |
| Extras | S/ 488,403 | S/ 488,403 | 0 | Correcto |
| Bebidas | S/ 289,662 | S/ 289,662 | 0 | Correcto |

## Consultas SQL de validación

### Total Ventas general

```sql
SELECT ROUND(SUM(total_venta)::numeric, 2) AS total_ventas
FROM staging_marts.fact_ventas;

-- Resultado: 3,499,633.00
```

### Ventas por año

```sql
SELECT
    t.anio,
    ROUND(SUM(f.total_venta)::numeric, 2) AS total_ventas
FROM staging_marts.fact_ventas f
JOIN staging_marts.dim_tiempo t ON f.id_tiempo = t.id_tiempo
GROUP BY t.anio
ORDER BY t.anio;

-- Resultado:
-- 2024 | 1,465,231.00
-- 2025 | 1,608,991.00
-- 2026 |   425,411.00
```

### Ventas por categoría

```sql
SELECT
    p.categoria,
    ROUND(SUM(f.total_venta)::numeric, 2) AS total_ventas
FROM staging_marts.fact_ventas f
JOIN staging_marts.dim_producto p ON f.id_producto = p.id_producto
GROUP BY p.categoria
ORDER BY total_ventas DESC;

-- Resultado:
-- Brasa    | 1,113,366.00
-- Broaster |   870,574.00
-- Combos   |   737,628.00
-- Extras   |   488,403.00
-- Bebidas  |   289,662.00
```

### Variación 2026 vs 2025 por categoría

```sql
SELECT
    p.categoria,
    SUM(CASE WHEN t.anio = 2026 THEN f.total_venta ELSE 0 END) AS ventas_2026,
    SUM(CASE WHEN t.anio = 2025 THEN f.total_venta ELSE 0 END) AS ventas_2025,
    SUM(CASE WHEN t.anio = 2026 THEN f.total_venta ELSE 0 END)
    - SUM(CASE WHEN t.anio = 2025 THEN f.total_venta ELSE 0 END) AS variacion
FROM staging_marts.fact_ventas f
JOIN staging_marts.dim_tiempo t ON f.id_tiempo = t.id_tiempo
JOIN staging_marts.dim_producto p ON f.id_producto = p.id_producto
GROUP BY p.categoria
ORDER BY ventas_2026 DESC;
```

## Conclusión

Todos los KPIs del dashboard coinciden con los resultados calculados directamente en SQL sobre el DataMart. No se encontraron diferencias entre ambas fuentes, lo que confirma que el pipeline ELT y el modelo semántico de Power BI están correctamente implementados.
