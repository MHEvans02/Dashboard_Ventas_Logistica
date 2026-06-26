# Documentación del Proyecto — Dashboard de Ventas y Logística

**Autor:** Michael Hans Evans — Data Analyst  
**Dataset:** Sample Superstore (Kaggle) | 2014–2017 | Mercado: Estados Unidos  
**Stack:** Python · SQL / SQLite · Power BI · Plotly Dash  
**Modelo:** Snowflake Schema en 3FN — 13 tablas — 11 relaciones

---

## 1. Introducción

Este proyecto abarca el ciclo completo de análisis de datos sobre el dataset Sample Superstore, que registra operaciones comerciales de una empresa de retail en Estados Unidos durante el período 2014–2017.

El objetivo principal es identificar patrones de rentabilidad, evaluar el impacto de los descuentos, analizar la performance por región, comprender el comportamiento logístico y de clientes, y detectar la estacionalidad de las ventas mediante técnicas de análisis exploratorio, modelado relacional, SQL y visualización interactiva.

**Herramientas utilizadas:** Python/pandas (EDA y limpieza), SQL/SQLite (análisis), Power BI (dashboard principal), Plotly Dash (dashboard alternativo), dbdiagram.io (modelo relacional), Miro (diagrama de flujo).

---

## 2. Descripción de los datos

| Atributo | Detalle |
|---|---|
| Fuente | Kaggle — Sample Superstore Dataset |
| Período | 01/01/2014 — 31/12/2017 |
| Registros originales | 9.994 filas × 21 columnas |
| Registros post-limpieza | 9.993 filas × 25 columnas |
| Eliminado | 1 fila duplicada exacta |
| Columnas eliminadas | Row ID (sin valor analítico), Country (solo United States) |
| Columnas agregadas | Discount_pct, Order_Year, Order_Month, Order_Quarter, Profit_Margin_pct, Shipping_Days |

### 2.1 Columnas originales

| Columna | Tipo | Descripción |
|---|---|---|
| Order ID | Texto | Identificador único de la orden |
| Order Date | Fecha | Fecha de la orden |
| Ship Date | Fecha | Fecha de envío |
| Ship Mode | Categórica | Modo de envío: Standard, Second, First, Same Day |
| Customer ID | Texto | Identificador único del cliente |
| Customer Name | Texto | Nombre del cliente |
| Segment | Categórica | Segmento: Consumer, Corporate, Home Office |
| City / State / Region | Texto | Ubicación geográfica |
| Postal Code | Numérico | Código postal |
| Product ID | Texto | Identificador único del producto |
| Category / Sub-Category | Categórica | Jerarquía de producto |
| Product Name | Texto | Nombre completo del producto |
| Sales | Decimal | Ventas en USD |
| Quantity | Entero | Cantidad de unidades |
| Discount | Decimal | Descuento aplicado (0 a 0.80) |
| Profit | Decimal | Ganancia en USD (puede ser negativa) |

---

## 3. Hipótesis planteadas

Se plantearon 6 hipótesis de negocio que guiaron el análisis SQL y la construcción del dashboard:

| # | Hipótesis | Dimensión analítica |
|---|---|---|
| H1 | No todas las categorías generan rentabilidad positiva. Existe al menos una subcategoría con pérdidas sistemáticas a pesar de tener volumen considerable. | Producto / Rentabilidad |
| H2 | Existe relación negativa entre el descuento aplicado y el profit generado. A partir de un umbral las ventas generan pérdidas. | Descuentos / Rentabilidad |
| H3 | Existe al menos una región con alto volumen de ventas pero baja rentabilidad, indicando ineficiencias comerciales. | Geografía / Rentabilidad |
| H4 | Standard Class concentra la mayoría de los pedidos. Corporate es el segmento que más utiliza envíos express. | Logística / Segmento |
| H5 | El 20% de los clientes genera el 80% de los ingresos. Existen clientes con alto volumen pero márgenes negativos. | Clientes / Rentabilidad |
| H6 | Las ventas tienen un patrón estacional consistente con pico en Q4 en todos los años del período. | Tiempo / Estacionalidad |

