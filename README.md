![imagen de banner](Pictures/NEW-power_bi_logo-yellow-01.png)
# DASHBOARD POWER BI : Análisis del Ciclo de Pedido y Tiempos de Entrega

## Descripción del Proyecto

### Objetivo
_Desarrollar un dashboard interactivo en Power BI para analizar los tiempos de preparación y envío en el proceso operativo, con el fin de evaluar su impacto en las calificaciones y reseñas de los clientes _

### Sobre los Datos
Los datos originales, junto con una explicación de cada columna, se pueden encontrar [aquí](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download&select=olist_orders_dataset.csv). 

La base de datos original está compuesta por un ecosistema de 9 tablas, para este proyecto se seleccionó un subconjunto de 6 tablas clave, las cuales contienen la información esencial para realizar el dashboard en Power BI.

## 🛢️Procesamiento y Transformación de Datos en SQL Server

Para la fase de preparación y modelado de datos, se crearon **Vistas (Views) en SQL** con el fin de estructurar, limpiar y optimizar los conjuntos de datos antes de su análisis en Power BI:

* **Filtrado Operativo e Integridad:** Se aplicó un filtro (`WHERE order_status = 'delivered'`) para acotar el análisis únicamente a pedidos completados, utilizando esta vista lógica como base para filtrar de forma consistente el detalle de items y las reseñas mediante `INNER JOIN`.
* **Traducción y Estandarización:** Se renombraron todas las columnas al español para facilitar la navegabilidad del modelo. Además, se utilizó `COALESCE` para traducir las categorías de productos al inglés/español y asignar la etiqueta `'Uncategorized'` a los valores nulos.
* **Casting y Calidad de Datos:** Se ajustaron los tipos de datos (como la conversión explícita del puntaje de reseñas mediante `CAST`) para garantizar cálculos numéricos correctos en el dashboard.
* **Modelado Relacional:** Se seleccionaron únicamente las variables clave de clientes, vendedores, productos, órdenes y reseñas, eliminando redundancias y preparando la estructura lógica para el modelo estrella en Power BI.

```sql
--VISTA TABLA ORDENES

CREATE VIEW Tabla_Ordenes AS
Select order_id as Id_Orden,
       customer_id as Id_Cliente,
	   order_status as Estado_orden,
	   order_purchase_timestamp as Fecha_compra,
	   order_delivered_carrier_date as Fecha_entrega_transportista,
	   order_delivered_customer_date as Fecha_entrega_cliente,
	   order_estimated_delivery_date as Fecha_entrega_estimada
FROM [dbo].[orders_dataset]
WHERE order_status = 'delivered'

SELECT * from Tabla_Ordenes


--VISTA TABLA DETALLES DE LA ORDEN

CREATE VIEW Tabla_detalles_ordenes AS 
SELECT oi.order_id as Id_Orden,
       oi.order_item_id as Id_item_orden,
	   oi.product_id as Id_Producto,
	   oi.seller_id as Id_Vendedor,
	   oi.shipping_limit_date as Fecha_limite_envio,
	   oi.price as Precio,
	   oi.freight_value as Valor_Flete
FROM orders_items_dataset oi
INNER JOIN Tabla_Ordenes t
ON oi.order_id = t.Id_Orden

SELECT * FROM Tabla_detalles_ordenes

--VISTA TABLA CLIENTES

CREATE VIEW Tabla_Clientes AS
SELECT customer_id AS Id_Cliente,
       customer_zip_code_prefix AS Codigo_postal_cliente,
	   customer_city as Ciudad_cliente,
	   customer_state as Estado_cliente
FROM customers_dataset
       
SELECT * FROM Tabla_Clientes

--VISTA TABLA PRODUCTOS

CREATE VIEW Tabla_Productos AS
SELECT 
    p.product_id AS Id_Producto,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Uncategorized') AS Categoria_Producto,
    p.product_weight_g AS Peso_Producto_gr,
    p.product_length_cm AS Largo_Producto_cm,
    p.product_height_cm AS Altura_Producto_cm,
    p.product_width_cm AS Ancho_Producto_cm
FROM products_dataset p
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;

SELECT * FROM Tabla_Productos

--VISTA TABLA RESEÑAS

CREATE VIEW Tabla_Reseñas AS
SELECT r.review_id AS Id_Reseña,
       r.order_id AS Id_Orden, 
	   CAST(r.review_score AS INT) AS Puntaje_Reseña
FROM order_reviews_dataset r
INNER JOIN Tabla_Ordenes o
ON r.order_id = o.Id_Orden

SELECT * FROM Tabla_Reseñas

--VISTA TABLA VENDEDORES

CREATE VIEW Tabla_Vendedores AS
SELECT seller_id AS Id_Vendedor,
       seller_zip_code_prefix AS Codigo_postal_vendedor,
	   seller_city AS Ciudad_Vendedor,
	   seller_state AS Estado_vendedor
FROM sellers_dataset

SELECT * FROM Tabla_Vendedores
```

