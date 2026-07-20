# Dashboard de Ventas y Logística — Superstore

**Autor:** Michael Hans Evans  
**Dataset:** Sample Superstore (Kaggle) | 2014–2017  
**Stack:** Python · SQL · Power BI · Plotly Dash  
**Tipo de modelo:** Snowflake Schema en 3FN — 14 tablas

---

## Descripción del proyecto

Análisis completo del ciclo de ventas de una empresa de retail en Estados Unidos. El proyecto abarca desde la exploración y limpieza del dataset crudo hasta la construcción de un dashboard interactivo en Power BI, pasando por modelado relacional, análisis SQL y validación de hipótesis de negocio.

El objetivo es identificar patrones de rentabilidad, impacto de descuentos, performance regional, comportamiento logístico, valor de clientes y estacionalidad de las ventas a partir de datos reales de 4 años (2014–2017).

---

## Estructura del proyecto

```
1.Dashboard_Ventas_Logistica/
├── data/
│   ├── superstore_dataset_original.csv   # Dataset crudo (9.994 filas, 21 cols)
│   └── superstore_clean.csv              # Dataset limpio (9.993 filas, 25 cols)
├── notebooks/
│   ├── 01_eda_limpieza.ipynb             # Exploración y limpieza (Python/pandas)
│   ├── 02_modelado_relacional.ipynb      # Construcción del modelo Snowflake
│   ├── 03_analisis_sql.ipynb             # Análisis SQL de las 6 hipótesis
│   └── 04_dashboard_plotly.ipynb         # Dashboard en Plotly Dash
├── sql/
│   ├── 01_crear_tablas.sql               # DDL — 13 tablas con PKs y FKs
│   ├── 02_carga_datos.sql                # Carga de datos a SQLite
│   ├── 03_kpis_generales.sql             # KPIs del dashboard
│   └── 04_hipotesis_analisis.sql         # Queries de las 6 hipótesis
├── database/
│   └── superstore_model.db               # Base SQLite con 13 tablas
├── powerbi/
│   ├── dashboard-ventas-logistica.pbix   # Dashboard Power BI (6 páginas)
│   └── dashboard-ventas-logistica.pdf    # Exportación en PDF
├── docs/
│   ├── dbdiagram_modelo_relacional.pdf   # Diagrama del modelo relacional
│   ├── miro_diagrama_flujo.pdf           # Diagrama de flujo del proceso
│   └── miro_diagrama_flujo.jpg
├── assets/
│   ├── 01_ventas_analisis.png
│   ├── 02_zonas_analisis.png
│   └── 03_logistica_analisis.png
└── README.md
```

---

## Flujo del proceso

```
Fuente de datos (CSV, 9.994 filas, 21 cols)
        │
        ▼
Python/pandas ──► EDA: perfil, estadísticas, outliers, correlaciones
        │
        ▼
Limpieza ──► superstore_clean.csv (9.993 filas, 25 cols)
        │
        ▼
Modelado relacional ──► Snowflake 3FN (13 tablas) ──► superstore_model.db
        │
        ├── SQLite ──► Análisis SQL de 6 hipótesis
        └── Python ──► Validación cruzada
        │
        ▼
Dashboard ──► Power BI (6 páginas) + Plotly Dash
```

---

## Dataset

| Atributo | Detalle |
|---|---|
| **Fuente** | Kaggle — Sample Superstore Dataset |
| **Período** | 2014 – 2017 |
| **Registros originales** | 9.994 filas × 21 columnas |
| **Registros post-limpieza** | 9.993 filas × 25 columnas |
| **Eliminado en limpieza** | 1 fila duplicada exacta |
| **Columnas agregadas** | `Discount_pct`, `Order_Year`, `Order_Month`, `Order_Quarter`, `Profit_Margin_pct`, `Shipping_Days` |

### KPIs globales

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

---

## EDA y Limpieza

El EDA y la limpieza se realizaron íntegramente en Python/pandas (`01_eda_limpieza.ipynb`):

- Perfil del dataset: tipos de datos, valores únicos, nulos
- Estadísticas descriptivas por columna numérica (Sales, Profit, Discount, Quantity)
- Detección de outliers en ventas y profit
- Correlaciones entre variables numéricas
- Distribuciones de categorías, regiones, segmentos y modos de envío

### Transformaciones aplicadas

| Transformación | Detalle |
|---|---|
| Eliminación de duplicados | 1 fila eliminada → 9.993 filas finales |
| Tipos de datos | `Order Date` y `Ship Date` → datetime |
| `Discount_pct` | `Discount × 100` para legibilidad en visualizaciones |
| `Order_Year`, `Order_Month`, `Order_Quarter` | Extraídos de `Order Date` |
| `Profit_Margin_pct` | `Profit / Sales × 100` |
| `Shipping_Days` | `Ship Date − Order Date` en días |
| Columnas eliminadas | `Row ID` (sin valor analítico), `Country` (solo "United States") |

---

## Modelado Relacional

### Tipo: Snowflake Schema en 3FN

Se eligió Snowflake sobre Star Schema para demostrar el dominio de normalización relacional clásica. Las tres formas normales fueron aplicadas explícitamente:

