-- ============================================================
-- PROYECTO: Dashboard de Ventas y Logística
-- ARCHIVO:  01_crear_tablas.sql
-- AUTOR:    Michael Hans Evans — Data Analyst
-- MOTOR:    SQLite (compatible con PostgreSQL / SQL Server)
-- MODELO:   Snowflake Schema — 13 tablas — 3FN
-- DESCRIPCIÓN: DDL completo del modelo relacional. Define las
--              13 tablas con sus PKs, FKs y tipos de datos.
--              Las tablas se cargan desde el notebook Python 02.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- JERARQUÍA PRODUCTOS
-- ────────────────────────────────────────────────────────────

-- Nivel 1: Categorías (3 filas: Furniture, Office Supplies, Technology)
CREATE TABLE IF NOT EXISTS dim_categories (
    categories_key    INTEGER     PRIMARY KEY,
    Category          TEXT        NOT NULL
);

-- Nivel 2: Subcategorías (17 filas)
CREATE TABLE IF NOT EXISTS dim_sub_categories (
    sub_categories_key  INTEGER   PRIMARY KEY,
    "Sub-Category"      TEXT      NOT NULL
);

-- Nivel 3: Detalle del producto (1.862 filas — une Product con sus categorías)
CREATE TABLE IF NOT EXISTS dim_products_detail (
    "Product ID"        TEXT      PRIMARY KEY,
    categories_key      INTEGER   NOT NULL REFERENCES dim_categories(categories_key),
    sub_categories_key  INTEGER   NOT NULL REFERENCES dim_sub_categories(sub_categories_key)
);

-- Nivel 4: Producto completo (1.862 filas — nombre del producto)
CREATE TABLE IF NOT EXISTS dim_products (
    "Product ID"    TEXT    PRIMARY KEY REFERENCES dim_products_detail("Product ID"),
    "Product Name"  TEXT    NOT NULL
);

-- ────────────────────────────────────────────────────────────
-- JERARQUÍA GEOGRAFÍA
-- ────────────────────────────────────────────────────────────

-- Nivel 1: Regiones (4 filas: Central, East, South, West)
CREATE TABLE IF NOT EXISTS dim_geography_region (
    region_key  INTEGER   PRIMARY KEY,
    Region      TEXT      NOT NULL
);

-- Nivel 2: Estados (49 filas)
CREATE TABLE IF NOT EXISTS dim_geography_state (
    state_key   INTEGER   PRIMARY KEY,
    State       TEXT      NOT NULL
);

-- Nivel 3: Ciudades (531 filas)
CREATE TABLE IF NOT EXISTS dim_geography_city (
    city_key    INTEGER   PRIMARY KEY,
    City        TEXT      NOT NULL
);

-- Nivel 4: Geografía completa (632 filas — City+PostalCode como clave natural)
-- Nota: geography_key = City_PostalCode (resuelve duplicados de códigos postales)
CREATE TABLE IF NOT EXISTS dim_geography (
    geography_key   TEXT      PRIMARY KEY,
    "Postal Code"   INTEGER   NOT NULL,
    city_key        INTEGER   NOT NULL REFERENCES dim_geography_city(city_key),
    state_key       INTEGER   NOT NULL REFERENCES dim_geography_state(state_key),
    region_key      INTEGER   NOT NULL REFERENCES dim_geography_region(region_key)
);

-- ────────────────────────────────────────────────────────────
-- JERARQUÍA CLIENTES
-- ────────────────────────────────────────────────────────────

-- Nivel 1: Segmentos (3 filas: Consumer, Corporate, Home Office)
CREATE TABLE IF NOT EXISTS dim_customers_segment (
    segment_key INTEGER   PRIMARY KEY,
    Segment     TEXT      NOT NULL
);

-- Nivel 2: Clientes (793 filas)
CREATE TABLE IF NOT EXISTS dim_customers (
    "Customer ID"   TEXT    PRIMARY KEY,
    "Customer Name" TEXT    NOT NULL,
    segment_key     INTEGER NOT NULL REFERENCES dim_customers_segment(segment_key)
);

-- ────────────────────────────────────────────────────────────
-- DIMENSIÓN ENVÍOS
-- ────────────────────────────────────────────────────────────

-- 4 filas: First Class, Same Day, Second Class, Standard Class
CREATE TABLE IF NOT EXISTS dim_shipment (
    shipment_key    INTEGER PRIMARY KEY,
    "Ship Mode"     TEXT    NOT NULL
);

-- ────────────────────────────────────────────────────────────
-- DIMENSIÓN TIEMPO
-- ────────────────────────────────────────────────────────────

-- 5.009 filas (una por Order ID único)
-- Relacionada con fact_orders por Order ID (no por fecha — evita duplicados)
CREATE TABLE IF NOT EXISTS dim_time (
    "Order ID"      TEXT    PRIMARY KEY,
    "Order Date"    DATE    NOT NULL,
    "Ship Date"     DATE    NOT NULL,
    Order_Year      INTEGER NOT NULL,
    Order_Month     INTEGER NOT NULL,
    Order_Quarter   INTEGER NOT NULL
);

-- ────────────────────────────────────────────────────────────
-- TABLA DE HECHOS
-- ────────────────────────────────────────────────────────────

-- 9.993 filas — una por línea de orden (Order + Product)
-- PK compuesta: Order ID + Product ID + Índice (resuelve duplicados)
CREATE TABLE IF NOT EXISTS fact_orders (
    order_product_key   TEXT        PRIMARY KEY,
    "Order ID"          TEXT        NOT NULL REFERENCES dim_time("Order ID"),
    "Customer ID"       TEXT        NOT NULL REFERENCES dim_customers("Customer ID"),
    "Product ID"        TEXT        NOT NULL REFERENCES dim_products_detail("Product ID"),
    geography_key       TEXT        NOT NULL REFERENCES dim_geography(geography_key),
    shipment_key        INTEGER     NOT NULL REFERENCES dim_shipment(shipment_key),
    Indice              INTEGER     NOT NULL,
    Sales               REAL        NOT NULL,
    Quantity            INTEGER     NOT NULL,
    Discount            REAL        NOT NULL,
    Discount_pct        REAL        NOT NULL,
    Profit              REAL        NOT NULL,
    Profit_Margin_pct   REAL        NOT NULL,
    Shipping_Days       INTEGER     NOT NULL
);

-- ────────────────────────────────────────────────────────────
-- VERIFICACIÓN POST-CREACIÓN
-- ────────────────────────────────────────────────────────────
SELECT 
    name AS tabla,
    'creada' AS estado
FROM sqlite_master 
WHERE type = 'table' 
ORDER BY name;
