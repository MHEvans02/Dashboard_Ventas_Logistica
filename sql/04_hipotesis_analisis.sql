-- ============================================================
-- PROYECTO: Dashboard de Ventas y Logística
-- ARCHIVO:  04_hipotesis_analisis.sql
-- AUTOR:    Michael Hans Evans — Data Analyst
-- INPUT:    superstore_model.db (13 tablas, Snowflake 3FN)
-- DESCRIPCIÓN: Análisis de las 6 hipótesis del proyecto.
--              Cada sección responde una hipótesis con sus
--              queries SQL y los resultados esperados validados
--              contra el dashboard Power BI.
-- ============================================================

-- ════════════════════════════════════════════════════════════
-- H1 — RENTABILIDAD POR CATEGORÍA
-- Hipótesis: No todas las categorías generan rentabilidad
-- positiva y existe al menos una subcategoría con pérdidas
-- sistemáticas a pesar de tener volumen considerable.
-- ════════════════════════════════════════════════════════════

-- H1.1: Profit Margin % por Categoría
SELECT
    dc.Category,
    ROUND(SUM(fo.Sales), 2)                         AS total_sales,
    ROUND(SUM(fo.Profit), 2)                        AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct,
    SUM(CASE WHEN fo.Profit < 0 THEN 1 ELSE 0 END) AS ordenes_con_perdida
FROM fact_orders fo
JOIN dim_products_detail dpd ON fo."Product ID" = dpd."Product ID"
JOIN dim_categories dc       ON dpd.categories_key = dc.categories_key
GROUP BY dc.Category
ORDER BY profit_margin_pct DESC;
-- RESULTADO ESPERADO:
--   Technology:     17.40% margen
--   Office Supplies: 17.04% margen
--   Furniture:        2.49% margen ← PROBLEMA

