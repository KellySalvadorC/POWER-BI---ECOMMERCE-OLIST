

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