---

## 4. Herramientas tecnológicas

| Herramienta | Versión | Uso en el proyecto |
|---|---|---|
| Python / pandas | 3.9+ / 1.3+ | EDA, limpieza, modelado, validación cruzada |
| SQLite | 3.x | Base de datos del modelo relacional Snowflake |
| Power BI Desktop | 2024 | Dashboard principal — 6 páginas, 24 medidas DAX |
| Plotly Dash | 2.x | Dashboard alternativo en Python |
| Jupyter Notebook | — | Entorno de desarrollo Python para los 4 notebooks |
| dbdiagram.io | — | Diagrama interactivo del modelo relacional Snowflake |
| Miro | — | Diagrama de flujo del proceso end-to-end |
| GitHub | — | Control de versiones y publicación del proyecto |

---

## 5. Dataset

### 5.1 KPIs globales (validados en Python, SQL, Power BI y Dash)

| KPI | Valor |
|---|---|
| Total Sales | $2,296,919.49 |
| Total Profit | $286,409.08 |
| Profit Margin % | 12.47% |
| Total Customers | 793 |
| Total Registros | 9,993 |
| Avg Ticket | $229.85 |
| Avg Discount % | 15.62% |
| Órdenes con Pérdida | 1,870 (18.71%) |

### 5.2 Distribución por dimensión

| Dimensión | Valores |
|---|---|
| Categorías (3) | Furniture · Office Supplies · Technology |
| Subcategorías (17) | Tables, Bookcases, Chairs, Copiers, Phones, etc. |
| Regiones (4) | Central · East · South · West |
| Segmentos (3) | Consumer · Corporate · Home Office |
| Modos de envío (4) | Standard Class · Second Class · First Class · Same Day |
| Estados (49) | California, New York, Texas, etc. |
| Ciudades (531) | New York City, Los Angeles, Seattle, etc. |
| Productos únicos (1.862) | Sillas, copiadoras, lápices, estantes, etc. |

---

## 6. EDA y Limpieza de datos

El análisis exploratorio y la limpieza se realizaron íntegramente en Python/pandas, documentados en el notebook `01_eda_limpieza.ipynb`.

### 6.1 EDA — Python/pandas (Notebook 01)

- Carga del dataset original con encoding latin-1 (requerido por el CSV)
- Perfil del dataset: tipos de datos, valores únicos por columna, memoria ocupada
- Análisis de nulos: el dataset original no tiene valores nulos en ninguna columna
- Estadísticas descriptivas: mínimo, máximo, media, mediana y desviación estándar de Sales, Profit, Quantity, Discount
- Detección de outliers en Sales (máximo: $22,638) y Profit (mínimo: -$6,599)
- Análisis de correlaciones entre variables numéricas
- Distribuciones de categorías, regiones, segmentos y modos de envío

### 6.2 Transformaciones aplicadas

| Transformación | Detalle | Resultado |
|---|---|---|
| Eliminación de duplicados | 1 fila duplicada exacta detectada y eliminada | 9.994 → 9.993 filas |
| Tipos de datos | Order Date y Ship Date convertidos a datetime | Permite cálculos de fechas |
| Discount_pct | Discount × 100 | Legibilidad en visualizaciones (0.20 → 20%) |
| Order_Year | Extraído de Order Date con .dt.year | Análisis temporal por año |
| Order_Month | Extraído de Order Date con .dt.month | Análisis estacional mensual |
| Order_Quarter | Extraído de Order Date con .dt.quarter | Análisis estacional trimestral |
| Profit_Margin_pct | Profit / Sales × 100 | Métrica de rentabilidad directa |
| Shipping_Days | Ship Date − Order Date en días | Análisis de performance logística |
| Eliminación de Row ID | Sin valor analítico (índice secuencial) | Simplificación del dataset |
| Eliminación de Country | 100% United States — sin variabilidad | Sin pérdida de información |

---

## 7. Modelado Relacional

### 7.1 Tipo de modelo: Snowflake Schema en 3FN

