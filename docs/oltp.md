# OLTP — MySQL

## Descripción

La base transaccional del proyecto usa MySQL 8.0 corriendo en un contenedor Docker. Contiene la tabla principal `ventas` con los registros operacionales de La Barca.

## Configuración del contenedor

```yaml
labarca-oltp-mysql:
  image: mysql:8.0
  container_name: labarca-oltp-mysql
  ports:
    - "3307:3306"
  environment:
    MYSQL_ROOT_PASSWORD: root1234
    MYSQL_DATABASE: labarca_oltp
    MYSQL_USER: labarca
    MYSQL_PASSWORD: labarca1234
```

El binlog está activado para soportar CDC con Airbyte:

```
--server-id=1
--log-bin=mysql-bin
--binlog-format=ROW
--binlog-row-image=FULL
```

## Estructura de la tabla ventas

```sql
CREATE TABLE IF NOT EXISTS ventas (
    id_venta            INT            PRIMARY KEY,
    fecha               DATE           NOT NULL,
    hora                VARCHAR(10),
    turno               VARCHAR(20),
    caja                VARCHAR(20),
    tipo_pedido         VARCHAR(30),
    metodo_pago         VARCHAR(30),
    cliente_nombre      VARCHAR(100),
    tipo_cliente        VARCHAR(30),
    producto            VARCHAR(100),
    categoria           VARCHAR(50),
    cantidad            INT,
    precio_unitario     DECIMAL(10,2),
    subtotal            DECIMAL(10,2),
    total_venta         DECIMAL(10,2),
    tiempo_preparacion  INT,
    estado_pedido       VARCHAR(30),
    tipo_dia            VARCHAR(20),
    nivel_demanda       VARCHAR(20),
    error_caja          VARCHAR(5),
    diferencia_caja     DECIMAL(10,2),
    created_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Usuario CDC para Airbyte

Se creó un usuario dedicado con permisos de replicación para que Airbyte pueda leer el binlog:

```sql
CREATE USER IF NOT EXISTS 'airbyte_cdc'@'%' 
    IDENTIFIED WITH mysql_native_password BY 'cdc1234';

GRANT SELECT, RELOAD, SHOW DATABASES, 
      REPLICATION SLAVE, REPLICATION CLIENT 
      ON *.* TO 'airbyte_cdc'@'%';

FLUSH PRIVILEGES;
```

## Carga inicial del CSV

El script `scripts/load_csv_to_mysql.py` carga el dataset fuente en batches de 1,000 filas:

```python
BATCH_SIZE = 1000

with open(CSV_PATH, encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        batch.append(record)
        if len(batch) >= BATCH_SIZE:
            cursor.executemany(INSERT_SQL, batch)
            conn.commit()
            batch = []
```

**Resultado de la carga:**

```
✅ Carga completada: 155,057 filas insertadas, 0 errores.
```

## Verificación

```sql
SELECT COUNT(*) FROM labarca_oltp.ventas;
-- Resultado: 155,057
```

## Campos principales

| Campo | Tipo | Descripción |
|---|---|---|
| id_venta | INT | Clave primaria de la transacción |
| fecha | DATE | Fecha de la venta |
| turno | VARCHAR | Turno del día (mañana, tarde, noche) |
| producto | VARCHAR | Nombre del producto vendido |
| categoria | VARCHAR | Categoría del producto |
| total_venta | DECIMAL | Monto total de la venta |
| metodo_pago | VARCHAR | Forma de pago usada |
| estado_pedido | VARCHAR | Estado del pedido |
| error_caja | VARCHAR | Indica si hubo error en caja |
