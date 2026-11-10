-- Motor utilizado: PostgreSQL 16

/* Consulta 1 — Vista base del proyecto (INNER JOIN)
Propósito: reunir los datos de las ventas con la información de clientes, 
productos y categorías para utilizarlos posteriormente en Power BI. */

SELECT 
	v.id_venta,
	v.fecha_venta,
	c.id_cliente,
	c.nombre AS comprador,
	c.ciudad AS ciudad_cliente,
	p.nombre_producto AS producto,
	cat.nombre_categoria AS categoria,
	cat.descripcion AS descripcion_categoria,
	v.cantidad AS cantidad_vendida,
	v.precio_unitario,
	(v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN productos p 
	ON v.id_producto = p.id_producto
INNER JOIN categorias cat 
	ON p.id_categoria = cat.id_categoria
INNER JOIN clientes c 
	ON v.id_cliente = c.id_cliente;

/* Hallazgo: La vista reúne las 10 ventas registradas con información del cliente,
la ciudad, el producto y su categoría, facilitando su análisis en Power BI. */

----------------------------------------------------------------------------------

/* Consulta 2 — Clientes sin ventas (LEFT JOIN) 
Propósito: identificar clientes registrados que no realizaron ninguna compra
para que el área encargada de clientes pueda contactarlos. */

SELECT
	c.nombre AS nombre_cliente,
	c.email,
	c.fecha_registro
FROM clientes c
LEFT JOIN ventas v
	ON v.id_cliente = c.id_cliente
WHERE v.id_venta IS NULL;

/* Hallazgo: No se encontraron clientes sin ventas. Los 5 clientes registrados
realizaron al menos una compra, por lo que CRM no tiene clientes sin compras para contactar. */

----------------------------------------------------------------------------------

/* Consulta 3 — Productos sin ventas (LEFT JOIN)
Propósito: identificar productos del catálogo que no registran ventas
para que el área de producto pueda revisar su situación. */

SELECT
	p.nombre_producto,
	cat.nombre_categoria,
	p.precio
FROM productos p
INNER JOIN categorias cat
	ON cat.id_categoria = p.id_categoria
LEFT JOIN ventas v
	ON v.id_producto = p.id_producto
WHERE v.id_venta IS NULL;

/* Hallazgo: No se encontraron productos sin ventas. Los 6 productos del catálogo 
registraron al menos una venta, por lo que no hay artículos sin movimiento. */

----------------------------------------------------------------------------------

/* Consulta 4 — Consolidado por período (UNION ALL) 
Propósito: dividir las ventas en dos períodos creados dentro de la consulta 
y comparar la facturación total obtenida en cada uno. */

SELECT
	periodo,
	SUM(total) AS total_periodo
FROM (
	SELECT
		fecha_venta,
		cantidad * precio_unitario AS total,
		'Primer período' AS periodo
	FROM ventas
	WHERE fecha_venta BETWEEN '2024-03-05' AND '2024-03-10'
	UNION ALL
	SELECT
		fecha_venta,
		cantidad * precio_unitario AS total,
		'Segundo período' AS periodo
	FROM ventas
	WHERE fecha_venta BETWEEN '2024-03-11' AND '2024-03-15'
) AS consolidado
GROUP BY periodo;

/* Hallazgo: El primer período alcanzó una facturación de $3.620, mientras que 
el segundo período facturó $2.824. El primer período generó $796 más.*/