Se eligió Snowflake Schema sobre Star Schema para demostrar el dominio de normalización relacional clásica. Las tres formas normales se aplicaron explícitamente:

- **1FN:** cada columna contiene un único valor atómico sin listas ni valores compuestos
- **2FN:** sin dependencias parciales — atributos no-clave dependen de la clave primaria completa
- **3FN:** dependencias transitivas eliminadas — City→State→Region y Product→Category/Sub-Category separadas en tablas propias

### 7.2 Decisiones de diseño

| Decisión | Justificación |
|---|---|
| geography_key = City_PostalCode | Resuelve ambigüedad: ciudades con mismo nombre en distintos estados (ej: Springfield, IL vs Springfield, MO) |
| order_product_key = Order + Product + Índice | Garantiza unicidad cuando el mismo producto aparece más de una vez en la misma orden |
| Claves subrogadas para jerarquías | categories_key, state_key, region_key, etc. — integers livianos para JOINs eficientes |
| Claves naturales para entidades | Customer ID, Product ID, Order ID — ya son únicos en el dataset y tienen significado de negocio |
| dim_time relacionada por Order ID | Cada Order ID tiene una sola fecha — evita duplicados que ocurrirían si se relacionara por Order Date |

### 7.3 Las 13 tablas del modelo

| Tabla | Tipo | Filas | Descripción |
|---|---|---|---|
| fact_orders | Hechos | 9,993 | Una fila por línea de orden (Order + Product). Contiene métricas y claves foráneas |
| dim_time | Dimensión | 5,009 | Fechas por Order ID único — Order Date, Ship Date, Year, Month, Quarter |
| dim_customers | Dimensión | 793 | Clientes únicos con FK a segmento |
| dim_customers_segment | Dimensión | 3 | Consumer, Corporate, Home Office |
| dim_geography | Dimensión | 632 | Ciudad + Código Postal como clave compuesta natural |
| dim_geography_city | Dimensión | 531 | 531 ciudades únicas |
| dim_geography_state | Dimensión | 49 | 49 estados únicos |
| dim_geography_region | Dimensión | 4 | Central, East, South, West |
| dim_products_detail | Dimensión | 1,862 | Vínculo entre Product ID y sus categorías |
| dim_products | Dimensión | 1,862 | Product ID + Product Name |
| dim_categories | Dimensión | 3 | Furniture, Office Supplies, Technology |
| dim_sub_categories | Dimensión | 17 | 17 subcategorías del catálogo |
| dim_shipment | Dimensión | 4 | Standard Class, Second Class, First Class, Same Day |

### 7.4 Relaciones (11 relaciones, todas * → 1 unidireccionales)

| Desde (tabla) | Columna | → | A (tabla) |
|---|---|---|---|
| fact_orders | Order ID | → | dim_time |
| fact_orders | Customer ID | → | dim_customers |
| fact_orders | Product ID | → | dim_products_detail |
| fact_orders | geography_key | → | dim_geography |
| fact_orders | shipment_key | → | dim_shipment |
| dim_customers | segment_key | → | dim_customers_segment |
| dim_geography | city_key | → | dim_geography_city |
| dim_geography | state_key | → | dim_geography_state |
| dim_geography | region_key | → | dim_geography_region |
| dim_products_detail | categories_key | → | dim_categories |
| dim_products_detail | sub_categories_key | → | dim_sub_categories |
| dim_products | Product ID | → | dim_products_detail |

---

## 8. Listado de tablas y columnas

### 8.1 fact_orders — Tabla de hechos