-- H1.2: Profit por Subcategoría (Top positivos y negativos)
SELECT
    dsc."Sub-Category",
    dc.Category,
    ROUND(SUM(fo.Sales), 2)                         AS total_sales,
    ROUND(SUM(fo.Profit), 2)                        AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct,
    COUNT(*)                                        AS total_ordenes,
    SUM(CASE WHEN fo.Profit < 0 THEN 1 ELSE 0 END) AS ordenes_perdida,
    ROUND(SUM(CASE WHEN fo.Profit < 0 THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS pct_ordenes_perdida
FROM fact_orders fo
JOIN dim_products_detail dpd ON fo."Product ID" = dpd."Product ID"
JOIN dim_categories dc       ON dpd.categories_key = dc.categories_key
JOIN dim_sub_categories dsc  ON dpd.sub_categories_key = dsc.sub_categories_key
GROUP BY dsc."Sub-Category", dc.Category
ORDER BY profit_margin_pct ASC;
-- RESULTADO ESPERADO (peores):
--   Tables:    -8.56% margen (pérdida sistemática)
--   Bookcases: -3.02% margen (pérdida sistemática)
--   Supplies:  -2.55% margen

-- H1.3: CONCLUSIÓN H1
--  CONFIRMADA: Furniture tiene margen de solo 2.49%.
-- Tables y Bookcases generan pérdidas netas a pesar de tener ventas.


-- ════════════════════════════════════════════════════════════
-- H2 — IMPACTO DEL DESCUENTO EN LA RENTABILIDAD
-- Hipótesis: Existe relación negativa entre descuento y profit.
-- A partir de cierto umbral las ventas generan pérdidas.
-- ════════════════════════════════════════════════════════════

-- H2.1: Avg Profit por rango de descuento
SELECT
    CASE
        WHEN Discount = 0          THEN '0% — Sin descuento'
        WHEN Discount <= 0.20      THEN '1% — 20%'
        WHEN Discount <= 0.40      THEN '21% — 40%'
        WHEN Discount <= 0.60      THEN '41% — 60%'
        ELSE                            '61% — 80%'
    END AS rango_descuento,
    COUNT(*)                            AS total_ordenes,
    ROUND(AVG(Profit), 2)               AS avg_profit,
    ROUND(AVG(Sales), 2)                AS avg_sales,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS margin_pct,
    SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) AS ordenes_perdida,
    ROUND(SUM(CASE WHEN Profit < 0 THEN 1.0 ELSE 0 END)/COUNT(*)*100,2) AS pct_perdida
FROM fact_orders
GROUP BY rango_descuento
ORDER BY MIN(Discount);
-- RESULTADO ESPERADO:
--   0%:      Avg Profit positivo
--   1-20%:   Avg Profit positivo
--   21-40%:  Avg Profit NEGATIVO ← umbral crítico
--   41-60%:  Avg Profit muy negativo
--   61-80%:  Avg Profit muy negativo

-- H2.2: Impacto del descuento por Categoría
SELECT
    dc.Category,
    ROUND(AVG(CASE WHEN fo.Discount = 0 THEN fo.Profit END), 2)    AS avg_profit_sin_descuento,
    ROUND(AVG(CASE WHEN fo.Discount > 0 THEN fo.Profit END), 2)    AS avg_profit_con_descuento,
    ROUND(AVG(CASE WHEN fo.Discount > 0.40 THEN fo.Profit END), 2) AS avg_profit_descuento_mayor_40
FROM fact_orders fo
JOIN dim_products_detail dpd ON fo."Product ID" = dpd."Product ID"
JOIN dim_categories dc       ON dpd.categories_key = dc.categories_key
GROUP BY dc.Category
ORDER BY dc.Category;

-- H2.3: CONCLUSIÓN H2
--   CONFIRMADA: A partir del 21% de descuento el profit es negativo.
-- El 100% de las órdenes con descuento >40% generan pérdidas.


-- ════════════════════════════════════════════════════════════
-- H3 — PERFORMANCE REGIONAL
-- Hipótesis: Existe al menos una región con alto volumen de
-- ventas pero baja rentabilidad (ineficiencias comerciales).
-- ════════════════════════════════════════════════════════════

-- H3.1: Sales y Profit Margin % por Región
SELECT
    dgr.Region,
    ROUND(SUM(fo.Sales), 2)                         AS total_sales,
    ROUND(SUM(fo.Profit), 2)                        AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct,
    COUNT(*)                                        AS total_ordenes
FROM fact_orders fo
JOIN dim_geography dg        ON fo.geography_key = dg.geography_key
JOIN dim_geography_region dgr ON dg.region_key = dgr.region_key
GROUP BY dgr.Region
ORDER BY profit_margin_pct DESC;
-- RESULTADO ESPERADO:
--   West:    14.94% margen
--   East:    13.49% margen
--   South:   11.93% margen
--   Central:  7.92% margen ← PEOR margen

-- H3.2: Ranking de Estados por Profit (Top 7 y Bottom 5)
SELECT
    dgs.State,
    dgr.Region,
    ROUND(SUM(fo.Sales), 2)   AS total_sales,
    ROUND(SUM(fo.Profit), 2)  AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct
FROM fact_orders fo
JOIN dim_geography dg         ON fo.geography_key = dg.geography_key
JOIN dim_geography_state dgs  ON dg.state_key = dgs.state_key
JOIN dim_geography_region dgr ON dg.region_key = dgr.region_key
GROUP BY dgs.State, dgr.Region
ORDER BY total_profit DESC
LIMIT 10;
-- RESULTADO ESPERADO Top: California, New York, Washington

-- H3.3: Estados con pérdida neta en región Central
SELECT
    dgs.State,
    ROUND(SUM(fo.Sales), 2)  AS total_sales,
    ROUND(SUM(fo.Profit), 2) AS total_profit
FROM fact_orders fo
JOIN dim_geography dg         ON fo.geography_key = dg.geography_key
JOIN dim_geography_state dgs  ON dg.state_key = dgs.state_key
JOIN dim_geography_region dgr ON dg.region_key = dgr.region_key
WHERE dgr.Region = 'Central'
GROUP BY dgs.State
ORDER BY total_profit ASC;

-- H3.4: CONCLUSIÓN H3
--   CONFIRMADA: Central tiene el peor margen (7.92%) siendo la
-- tercera región en volumen de ventas — ineficiencia comercial confirmada.


-- ════════════════════════════════════════════════════════════
-- H4 — LOGÍSTICA Y MODO DE ENVÍO
-- Hipótesis: Standard Class concentra la mayoría de pedidos.
-- Corporate es el segmento que más usa envíos express.
-- ════════════════════════════════════════════════════════════

-- H4.1: Distribución de pedidos por Ship Mode
SELECT
    ds."Ship Mode",
    COUNT(*)                                                    AS total_ordenes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)        AS pct_ordenes,
    ROUND(SUM(fo.Sales), 2)                                    AS total_sales,
    ROUND(AVG(fo.Shipping_Days), 1)                            AS avg_shipping_days