- **1FN:** cada columna contiene un único valor atómico
- **2FN:** sin dependencias parciales sobre claves compuestas
- **3FN:** dependencias transitivas eliminadas — City→State→Region y Product→Category/Sub-Category separadas en tablas propias

### Decisiones de diseño

| Decisión | Justificación |
|---|---|
| `geography_key = City_PostalCode` | Resuelve ambigüedad de ciudades con mismo nombre en distintos estados |
| `order_product_key = Order + Product + Índice` | Garantiza unicidad cuando el mismo producto aparece más de una vez en una orden |
| Claves subrogadas para jerarquías | `categories_key`, `state_key`, etc. — integers para JOINs eficientes |
| Claves naturales para entidades | `Customer ID`, `Product ID`, `Order ID` — ya son únicos en el dataset |

### 13 tablas del modelo

| Tabla | Tipo | Filas | Descripción |
|---|---|---|---|
| `fact_orders` | Hechos | 9,993 | Una fila por línea de orden (Order + Product) |
| `dim_time` | Dimensión | 5,009 | Fechas por Order ID único |
| `dim_customers` | Dimensión | 793 | Clientes únicos |
| `dim_customers_segment` | Dimensión | 3 | Consumer, Corporate, Home Office |
| `dim_geography` | Dimensión | 632 | City + Postal Code como clave |
| `dim_geography_city` | Dimensión | 531 | Ciudades |
| `dim_geography_state` | Dimensión | 49 | Estados |
| `dim_geography_region` | Dimensión | 4 | Central, East, South, West |
| `dim_products_detail` | Dimensión | 1,862 | Vínculo Product→Category/Sub-Category |
| `dim_products` | Dimensión | 1,862 | Nombre del producto |
| `dim_categories` | Dimensión | 3 | Furniture, Office Supplies, Technology |
| `dim_sub_categories` | Dimensión | 17 | 17 subcategorías |
| `dim_shipment` | Dimensión | 4 | Modos de envío |

### Relaciones (11 relaciones, todas `* → 1` unidireccionales)

```
fact_orders ──► dim_time            (Order ID)
fact_orders ──► dim_customers       (Customer ID)
fact_orders ──► dim_products_detail (Product ID)
fact_orders ──► dim_geography       (geography_key)
fact_orders ──► dim_shipment        (shipment_key)

dim_customers       ──► dim_customers_segment (segment_key)
dim_geography       ──► dim_geography_city    (city_key)
dim_geography       ──► dim_geography_state   (state_key)
dim_geography       ──► dim_geography_region  (region_key)
dim_products_detail ──► dim_categories        (categories_key)
dim_products_detail ──► dim_sub_categories    (sub_categories_key)
dim_products        ──► dim_products_detail   (Product ID)
```

---

## Análisis SQL

El análisis SQL se ejecuta sobre `superstore_model.db` usando SQLite y está organizado en 4 archivos:

| Archivo | Propósito | Contenido |
|---|---|---|
| `01_crear_tablas.sql` | DDL | 13 CREATE TABLE con PKs, FKs y tipos |
| `02_carga_datos.sql` | ETL | `.import` desde CSV + validación de integridad referencial |
| `03_kpis_generales.sql` | KPIs | 8 KPIs + tendencia trimestral + KPIs por categoría |
| `04_hipotesis_analisis.sql` | Análisis | 3-4 queries por hipótesis, con JOINs multi-tabla y CTEs |

---

## Hipótesis y Resultados

### H1 — Rentabilidad por categoría — CONFIRMADA

> Suponemos que no todas las categorías generan rentabilidad positiva y existe al menos una subcategoría con pérdidas sistemáticas a pesar de tener volumen considerable.

| Categoría | Margin % |
|---|---|
| Technology | 17.40% |
| Office Supplies | 17.04% |
| **Furniture** | **2.49%** |

Subcategorías con pérdidas netas: **Tables (-8.56%)**, **Bookcases (-3.02%)**, **Supplies (-2.55%)**

### H2 — Impacto del descuento en la rentabilidad — CONFIRMADA

> Suponemos que a partir de un umbral de descuento las ventas generan pérdidas sistemáticas.

| Rango descuento | Avg Profit |
|---|---|
| Sin descuento (0%) | +$66.90 |
| Bajo (1–20%) | +$26.50 |
| **Medio (21–40%)** | **-$78.01** ← umbral crítico |
| Alto (41–60%) | -$134.62 |
| Muy alto (61–80%) | -$98.35 |

A partir del 21% el profit es negativo. Con más del 40% el 100% de las órdenes generan pérdidas.

### H3 — Performance regional — CONFIRMADA

> Suponemos que existe al menos una región con alto volumen pero baja rentabilidad.

| Región | Margin % |
|---|---|
| West | 14.94% |
| East | 13.49% |
| South | 11.93% |
| **Central** | **7.92%** |

Central es la 3ra región en volumen de ventas pero tiene el peor margen — casi la mitad del margen de West.

### H4 — Logística y modo de envío — CONFIRMADA