## 📊 Procesamiento, Modelado y Visualización en Power BI

### 1. Ingesta y Profiling de Datos (Power Query)
* **Importación:** Carga de las vistas SQL optimizadas en el entorno de Power BI.
* **Calidad de Datos:** Evaluación de la distribución e integridad mediante el análisis de calidad de columnas (verificación de valores nulos, errores y duplicados).
* **Transformación Complementaria:** Ajuste fino de tipos de datos y creación de **columnas condicionales** en Power Query para segmentar variables clave y facilitar la posterior agrupación de métricas.


![Tablas en Power Bi](Pictures/Tablas%20en%20Power%20BI.png)

_Tablas importadas en POWER BI_

### 2. Modelado de Datos y DAX
* **Tabla Calendario:** Creación de una tabla dimensional de fechas dedicada (*Date Table*) mediante DAX para permitir análisis temporales precisos y cálculos *Time Intelligence*.
* **Modelo de Datos:** Establecimiento de relaciones (1 a Muchos) entre las tablas dimensionales (*Clientes, Productos, Vendedores, Calendario,Reseñas*) y las tablas de hechos (*Órdenes, Detalles*), construyendo un **Modelo en Estrella (Star Schema)** eficiente.
* **Métricas DAX:** Creación de medidas explícitas para calcular indicadores clave (KPIs) como tiempos promedio de procesamiento, tiempos de tránsito, tasa de entrega a tiempo y puntaje promedio de satisfacción.


![Tabla Calendario](Pictures/Tabla%20Calendario.png)
_Realizando Tabla Calendario usando lenguaje DAX_

![Modelado](Pictures/Modelado%20de%20Datos.png)
_Modelado de Datos_

### 3. Diseño del Dashboard Interactivos
* **Dashboard:** Creación de un panel dinámico con jerarquía visual intuitiva, filtros interactivos por periodo/categoría y tarjetas KPI principales.
* **Análisis Operativo vs. Satisfacción:** Visualización focalizada en la correlación entre los días de demora/preparación y la variación en las calificaciones (*review scores*) de los clientes.

![Dashboard](Pictures/Análisis%20del%20Ciclo%20del%20Pedido%20y%20Tiempos%20de%20Entrega_page-0001.jpg)
_Dashboard del Análisis del Ciclo de Pedido y Tiempos de Entrega_

## Insihts Clave

* Hay una directa correlación entre el retraso y la insatisfacción, vemos que en los pedidos con 1 estrella, el 36.60% sufrió retraso mientras que los pedidos de 5 estrellas, solo el 1.86% de retraso. Esto demuestra que la causa raíz principal de las malas reseñas.

* El 64% de los envíos  son interestatales(entre diferentes estados) y solo el 36% son intraestatales(mismo estado). Esta alta dependencia del transporte interregional explica por qué el tiempo promedio de entrega general es de 12.50 días.

* Los muebles de oficina tienen un promedio combinado de 20.59 días, donde el tiempo de preparación promedio es aproximadamente 11 días donde supera por mucho los días de preparación promedio. 

* A pesar de las desviaciones regionales, el negocio mantiene una tasa de entregas a tiempo del 93.22% sobre las más de 96.4 mil órdenes.

* A nivel general, el tiempo de preparación es de 3.21 días, lo que indica que el grueso de la demora (12.50 días de entrega) proviene de la fase de tránsito a cargo de las transportistas.



