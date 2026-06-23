# La Barca — Pipeline BI End-to-End

Solución de Business Intelligence para una pollería peruana, construida con pipeline ELT completo desde la fuente transaccional hasta el dashboard interactivo.

## Equipo

| Integrante | Componentes trabajados |
|---|---|
| Ramos Arisapana Frank | Ingesta CDC, transformación dbt, modelo semántico Power BI, validación SQL |
| Choquechambi Luque Wrangler | Base transaccional OLTP, carga de datos, esquema estrella DataMart |

**Curso:** Business Intelligence  
**Universidad:** Universidad Peruana Unión  
**Docente:** Abel Angel Sullon Macalupu

---

## Arquitectura

```
MySQL 8.0 (OLTP) — labarca_oltp.ventas
    |
    v  Airbyte CDC (Change Data Capture — binlog MySQL)
PostgreSQL 16 (Data Warehouse) — schema: raw
    |
    v  dbt run
schema: staging — stg_ventas (limpieza, tipado, renombrado)
    |
    v  dbt run
schema: marts — fact_ventas + dim_tiempo + dim_producto + dim_cliente + dim_pedido
    |
    v
Power BI Desktop — Dashboard interactivo (3 páginas)
```

---

## Stack tecnológico

| Componente | Herramienta / Tecnología |
|---|---|
| OLTP | MySQL 8.0 |
| Ingesta / CDC | Airbyte (CDC con binlog MySQL) |
| Data Warehouse | PostgreSQL 16 |
| Transformación | dbt 1.12 con dbt-postgres |
| Visualización | Power BI Desktop |
| Infraestructura | Docker + Docker Compose |
| Lenguajes | Python 3.14, SQL |

---

## Estructura del proyecto

```
labarca-completo/
├── docker-compose.yml              # Levanta MySQL y PostgreSQL en Docker
├── La-barca.csv                    # Dataset fuente (155,057 registros de ventas)
├── oltp-mysql/
│   └── init.sql                    # Crea tabla ventas y usuario CDC para Airbyte
├── dw-pg/
│   └── init.sql                    # Crea schemas raw, staging y marts en PostgreSQL
├── dw-dbt/
│   ├── dbt_project.yml             # Configuración principal de dbt
│   ├── profiles.yml                # Conexión a PostgreSQL
│   ├── packages.yml                # Dependencias dbt
│   └── models/
│       ├── staging/
│       │   ├── sources.yml         # Define fuente raw.ventas
│       │   └── stg_ventas.sql      # Vista de limpieza y tipado
│       └── marts/
│           ├── dim_tiempo.sql      # Dimensión temporal (821 fechas únicas)
│           ├── dim_producto.sql    # Dimensión producto (27 productos)
│           ├── dim_cliente.sql     # Dimensión cliente (1,400 clientes)
│           ├── dim_pedido.sql      # Dimensión pedido (269 combinaciones)
│           └── fact_ventas.sql     # Tabla de hechos central (155,057 filas)
├── scripts/
│   └── load_csv_to_mysql.py        # Carga el CSV a MySQL en batches de 1,000
└── powerbi/
    └── LaBarca_BI_Dashboard.pbix   # Dashboard con 3 páginas
```

---

## Cómo reproducir el proyecto

### Requisitos previos
- Docker Desktop instalado y corriendo
- Python 3.x instalado
- Power BI Desktop instalado
- Airbyte (abctl) instalado

### Paso 1 — Levantar los contenedores
```bash
docker-compose up -d
```
Esto levanta MySQL en el puerto 3307 y PostgreSQL en el puerto 5433.

### Paso 2 — Cargar el CSV a MySQL
```bash
pip install mysql-connector-python
python scripts/load_csv_to_mysql.py
```
Carga 155,057 filas con 0 errores en la tabla labarca_oltp.ventas.

### Paso 3 — Configurar Airbyte CDC
```bash
abctl local install
```
- Abrir http://localhost:8000
- Source: MySQL — host.docker.internal:3307 — usuario airbyte_cdc — modo CDC (binlog)
- Destination: PostgreSQL — host.docker.internal:5433 — schema raw
- Hacer Sync Now — los datos llegan a raw.ventas

### Paso 4 — Ejecutar dbt
```bash
cd dw-dbt
pip install dbt-postgres
dbt deps
dbt run
dbt test
```

### Paso 5 — Conectar Power BI
- Servidor: localhost:5433
- Base de datos: labarca_dw
- Schema: staging_marts
- Tablas: fact_ventas, dim_tiempo, dim_producto, dim_cliente, dim_pedido

---

## DataMart — Esquema Estrella

| Tabla | Tipo | Filas | Descripción |
|---|---|---|---|
| fact_ventas | Hecho | 155,057 | Transacciones de venta con métricas |
| dim_tiempo | Dimensión | 821 | Fechas con atributos temporales |
| dim_producto | Dimensión | 27 | Productos con categoría y precio |
| dim_cliente | Dimensión | 1,400 | Clientes con tipo de cliente |
| dim_pedido | Dimensión | 269 | Combinaciones de tipo pedido, pago y caja |

---

## Validación SQL vs Power BI

| KPI | Resultado SQL | Resultado Power BI | Estado |
|---|---|---|---|
| Total Ventas | S/ 3,499,633 | S/ 3.50 mill. | Correcto |
| Ventas 2024 | S/ 1,465,231 | S/ 1,465,231 | Correcto |
| Ventas 2025 | S/ 1,608,991 | S/ 1,608,991 | Correcto |
| Ventas 2026 | S/ 425,411 | S/ 425,411 | Correcto |
| Brasa | S/ 1,113,366 | ~S/ 1.1 mill. | Correcto |

---

## KPIs principales del dashboard

- Total Ventas: S/ 3,499,633
- Ticket Promedio: S/ 22.57
- Número de transacciones: 155,057
- Categoria con mayor venta: Brasa (S/ 1,113,366)
- Crecimiento anual 2024 a 2025: +10%
- Crecimiento anual 2025 a 2026: +10% (año parcial)

---

## Resultados dbt test

```
PASS source_not_null_raw_ventas_fecha
PASS source_not_null_raw_ventas_id_venta
PASS source_not_null_raw_ventas_total_venta
PASS source_unique_raw_ventas_id_venta

PASS=4  WARN=0  ERROR=0  TOTAL=4
```
