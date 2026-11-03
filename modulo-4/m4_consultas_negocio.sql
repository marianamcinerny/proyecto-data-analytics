-- Motor utilizado: PostgreSQL 16

-- Consulta 1 — Resumen ejecutivo mensual

	SELECT
		EXTRACT(MONTH FROM fecha_venta) AS mes,
		SUM(cantidad * precio_unitario) AS total_facturado,
		COUNT(*) AS cantidad_pedidos,
		AVG(cantidad * precio_unitario) AS ticket_promedio
	FROM ventas
	GROUP BY EXTRACT(MONTH FROM fecha_venta)
	ORDER BY mes;


-- Consulta 2 — Ranking de productos

	SELECT
		id_producto,
		SUM(cantidad * precio_unitario) AS total_facturado
		SUM(cantidad) AS unidades_vendidas,
	FROM ventas
	GROUP BY id_producto
	ORDER BY total_facturado DESC
	LIMIT 5;


-- Consulta 3 — Clientes recurrentes

	SELECT
		id_cliente,
		COUNT(*) AS cantidad_pedidos,
		SUM(cantidad * precio_unitario) AS total_gastado
	FROM ventas
	GROUP BY id_cliente
	HAVING COUNT(*) > 1
	ORDER BY total_gastado DESC;


-- Consulta 4 — Productos por encima/por debajo del promedio

	WITH facturacion_por_producto AS (
		SELECT
			id_producto,
			SUM(cantidad * precio_unitario) AS total_facturado
		FROM ventas
		GROUP BY id_producto
	)
	
	SELECT
		id_producto,
		total_facturado,
		CASE
			WHEN total_facturado > (
				SELECT AVG(total_facturado)
				FROM facturacion_por_producto
			)
			THEN 'Por encima'
			ELSE 'Por debajo'
		END AS comparacion_promedio
	FROM facturacion_por_producto
	ORDER BY total_facturado DESC;


/*
	HALLAZGOS

	1. Durante marzo se registraron 10 pedidos, con una facturación total 
	de $6.444 y un ticket promedio de $644,40.
	
	2. El producto 1 fue el de mayor facturación, con un total de $3.600.
	Aunque el producto 2 vendió más unidades, su facturación fue menor 
	debido a que tiene un precio unitario más bajo.

	3. Todos los clientes realizaron más de un pedido. El cliente 1 fue 
	el que más gastó, con un total de $2.640, seguido por el cliente 5 
	con $2.100.

*/
