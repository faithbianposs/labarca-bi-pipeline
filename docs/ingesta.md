# Ingesta — Airbyte CDC

## Descripción

La ingesta de datos usa Airbyte con modo CDC (Change Data Capture) activado. Airbyte lee el binlog de MySQL y replica los cambios hacia el schema `raw` de PostgreSQL de forma incremental.

## Instalación de Airbyte

Airbyte se instala con `abctl`, la herramienta de línea de comandos oficial:

```bash
abctl local install
```

Esto levanta Airbyte sobre un cluster Kubernetes local (kind). La interfaz web queda disponible en `http://localhost:8000`.

## Configuración del Source — MySQL CDC

| Campo | Valor |
|---|---|
| Host | host.docker.internal |
| Puerto | 3307 |
| Base de datos | labarca_oltp |
| Usuario | airbyte_cdc |
| Contraseña | cdc1234 |
| Método de replicación | Read Changes using Change Data Capture (CDC) |
| JDBC URL Params | serverTimezone=America/Lima |
| Encryption | preferred |

## Configuración del Destination — PostgreSQL

| Campo | Valor |
|---|---|
| Host | host.docker.internal |
| Puerto | 5433 |
| Base de datos | labarca_dw |
| Schema | raw |
| Usuario | dbt_user |
| Contraseña | dbt1234 |
| SSL Mode | disable |

## Configuración de la conexión

| Parámetro | Valor |
|---|---|
| Nombre | labarca-mysql-to-postgres-cdc |
| Schedule | Manual |
| Destination Namespace | Destination-defined (raw) |
| Sync mode | Incremental — Append + Deduped |
| Cursor | _ab_cdc_cursor |
| Primary key | id_venta |

## Resultado del sync

El primer sync cargó las 155,057 filas de la tabla `ventas` hacia `raw.ventas` en PostgreSQL:

```
Sync succeeded
155,057 records loaded
```

## Verificación en PostgreSQL

```sql
SELECT COUNT(*) FROM raw.ventas;
-- Resultado: 155,057
```

## CDC — Cómo funciona

El CDC con Airbyte y MySQL funciona así:

1. Airbyte se conecta al binlog de MySQL usando el usuario `airbyte_cdc`
2. El primer sync hace un snapshot completo de la tabla
3. Los syncs siguientes solo capturan los cambios (INSERT, UPDATE, DELETE) registrados en el binlog
4. Los cambios llegan a PostgreSQL con metadatos adicionales como `_ab_cdc_cursor` y `_ab_cdc_deleted_at`

Esto permite mantener el Data Warehouse sincronizado con el OLTP sin recargar toda la tabla en cada ejecución.
