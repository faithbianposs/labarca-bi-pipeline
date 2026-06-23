# La Barca — Pipeline BI End-to-End

Documentación técnica del proyecto de Business Intelligence desarrollado para La Barca, una pollería peruana, como parte del curso de Business Intelligence de la Universidad Peruana Unión.

## Descripción del proyecto

La Barca es una pollería que genera registros de ventas de forma continua. El objetivo del proyecto fue construir un pipeline de datos completo que permita transformar esos registros transaccionales en información analítica útil para la toma de decisiones comerciales.

El pipeline cubre desde la fuente de datos original hasta un dashboard interactivo en Power BI, pasando por ingesta con CDC, almacenamiento en un Data Warehouse y transformación con dbt.

## Equipo

| Integrante | Rol principal |
|---|---|
| Ramos Arisapana Frank | Ingesta CDC, transformación dbt, modelo semántico, validación |
| Choquechambi Luque Wrangler | Base transaccional OLTP, carga de datos, esquema estrella |

**Curso:** Business Intelligence  
**Universidad:** Universidad Peruana Unión  
**Docente:** Abel Angel Sullon Macalupu

## Flujo del pipeline

```
CSV (155,057 registros de ventas)
    |
    v  Carga con Python
MySQL 8.0 — OLTP (labarca_oltp)
    |
    v  Airbyte CDC — Change Data Capture
PostgreSQL 16 — schema raw
    |
    v  dbt run
PostgreSQL 16 — schema staging
    |
    v  dbt run
PostgreSQL 16 — schema marts (DataMart)
    |
    v
Power BI Desktop — Dashboard interactivo
```

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| OLTP | MySQL 8.0 |
| Ingesta / CDC | Airbyte con binlog MySQL |
| Data Warehouse | PostgreSQL 16 |
| Transformación | dbt 1.12 |
| Visualización | Power BI Desktop |
| Infraestructura | Docker + Docker Compose |
| Lenguajes | Python 3.14, SQL |

## Resultados principales

- **155,057** registros procesados sin errores
- **4 tests dbt** pasados (PASS=4, ERROR=0)
- **Total ventas:** S/ 3,499,633
- **Ticket promedio:** S/ 22.57
- **Categoria líder:** Brasa con S/ 1,113,366
- **Crecimiento 2024 a 2025:** +10%

## Navegación

Usa el menú de la izquierda para revisar cada componente del pipeline en detalle:

- **Arquitectura** — diagrama y descripción del flujo completo
- **OLTP MySQL** — estructura de la base transaccional
- **Ingesta Airbyte CDC** — configuración del conector y sincronización
- **Data Warehouse** — schemas raw, staging y marts
- **Transformacion dbt** — modelos, tests y lineage
- **Dashboard Power BI** — páginas, medidas DAX y visuales
- **Validacion SQL** — conciliación de KPIs entre SQL y Power BI