| Columna | Tipo | Rol |
|---|---|---|
| order_product_key | TEXT | PK — Order ID + Product ID + Índice |
| Order ID | TEXT | FK → dim_time |
| Customer ID | TEXT | FK → dim_customers |
| Product ID | TEXT | FK → dim_products_detail |
| geography_key | TEXT | FK → dim_geography |
| shipment_key | INTEGER | FK → dim_shipment |
| Indice | INTEGER | Diferenciador cuando mismo producto aparece más de una vez |
| Sales | REAL | Métrica — Ventas en USD |
| Quantity | INTEGER | Métrica — Unidades vendidas |
| Discount | REAL | Métrica — Descuento aplicado (0.0 a 0.8) |
| Discount_pct | REAL | Métrica calculada — Discount × 100 |
| Profit | REAL | Métrica — Ganancia en USD (puede ser negativa) |
| Profit_Margin_pct | REAL | Métrica calculada — Profit / Sales × 100 |
| Shipping_Days | INTEGER | Métrica calculada — Ship Date − Order Date |

### 8.2 Columnas por dimensión

| Tabla | Columnas (PK en negrita) |
|---|---|
| dim_time | **Order ID**, Order Date, Ship Date, Order_Year, Order_Month, Order_Quarter |
| dim_customers | **Customer ID**, Customer Name, segment_key (FK) |
| dim_customers_segment | **segment_key**, Segment |
| dim_geography | **geography_key**, Postal Code, city_key (FK), state_key (FK), region_key (FK) |
| dim_geography_city | **city_key**, City |
| dim_geography_state | **state_key**, State |
| dim_geography_region | **region_key**, Region |
| dim_products_detail | **Product ID**, categories_key (FK), sub_categories_key (FK) |
| dim_products | **Product ID** (FK), Product Name |
| dim_categories | **categories_key**, Category |
| dim_sub_categories | **sub_categories_key**, Sub-Category |
| dim_shipment | **shipment_key**, Ship Mode |

---

## 9. Análisis SQL

El análisis SQL se ejecutó sobre `superstore_model.db` (SQLite) y está organizado en 4 archivos. El notebook `03_analisis_sql.ipynb` documenta la ejecución y los resultados con validación cruzada contra Python/pandas.

| Archivo | Propósito | Contenido principal |
|---|---|---|
| 01_crear_tablas.sql | DDL | 13 CREATE TABLE con PKs, FKs y tipos de datos |
| 02_carga_datos.sql | ETL | Carga desde CSV con `.import` + validación de integridad referencial (5 checks) |
| 03_kpis_generales.sql | KPIs | 8 KPIs individuales + resumen consolidado + tendencia trimestral + KPIs por categoría |
| 04_hipotesis_analisis.sql | Análisis | 3–4 queries por hipótesis con JOINs multi-tabla, CTEs, WINDOW FUNCTIONS y CASE |

### 9.1 Técnicas SQL utilizadas

- **JOINs multi-tabla:** hasta 4 JOINs en una sola query (fact_orders → dim_products_detail → dim_categories → dim_sub_categories)
- **CTEs (Common Table Expressions):** análisis Pareto con `WITH customer_sales AS (...)`
- **Window Functions:** `SUM() OVER ()`, `COUNT() OVER (PARTITION BY)` para porcentajes
- **CASE expressions:** rangos de descuento, análisis condicional de profit
- **Agregaciones:** GROUP BY multi-columna, HAVING para filtros post-agrupación
- **Subqueries escalares:** `SELECT COUNT(*) FROM dim_customers` como referencia

---

## 10. Medidas calculadas (DAX — Power BI)

Se implementaron 24 medidas DAX en la tabla fact_orders del modelo Power BI:

| Medida | Fórmula DAX simplificada | Grupo |
|---|---|---|
| Total Sales | SUM(fact_orders[Sales]) | Base |
| Total Profit | SUM(fact_orders[Profit]) | Base |
| Profit Margin % | DIVIDE([Total Profit], [Total Sales]) | Base |
| Total Registros | COUNTROWS(fact_orders) | Base |
| Total Customers | DISTINCTCOUNT(fact_orders[Customer ID]) | Base |
| Total Orders | DISTINCTCOUNT(fact_orders[Order ID]) | Base |
| Avg Ticket | AVERAGEX(fact_orders, fact_orders[Sales]) | Base |
| Avg Discount % | AVERAGE(fact_orders[Discount_pct]) | Base |
| Avg Profit | AVERAGE(fact_orders[Profit]) | Descuentos |
| Avg Profit Sin Descuento | CALCULATE([Avg Profit], fact_orders[Discount]=0) | Descuentos |
| Avg Profit Con Descuento | CALCULATE([Avg Profit], fact_orders[Discount]>0) | Descuentos |
| Total Sales Sin Descuento | CALCULATE([Total Sales], fact_orders[Discount]=0) | Descuentos |
| Ordenes con Perdida | COUNTROWS(FILTER(fact_orders, fact_orders[Profit]<0)) | Pérdidas |
| Clientes con Perdida | CALCULATE(DISTINCTCOUNT(...), FILTER(...)) | Pérdidas |
| Pct Ordenes con Perdida | DIVIDE([Ordenes con Perdida], [Total Registros]) | Pérdidas |
| Pct Standard Class | CALCULATE([Total Registros], Ship Mode='Standard Class') / [Total Registros] | Logística |
| Sales Q1 | CALCULATE([Total Sales], dim_time[Order_Quarter]=1) | Estacional |
| Sales Q4 | CALCULATE([Total Sales], dim_time[Order_Quarter]=4) | Estacional |
| Pct Ventas Q4 | DIVIDE([Sales Q4], [Total Sales]) | Estacional |
| Profit Central | CALCULATE([Total Profit], Region='Central') | Regional |
| Profit West | CALCULATE([Total Profit], Region='West') | Regional |
| Profit Margin Central % | DIVIDE([Profit Central], CALCULATE([Total Sales], Region='Central')) | Regional |
| Profit Margin Furniture % | CALCULATE([Profit Margin %], Category='Furniture') | Categoría |
| Profit Margin Technology % | CALCULATE([Profit Margin %], Category='Technology') | Categoría |

---

## 11. Segmentaciones y filtros del dashboard

Los tres filtros están sincronizados en las 5 páginas analíticas (no en Portada) mediante Power BI Sync Slicers:

| Filtro | Tabla origen | Valores | Aplica en |
|---|---|---|---|
| Año | dim_time[Order_Year] | 2014, 2015, 2016, 2017 | 5 páginas analíticas |
| Categoría | dim_categories[Category] | Furniture, Office Supplies, Technology | 5 páginas analíticas |
| Segmento | dim_customers_segment[Segment] | Consumer, Corporate, Home Office | 5 páginas analíticas |

---

## 12. Visualización — Dashboard Power BI

El dashboard principal se construyó en Power BI Desktop con 6 páginas interactivas. Se implementó también un dashboard alternativo en Python usando Plotly Dash (`04_dashboard_plotly.ipynb`).

| Página | KPIs | Gráficos principales |
|---|---|---|
| Portada | 8 KPIs estáticos + navegación | Botones de navegación a las 5 páginas analíticas |
| Resumen Ejecutivo | 7 KPIs dinámicos | Sales/Profit por categoría, Profit Margin % por categoría, Tendencia trimestral (líneas doble eje) |
| Rentabilidad y Descuentos | 4 KPIs | Profit por subcategoría, Avg Profit por rango descuento, % órdenes pérdida por subcategoría, Impacto descuento por categoría |
| Performance Regional | 4 KPIs | Sales/Profit por región, Profit Margin % por región, Ranking de estados por Profit |
| Clientes y Logística | 4 KPIs | Top 10 clientes, Distribución Ship Mode (dona), Clientes con pérdida por segmento, Ship Mode por segmento |
| Estacionalidad | 4 KPIs | Tendencia anual/trimestral, Sales por trimestre, Sales por mes |

> El dashboard en Plotly Dash replica las 6 páginas e incorpora tres análisis extra no presentes en Power BI: scatter de cuadrantes por estado (Estrella / Riesgo / Potencial / Crítico), curva de Pareto de clientes (80/20) y heatmap de estacionalidad (Mes × Año).

---

## 13. Conclusiones

### H1 — Rentabilidad por categoría

| Categoría | Margin % | Observación |
|---|---|---|
| Technology | 17.40% | Mejor categoría — alta rentabilidad y volumen |
| Office Supplies | 17.04% | Sólida rentabilidad — mayor cantidad de órdenes |
| Furniture | 2.49% | Problema crítico — Tables (-8.56%) y Bookcases (-3.02%) generan pérdidas netas |