FROM fact_orders fo
JOIN dim_shipment ds ON fo.shipment_key = ds.shipment_key
GROUP BY ds."Ship Mode"
ORDER BY total_ordenes DESC;
-- RESULTADO ESPERADO:
--   Standard Class: 59.71%
--   Second Class:   19.46%
--   First Class:    15.39%
--   Same Day:        5.43%

-- H4.2: Ship Mode por Segmento (cross-tab)
SELECT
    dcs.Segment,
    ds."Ship Mode",
    COUNT(*)                                                   AS total_ordenes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY dcs.Segment), 2) AS pct_en_segmento
FROM fact_orders fo
JOIN dim_customers dc    ON fo."Customer ID" = dc."Customer ID"
JOIN dim_customers_segment dcs ON dc.segment_key = dcs.segment_key
JOIN dim_shipment ds     ON fo.shipment_key = ds.shipment_key
GROUP BY dcs.Segment, ds."Ship Mode"
ORDER BY dcs.Segment, total_ordenes DESC;

-- H4.3: Avg Shipping Days por Ship Mode
SELECT
    ds."Ship Mode",
    ROUND(AVG(fo.Shipping_Days), 2) AS avg_shipping_days,
    MIN(fo.Shipping_Days)           AS min_dias,
    MAX(fo.Shipping_Days)           AS max_dias
FROM fact_orders fo
JOIN dim_shipment ds ON fo.shipment_key = ds.shipment_key
GROUP BY ds."Ship Mode"
ORDER BY avg_shipping_days ASC;

-- H4.4: CONCLUSIÓN H4
--   CONFIRMADA: Standard Class concentra 59.71% de los pedidos.
-- Se verifica la distribución por segmento en H4.2.


-- ════════════════════════════════════════════════════════════
-- H5 — CLIENTES MÁS VALIOSOS
-- Hipótesis: El 20% de los clientes genera el 80% de los
-- ingresos. Existen clientes con alto volumen y margen bajo.
-- ════════════════════════════════════════════════════════════

-- H5.1: Top 10 clientes por Sales con su Profit
SELECT
    dc."Customer Name",
    dcs.Segment,
    ROUND(SUM(fo.Sales), 2)                         AS total_sales,
    ROUND(SUM(fo.Profit), 2)                        AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct,
    COUNT(*)                                        AS total_ordenes
FROM fact_orders fo
JOIN dim_customers dc          ON fo."Customer ID" = dc."Customer ID"
JOIN dim_customers_segment dcs ON dc.segment_key = dcs.segment_key
GROUP BY dc."Customer ID", dc."Customer Name", dcs.Segment
ORDER BY total_sales DESC
LIMIT 10;
-- RESULTADO ESPERADO:
--   Sean Miller:   $25,043 en Sales (pero con pérdidas netas = -$1,980)
--   Tamara Chand:  $19,052
--   Raymond Buch:  $15,117

-- H5.2: Análisis Pareto — acumulado por % de clientes
WITH customer_sales AS (
    SELECT
        dc."Customer ID",
        SUM(fo.Sales) AS total_sales
    FROM fact_orders fo
    JOIN dim_customers dc ON fo."Customer ID" = dc."Customer ID"
    GROUP BY dc."Customer ID"
    ORDER BY total_sales DESC
),
running_totals AS (
    SELECT
        "Customer ID",
        total_sales,
        SUM(total_sales) OVER (ORDER BY total_sales DESC) AS sales_acumulado,
        (SELECT SUM(total_sales) FROM customer_sales)     AS sales_total,
        ROW_NUMBER() OVER (ORDER BY total_sales DESC)     AS ranking
    FROM customer_sales
)
SELECT
    ranking,
    ROUND(ranking * 100.0 / (SELECT COUNT(*) FROM customer_sales), 1) AS pct_clientes,
    ROUND(sales_acumulado / sales_total * 100, 1)                      AS pct_sales_acumulado
FROM running_totals
WHERE ranking IN (10, 20, 50, 80, 100, 150, 200, 300, 400, 500, 600, 793);
-- VERIFICA si el 20% de clientes genera ~80% de ventas

