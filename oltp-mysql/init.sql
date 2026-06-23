-- ============================================
--  La Barca — OLTP MySQL
--  Tabla principal de ventas
-- ============================================

CREATE DATABASE IF NOT EXISTS labarca_oltp;
USE labarca_oltp;

-- Usuario con permisos para CDC (binlog replication)
CREATE USER IF NOT EXISTS 'airbyte_cdc'@'%' IDENTIFIED WITH mysql_native_password BY 'cdc1234';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'airbyte_cdc'@'%';
FLUSH PRIVILEGES;

-- Tabla principal
CREATE TABLE IF NOT EXISTS ventas (
    id_venta          INT            PRIMARY KEY,
    fecha             DATE           NOT NULL,
    hora              VARCHAR(10),
    turno             VARCHAR(20),
    caja              VARCHAR(20),
    tipo_pedido       VARCHAR(30),
    metodo_pago       VARCHAR(30),
    cliente_nombre    VARCHAR(100),
    tipo_cliente      VARCHAR(30),
    producto          VARCHAR(100),
    categoria         VARCHAR(50),
    cantidad          INT,
    precio_unitario   DECIMAL(10,2),
    subtotal          DECIMAL(10,2),
    total_venta       DECIMAL(10,2),
    tiempo_preparacion INT,
    estado_pedido     VARCHAR(30),
    tipo_dia          VARCHAR(20),
    nivel_demanda     VARCHAR(20),
    error_caja        VARCHAR(5),
    diferencia_caja   DECIMAL(10,2),
    -- columnas de auditoría para CDC
    created_at        TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
