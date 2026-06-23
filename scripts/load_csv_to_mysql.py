"""
La Barca — Carga CSV → MySQL OLTP
Ejecutar: python scripts/load_csv_to_mysql.py
"""

import csv
import mysql.connector
from datetime import datetime
import os

# ── Configuración ──────────────────────────────────────────
CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "La-barca.csv")

DB_CONFIG = {
    "host":     "localhost",
    "port":     3307,          # puerto mapeado en docker-compose
    "user":     "labarca",
    "password": "labarca1234",
    "database": "labarca_oltp",
}

BATCH_SIZE = 1000
# ───────────────────────────────────────────────────────────

INSERT_SQL = """
INSERT INTO ventas (
    id_venta, fecha, hora, turno, caja,
    tipo_pedido, metodo_pago, cliente_nombre, tipo_cliente,
    producto, categoria, cantidad, precio_unitario,
    subtotal, total_venta, tiempo_preparacion,
    estado_pedido, tipo_dia, nivel_demanda,
    error_caja, diferencia_caja
) VALUES (
    %s, %s, %s, %s, %s,
    %s, %s, %s, %s,
    %s, %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s,
    %s, %s
) ON DUPLICATE KEY UPDATE
    updated_at = CURRENT_TIMESTAMP
"""


def parse_fecha(fecha_str: str):
    """Convierte DD/MM/YYYY → date."""
    try:
        return datetime.strptime(fecha_str.strip(), "%d/%m/%Y").date()
    except ValueError:
        return None


def parse_decimal(val: str):
    try:
        return float(val.strip()) if val.strip() else 0.0
    except ValueError:
        return 0.0


def parse_int(val: str):
    try:
        return int(val.strip()) if val.strip() else 0
    except ValueError:
        return 0


def load():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    batch = []
    total = 0
    errores = 0

    print(f"[INFO] Abriendo {CSV_PATH} ...")

    with open(CSV_PATH, encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)

        for row in reader:
            try:
                record = (
                    parse_int(row["id_venta"]),
                    parse_fecha(row["fecha"]),
                    row["hora"].strip(),
                    row["turno"].strip(),
                    row["caja"].strip(),
                    row["tipo_pedido"].strip(),
                    row["metodo_pago"].strip(),
                    row["cliente_nombre"].strip(),
                    row["tipo_cliente"].strip(),
                    row["producto"].strip(),
                    row["categoria"].strip(),
                    parse_int(row["cantidad"]),
                    parse_decimal(row["precio_unitario"]),
                    parse_decimal(row["subtotal"]),
                    parse_decimal(row["total_venta"]),
                    parse_int(row["tiempo_preparacion"]),
                    row["estado_pedido"].strip(),
                    row["tipo_dia"].strip(),
                    row["nivel_demanda"].strip(),
                    row["error_caja"].strip(),
                    parse_decimal(row["diferencia_caja"]),
                )
                batch.append(record)
            except Exception as e:
                errores += 1
                print(f"  [WARN] fila {total+1} ignorada: {e}")
                continue

            if len(batch) >= BATCH_SIZE:
                cursor.executemany(INSERT_SQL, batch)
                conn.commit()
                total += len(batch)
                print(f"  → {total:,} filas insertadas...")
                batch = []

    # último batch
    if batch:
        cursor.executemany(INSERT_SQL, batch)
        conn.commit()
        total += len(batch)

    cursor.close()
    conn.close()

    print(f"\n✅ Carga completada: {total:,} filas insertadas, {errores} errores.")


if __name__ == "__main__":
    load()