**CONFIRMADA** — Furniture destruye valor. Tables y Bookcases generan pérdidas sistemáticas. Se recomienda revisar la política de precios y descuentos en esta categoría.

### H2 — Impacto del descuento

| Rango descuento | Avg Profit | % Órdenes con pérdida |
|---|---|---|
| Sin descuento (0%) | +$66.90 | ~0% |
| Bajo (1–20%) | +$26.50 | Bajo |
| Medio (21–40%) | -$78.01 ← UMBRAL CRÍTICO | Alto |
| Alto (41–60%) | -$134.62 | Muy alto |
| Muy alto (61–80%) | -$98.35 | 100% |

**CONFIRMADA** — A partir del 21% de descuento el profit promedio es negativo. Descuentos superiores al 40% generan pérdidas en el 100% de los casos.

### H3 — Performance regional

| Región | Total Sales | Profit Margin % |
|---|---|---|
| West | $725,457.82 | 14.94% |
| East | $678,781.24 | 13.49% |
| Central | $501,239.89 | 7.92% ← PROBLEMA |
| South | $391,440.54 | 11.93% |

**CONFIRMADA** — Central es la 3ra región en ventas con el peor margen (7.92%) — casi la mitad del margen de West. Se recomienda análisis de estructura de costos en esta región.

### H4 — Logística y modo de envío

| Ship Mode | % Órdenes | Observación |
|---|---|---|
| Standard Class | 59.71% | Modo dominante en todos los segmentos |
| Second Class | 19.46% | Segunda opción más usada |
| First Class | 15.39% | Mayor uso en Corporate |
| Same Day | 5.43% | Nicho de urgencia |

**CONFIRMADA** — Standard Class concentra el 59.71% de todos los pedidos. Corporate utiliza más envíos express (First Class y Same Day) que Consumer y Home Office.

### H5 — Clientes más valiosos

| Cliente | Total Sales | Total Profit | Observación |
|---|---|---|---|
| Sean Miller | $25,043.05 | Negativo | Mayor comprador — genera pérdidas netas |
| Tamara Chand | $19,052.22 | Positivo | Alto valor con margen positivo |
| Raymond Buch | $15,117.34 | Positivo | Cliente rentable |

638 de 793 clientes (80.5%) tienen al menos una orden con pérdida neta — señal de política de descuentos mal calibrada.

**CONFIRMADA** — Existen clientes con alto volumen de compra y profit negativo. Sean Miller: mayor comprador ($25K) con pérdidas netas. La regla 80/20 requiere análisis individual de los top clientes.

### H6 — Estacionalidad

| Quarter | Total Sales | % Anual |
|---|---|---|
| Q1 | $359,681.58 | 15.67% |
| Q2 | $445,228.25 | 19.39% |
| Q3 | $613,932.11 | 26.73% |
| Q4 — PICO | $878,077.56 | 38.23% |

**CONFIRMADA** — Q4 concentra el 38.23% de las ventas anuales. El patrón es consistente en todos los años 2014–2017. Noviembre y Diciembre son los meses pico. La planificación logística e inventario debe anticipar este pico estacional.

### Recomendaciones de negocio

- **Revisar la política de descuentos:** establecer un tope del 20%, ya que por encima de ese umbral el profit es sistemáticamente negativo.
- **Analizar la viabilidad de las subcategorías Tables y Bookcases:** considerar ajuste de precios o descontinuación si los márgenes negativos son estructurales.
- **Investigar ineficiencias en la región Central:** el gap de margen vs West (7.92% vs 14.94%) sugiere problemas de costos operativos o pricing regional.
- **Implementar scoring de clientes:** identificar clientes como Sean Miller con alto volumen y profit negativo para renegociar condiciones comerciales.
- **Preparar la cadena logística para Q4:** el pico estacional del 38% requiere planificación anticipada de inventario y capacidad de envíos.
