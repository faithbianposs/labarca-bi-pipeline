# Dashboard — Power BI

## Descripción

El dashboard conecta directamente al schema `marts` de PostgreSQL y presenta tres páginas de análisis con medidas DAX, formato condicional y segmentadores interactivos.

## Conexión al DataMart

| Parámetro | Valor |
|---|---|
| Servidor | localhost:5433 |
| Base de datos | labarca_dw |
| Schema | staging_marts |
| Tablas | fact_ventas, dim_tiempo, dim_producto, dim_cliente, dim_pedido |

## Relaciones del modelo semántico

| Tabla dimensión | Tabla hecho | Campo | Cardinalidad |
|---|---|---|---|
| dim_tiempo | fact_ventas | id_tiempo | 1 a * |
| dim_producto | fact_ventas | id_producto | 1 a * |
| dim_cliente | fact_ventas | id_cliente | * a * |
| dim_pedido | fact_ventas | id_pedido | * a * |

## Medidas DAX

### Medidas base

```dax
Total Ventas = SUM(fact_ventas[total_venta])

Ticket Promedio = AVERAGE(fact_ventas[total_venta])

N° Transacciones = COUNTROWS(fact_ventas)

Errores Caja = SUM(fact_ventas[tiene_error_caja])
```

### Medidas de variación anual

```dax
Ventas Anio Previo =
CALCULATE(
    [Total Ventas],
    DATEADD(dim_tiempo[fecha], -1, YEAR)
)

Variacion vs Anio Previo = [Total Ventas] - [Ventas Anio Previo]

% Variacion vs Anio Previo =
DIVIDE([Variacion vs Anio Previo], [Ventas Anio Previo])
```

### Medidas KPI con iconos

```dax
KPI Var Ventas =
IF(
    [% Variacion vs Anio Previo] >= 0,
    UNICHAR(9650),
    UNICHAR(9660)
)

KPI Var Ventas Color =
IF(
    [% Variacion vs Anio Previo] >= 0,
    "Green",
    "Red"
)
```

## Páginas del dashboard

### Página 1 — Resumen

Vista ejecutiva con los KPIs principales y tendencia de ventas.

Visuales:
- 5 tarjetas KPI: Total Ventas, Ticket Promedio, N° Transacciones, Errores Caja, % Variacion vs Anio Previo
- Gráfico de barras: ventas por mes
- Gráfico de barras: ventas por categoría
- Gráfico de dona: ventas por tipo de cliente
- Gráfico de líneas: tendencia de ventas por fecha con línea de tendencia
- Segmentador: año

### Página 2 — KPI Variación

Análisis comparativo de ventas año vs año previo.

Visuales:
- Matriz KPI por año con: Total Ventas, Ventas Año Previo, Variación, % Variación, flecha KPI
- Gráfico de barras agrupadas: Total Ventas vs Ventas Año Previo por mes
- Segmentador: año

Formato condicional aplicado:
- Flechas coloreadas con `KPI Var Ventas Color`
- Porcentaje de variación en verde (positivo) o rojo (negativo)

### Página 3 — Categorías y Productos

Análisis de desempeño por categoría y producto.

Visuales:
- Matriz KPI por categoría con: Total Ventas, Ventas Año Previo, Variación, % Variación, flecha KPI
- Gráfico de barras: Top productos por ventas
- Segmentador: año
- Segmentador: categoría

## Carpetas de medidas

| Carpeta | Medidas |
|---|---|
| 01 Ventas Base | Total Ventas, Ticket Promedio, N° Transacciones, Errores Caja |
| 02 Variacion Anual | Ventas Anio Previo, Variacion vs Anio Previo, % Variacion vs Anio Previo, KPI Var Ventas, KPI Var Ventas Color |