-- H5.3: Clientes con pérdida neta
SELECT
    dc."Customer Name",
    dcs.Segment,
    ROUND(SUM(fo.Sales), 2)  AS total_sales,
    ROUND(SUM(fo.Profit), 2) AS total_profit,
    COUNT(*)                 AS total_ordenes
FROM fact_orders fo
JOIN dim_customers dc          ON fo."Customer ID" = dc."Customer ID"
JOIN dim_customers_segment dcs ON dc.segment_key = dcs.segment_key
GROUP BY dc."Customer ID", dc."Customer Name", dcs.Segment
HAVING SUM(fo.Profit) < 0
ORDER BY total_profit ASC
LIMIT 10;
-- RESULTADO ESPERADO: Sean Miller con -$1,980 de profit neto

-- H5.4: CONCLUSIÓN H5
--   CONFIRMADA: Existen clientes con alto volumen y profit negativo.
-- Sean Miller: mayor comprador ($25K) pero genera pérdidas netas.


-- ════════════════════════════════════════════════════════════
-- H6 — ESTACIONALIDAD DE LAS VENTAS
-- Hipótesis: Las ventas no se distribuyen uniformemente.
-- Existe un patrón estacional consistente (pico en Q4).
-- ════════════════════════════════════════════════════════════

-- H6.1: Sales por Quarter (acumulado 2014-2017)
SELECT
    dt.Order_Quarter,
    ROUND(SUM(fo.Sales), 2)                                       AS total_sales,
    ROUND(SUM(fo.Sales) * 100.0 / SUM(SUM(fo.Sales)) OVER (), 2) AS pct_total
FROM fact_orders fo
JOIN dim_time dt ON fo."Order ID" = dt."Order ID"
GROUP BY dt.Order_Quarter
ORDER BY dt.Order_Quarter;
-- RESULTADO ESPERADO:
--   Q1: $359,682 (15.7%)
--   Q2: $445,228 (19.4%)
--   Q3: $613,932 (26.7%)
--   Q4: $878,078 (38.2%) ← PICO CONSISTENTE

-- H6.2: Tendencia por Año y Quarter (verifica consistencia del patrón)
SELECT
    dt.Order_Year,
    dt.Order_Quarter,
    ROUND(SUM(fo.Sales), 2)   AS total_sales,
    ROUND(SUM(fo.Profit), 2)  AS total_profit
FROM fact_orders fo
JOIN dim_time dt ON fo."Order ID" = dt."Order ID"
GROUP BY dt.Order_Year, dt.Order_Quarter
ORDER BY dt.Order_Year, dt.Order_Quarter;
-- VERIFICA que Q4 es el mayor en cada año de 2014 a 2017

-- H6.3: Sales por Mes (estacionalidad mensual)
SELECT
    dt.Order_Month,
    ROUND(SUM(fo.Sales), 2)                                       AS total_sales,
    ROUND(SUM(fo.Sales) * 100.0 / SUM(SUM(fo.Sales)) OVER (), 2) AS pct_total
FROM fact_orders fo
JOIN dim_time dt ON fo."Order ID" = dt."Order ID"
GROUP BY dt.Order_Month
ORDER BY dt.Order_Month;
-- RESULTADO ESPERADO: Noviembre y Diciembre son los picos mensuales

-- H6.4: Comparación Q4 vs Q1 por año
SELECT
    dt.Order_Year,
    ROUND(SUM(CASE WHEN dt.Order_Quarter = 4 THEN fo.Sales ELSE 0 END), 2) AS sales_q4,
    ROUND(SUM(CASE WHEN dt.Order_Quarter = 1 THEN fo.Sales ELSE 0 END), 2) AS sales_q1,
    ROUND(
        SUM(CASE WHEN dt.Order_Quarter = 4 THEN fo.Sales ELSE 0 END) /
        NULLIF(SUM(CASE WHEN dt.Order_Quarter = 1 THEN fo.Sales ELSE 0 END), 0),
    2) AS ratio_q4_vs_q1
FROM fact_orders fo
JOIN dim_time dt ON fo."Order ID" = dt."Order ID"
GROUP BY dt.Order_Year
ORDER BY dt.Order_Year;
-- Q4 es entre 2x y 3x mayor que Q1 en cada año

-- H6.5: CONCLUSIÓN H6
--   CONFIRMADA: Q4 concentra el 38.23% de las ventas anuales.
-- El patrón es consistente en todos los años 2014-2017.
-- Noviembre y Diciembre son los meses pico (temporada Holiday).
