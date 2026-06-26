-- ============================================================
-- PROYECTO: Dashboard de Ventas y Logística
-- ARCHIVO:  03_kpis_generales.sql
-- AUTOR:    Michael Hans Evans — Data Analyst
-- INPUT:    superstore_model.db (13 tablas, Snowflake 3FN)
-- DESCRIPCIÓN: KPIs generales del dashboard. Cada query
--              reproduce exactamente un card del Power BI.
-- RESULTADOS ESPERADOS (validados contra Power BI):
--   Total Sales:       $2,296,919.49
--   Total Profit:      $286,409.08
--   Profit Margin %:   12.47%
--   Total Customers:   793
--   Total Registros:   9,993
--   Avg Ticket:        $229.85
--   Avg Discount %:    15.62%
--   Órdenes pérdida:   1,870
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- KPI 1: Total Sales
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(SUM(Sales), 2)    AS total_sales
FROM fact_orders;
-- Esperado: 2296919.49

-- ────────────────────────────────────────────────────────────
-- KPI 2: Total Profit
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(SUM(Profit), 2)   AS total_profit
FROM fact_orders;
-- Esperado: 286409.08

-- ────────────────────────────────────────────────────────────
-- KPI 3: Profit Margin %
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)   AS profit_margin_pct
FROM fact_orders;
-- Esperado: 12.47%

-- ────────────────────────────────────────────────────────────
-- KPI 4: Total Customers
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(*)    AS total_customers
FROM dim_customers;
-- Esperado: 793

-- ────────────────────────────────────────────────────────────
-- KPI 5: Total Registros (órdenes)
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(*)    AS total_registros
FROM fact_orders;
-- Esperado: 9993

-- ────────────────────────────────────────────────────────────
-- KPI 6: Avg Ticket (Sales promedio por orden-producto)
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(AVG(Sales), 2)    AS avg_ticket
FROM fact_orders;
-- Esperado: 229.85

-- ────────────────────────────────────────────────────────────
-- KPI 7: Avg Discount %
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(AVG(Discount) * 100, 2)   AS avg_discount_pct
FROM fact_orders;
-- Esperado: 15.62%

-- ────────────────────────────────────────────────────────────
-- KPI 8: Órdenes con Pérdida
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(*)    AS ordenes_con_perdida
FROM fact_orders
WHERE Profit < 0;
-- Esperado: 1870

-- ────────────────────────────────────────────────────────────
-- RESUMEN CONSOLIDADO — Todos los KPIs en una sola query
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(SUM(fo.Sales), 2)                         AS total_sales,
    ROUND(SUM(fo.Profit), 2)                        AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct,
    (SELECT COUNT(*) FROM dim_customers)            AS total_customers,
    COUNT(*)                                        AS total_registros,
    ROUND(AVG(fo.Sales), 2)                         AS avg_ticket,
    ROUND(AVG(fo.Discount) * 100, 2)               AS avg_discount_pct,
    SUM(CASE WHEN fo.Profit < 0 THEN 1 ELSE 0 END) AS ordenes_con_perdida
FROM fact_orders fo;

-- ────────────────────────────────────────────────────────────
-- KPIs POR CATEGORÍA (para gráfico Resumen Ejecutivo)
-- ────────────────────────────────────────────────────────────
SELECT
    dc.Category,
    ROUND(SUM(fo.Sales), 2)                         AS total_sales,
    ROUND(SUM(fo.Profit), 2)                        AS total_profit,
    ROUND(SUM(fo.Profit) / SUM(fo.Sales) * 100, 2) AS profit_margin_pct
FROM fact_orders fo
JOIN dim_products_detail dpd ON fo."Product ID" = dpd."Product ID"
JOIN dim_categories dc       ON dpd.categories_key = dc.categories_key
GROUP BY dc.Category
ORDER BY total_sales DESC;
-- Esperado: Technology > Furniture > Office Supplies en Sales
-- Pero Furniture tiene el menor margen (~2.49%)

-- ────────────────────────────────────────────────────────────
-- TENDENCIA TRIMESTRAL (para gráfico de líneas)
-- ────────────────────────────────────────────────────────────
SELECT
    dt.Order_Year,
    dt.Order_Quarter,
    ROUND(SUM(fo.Sales), 2)    AS total_sales,
    ROUND(SUM(fo.Profit), 2)   AS total_profit
FROM fact_orders fo
JOIN dim_time dt ON fo."Order ID" = dt."Order ID"
GROUP BY dt.Order_Year, dt.Order_Quarter
ORDER BY dt.Order_Year, dt.Order_Quarter;