> Suponemos que Standard Class concentra la mayoría de los pedidos.

| Ship Mode | % Órdenes |
|---|---|
| **Standard Class** | **59.71%** |
| Second Class | 19.46% |
| First Class | 15.39% |
| Same Day | 5.43% |

### H5 — Clientes más valiosos — CONFIRMADA

> Suponemos que existen clientes con alto volumen de compra pero margen muy bajo o negativo.

| Cliente | Total Sales | Profit |
|---|---|---|
| **Sean Miller** | **$25,043** | **Negativo** |
| Tamara Chand | $19,052 | Positivo |
| Raymond Buch | $15,117 | Positivo |

638 de 793 clientes (80.5%) tienen al menos una orden con pérdida neta.

### H6 — Estacionalidad de las ventas — CONFIRMADA

> Suponemos que las ventas tienen un patrón estacional consistente con pico en Q4.

| Quarter | Sales | % Anual |
|---|---|---|
| Q1 | $359,682 | 15.67% |
| Q2 | $445,228 | 19.39% |
| Q3 | $613,932 | 26.73% |
| **Q4** | **$878,078** | **38.23%** |

Patrón consistente en todos los años 2014–2017. Noviembre y Diciembre son los meses pico.

---

## Dashboard Power BI

### 6 páginas del dashboard

| Página | Descripción |
|---|---|
| **Portada** | 8 KPIs estáticos + navegación entre páginas |
| **Resumen Ejecutivo** | Sales/Profit por categoría, Profit Margin %, tendencia trimestral |
| **Rentabilidad y Descuentos** | Profit por subcategoría, impacto del descuento, órdenes con pérdida |
| **Performance Regional** | Sales/Profit por región, Profit Margin % por región, ranking de estados |
| **Clientes y Logística** | Top 10 clientes, distribución Ship Mode, análisis por segmento |
| **Estacionalidad** | Tendencia anual/trimestral, Sales por trimestre y por mes |

### Medidas DAX implementadas (24)

```
Métricas base:          Total Sales, Total Profit, Profit Margin %, Total Registros,
                        Total Customers, Total Orders, Avg Ticket, Avg Discount %
Análisis de pérdidas:   Ordenes con Perdida, Clientes con Perdida, Pct Ordenes con Perdida
Análisis estacional:    Sales Q1, Sales Q4, Pct Ventas Q4
Análisis regional:      Profit Central, Profit West, Profit Margin Central %
Análisis por categoría: Profit Margin Furniture %, Profit Margin Technology %,
                        Profit Margin Office Supplies %
Análisis de descuentos: Avg Profit, Avg Profit Sin Descuento, Avg Profit Con Descuento,
                        Pct Standard Class
```

### Filtros sincronizados

Año · Categoría · Segmento — activos en las 5 páginas analíticas (no en Portada).

> Adicionalmente, el dashboard en Plotly Dash (`04_dashboard_plotly.ipynb`) replica las 6 páginas e incorpora tres análisis extra no presentes en Power BI: scatter de cuadrantes por estado (Estrella / Riesgo / Potencial / Crítico), curva de Pareto de clientes (80/20) y heatmap de estacionalidad (Mes × Año).

---

## Stack tecnológico

| Herramienta | Uso |
|---|---|
| Python 3.9+ / pandas | EDA, limpieza, modelado, validación |
| SQLite | Base de datos del modelo relacional |
| Power BI Desktop | Dashboard principal (6 páginas, 24 medidas DAX) |
| Plotly Dash | Dashboard alternativo en Python |
| dbdiagram.io | Diagrama del modelo relacional |
| Miro | Diagrama de flujo del proceso end-to-end |
| Jupyter Notebook | Entorno de desarrollo Python |

---

## Cómo ejecutar

```bash
# Instalar dependencias
pip install pandas numpy plotly dash

# 1. EDA y limpieza
jupyter notebook notebooks/01_eda_limpieza.ipynb

# 2. Modelado relacional (genera superstore_model.db)
jupyter notebook notebooks/02_modelado_relacional.ipynb

# 3. Análisis SQL
jupyter notebook notebooks/03_analisis_sql.ipynb

# 4. Dashboard Python (opcional)
jupyter notebook notebooks/04_dashboard_plotly.ipynb

# 5. Dashboard Power BI
# Abrir powerbi/dashboard-ventas-logistica.pbix con Power BI Desktop
```

---

## Conclusiones

1. **Furniture destruye valor** — margen de 2.49% con subcategorías como Tables (-8.56%) que generan pérdidas netas a pesar del volumen.
2. **El descuento >20% es contraproducente** — existe un umbral claro donde la política de descuentos destruye rentabilidad en lugar de impulsar ventas.
3. **Central necesita intervención** — 3ra región en ventas pero con el peor margen (7.92%), casi la mitad del margen de West (14.94%).
4. **El 80% de los clientes tiene órdenes con pérdida** — señal de que la política de descuentos está mal calibrada a nivel individual.
5. **Q4 es crítico** — 38% de las ventas anuales en 3 meses. La planificación logística y de inventario debe anticipar este pico consistente.
