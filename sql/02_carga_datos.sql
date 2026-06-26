-- ============================================================
-- PROYECTO: Dashboard de Ventas y Logística
-- ARCHIVO:  02_carga_datos.sql
-- AUTOR:    Michael Hans Evans — Data Analyst
-- MOTOR:    SQLite
-- DESCRIPCIÓN: Carga de datos desde archivos CSV exportados
--              por el notebook Python 02_modelado_relacional.
--              Ejecutar DESPUÉS de 01_crear_tablas.sql.
--              Las tablas se cargan en orden para respetar FKs.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- CONFIGURACIÓN INICIAL
-- ────────────────────────────────────────────────────────────
.mode csv
.headers on

-- ────────────────────────────────────────────────────────────
-- ORDEN DE CARGA (respetar dependencias FK)
-- ────────────────────────────────────────────────────────────

-- Paso 1: Dimensiones independientes (sin FK a otras tablas)
.import 'data/exports/dim_categories.csv'          dim_categories
.import 'data/exports/dim_sub_categories.csv'      dim_sub_categories
.import 'data/exports/dim_customers_segment.csv'   dim_customers_segment
.import 'data/exports/dim_geography_region.csv'    dim_geography_region
.import 'data/exports/dim_geography_state.csv'     dim_geography_state
.import 'data/exports/dim_geography_city.csv'      dim_geography_city
.import 'data/exports/dim_shipment.csv'            dim_shipment

-- Paso 2: Dimensiones con FK a las anteriores
.import 'data/exports/dim_products_detail.csv'     dim_products_detail
.import 'data/exports/dim_products.csv'            dim_products
.import 'data/exports/dim_geography.csv'           dim_geography
.import 'data/exports/dim_customers.csv'           dim_customers
.import 'data/exports/dim_time.csv'                dim_time

-- Paso 3: Tabla de hechos (depende de todas las anteriores)
.import 'data/exports/fact_orders.csv'             fact_orders

-- ────────────────────────────────────────────────────────────
-- VERIFICACIÓN DE CARGA
-- ────────────────────────────────────────────────────────────
SELECT 'dim_categories'       AS tabla, COUNT(*) AS filas, '3 esperadas'    AS nota FROM dim_categories
UNION ALL
SELECT 'dim_sub_categories',         COUNT(*), '17 esperadas'   FROM dim_sub_categories
UNION ALL
SELECT 'dim_customers_segment',      COUNT(*), '3 esperadas'    FROM dim_customers_segment
UNION ALL
SELECT 'dim_customers',              COUNT(*), '793 esperadas'  FROM dim_customers
UNION ALL
SELECT 'dim_geography_region',       COUNT(*), '4 esperadas'    FROM dim_geography_region
UNION ALL
SELECT 'dim_geography_state',        COUNT(*), '49 esperadas'   FROM dim_geography_state
UNION ALL
SELECT 'dim_geography_city',         COUNT(*), '531 esperadas'  FROM dim_geography_city
UNION ALL
SELECT 'dim_geography',              COUNT(*), '632 esperadas'  FROM dim_geography
UNION ALL
SELECT 'dim_products_detail',        COUNT(*), '1862 esperadas' FROM dim_products_detail
UNION ALL
SELECT 'dim_products',               COUNT(*), '1862 esperadas' FROM dim_products
UNION ALL
SELECT 'dim_shipment',               COUNT(*), '4 esperadas'    FROM dim_shipment
UNION ALL
SELECT 'dim_time',                   COUNT(*), '5009 esperadas' FROM dim_time
UNION ALL
SELECT 'fact_orders',                COUNT(*), '9993 esperadas' FROM fact_orders;

-- ────────────────────────────────────────────────────────────
-- VALIDACIÓN DE INTEGRIDAD REFERENCIAL
-- ────────────────────────────────────────────────────────────

-- FK: fact_orders → dim_customers (ninguna orden sin cliente)
SELECT 
    'fact_orders → dim_customers' AS relacion,
    COUNT(*) AS registros_huerfanos
FROM fact_orders fo
LEFT JOIN dim_customers dc ON fo."Customer ID" = dc."Customer ID"
WHERE dc."Customer ID" IS NULL;

-- FK: fact_orders → dim_products_detail
SELECT 
    'fact_orders → dim_products_detail' AS relacion,
    COUNT(*) AS registros_huerfanos
FROM fact_orders fo
LEFT JOIN dim_products_detail dpd ON fo."Product ID" = dpd."Product ID"
WHERE dpd."Product ID" IS NULL;

-- FK: fact_orders → dim_geography
SELECT 
    'fact_orders → dim_geography' AS relacion,
    COUNT(*) AS registros_huerfanos
FROM fact_orders fo
LEFT JOIN dim_geography dg ON fo.geography_key = dg.geography_key
WHERE dg.geography_key IS NULL;

-- FK: fact_orders → dim_time
SELECT 
    'fact_orders → dim_time' AS relacion,
    COUNT(*) AS registros_huerfanos
FROM fact_orders fo
LEFT JOIN dim_time dt ON fo."Order ID" = dt."Order ID"
WHERE dt."Order ID" IS NULL;

-- FK: fact_orders → dim_shipment
SELECT 
    'fact_orders → dim_shipment' AS relacion,
    COUNT(*) AS registros_huerfanos
FROM fact_orders fo
LEFT JOIN dim_shipment ds ON fo.shipment_key = ds.shipment_key
WHERE ds.shipment_key IS NULL;
