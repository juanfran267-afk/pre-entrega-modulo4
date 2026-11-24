CREATE SCHEMA IF NOT EXISTS practica_m4;
SET search_path TO practica_m4;

CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    id_categoria INT REFERENCES categorias(categoria_id)
);

CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(cliente_id),
    producto_id INT REFERENCES productos(producto_id),
    cantidad INT NOT NULL,
    fecha DATE NOT NULL
);

INSERT INTO categorias (nombre_categoria) VALUES
('Tecnología'), ('Hogar'), ('Deportes');

INSERT INTO productos (nombre, precio, id_categoria) VALUES
('Notebook', 1200, 1), ('Mouse', 25, 1), ('Monitor', 300, 1),
('Licuadora', 80, 2), ('Sartén', 40, 2), ('Aspiradora', 150, 2),
('Pelota', 30, 3), ('Bicicleta', 500, 3), ('Mancuernas', 60, 3), ('Carpa', 200, 3);

INSERT INTO clientes (nombre) VALUES
('Ana'), ('Bruno'), ('Carla'), ('Diego'), ('Elena');

INSERT INTO ventas (cliente_id, producto_id, cantidad, fecha) VALUES
(1, 2, 2, '2024-03-01'), (1, 1, 1, '2024-03-05'), (1, 2, 1, '2024-04-10'),
(2, 4, 1, '2024-03-07'), (2, 8, 1, '2024-04-02'),
(3, 7, 3, '2024-03-15'), (3, 7, 2, '2024-04-20'), (3, 10, 1, '2024-05-01'),
(4, 3, 2, '2024-05-03'), (4, 5, 1, '2024-05-04');


-- 1. RENTABILIDAD POR CATEGORÍA

-- Esta consulta permite identificar qué categorías de productos
-- generan mayores ingresos y qué volumen de unidades comercializan.
-- La información puede utilizarse para comparar el desempeño comercial
-- de las categorías y orientar decisiones de stock y ventas.

-- Umbral definido en $100.000 porque permite identificar
-- las categorías que generan ingresos superiores a ese monto,
-- facilitando la identificación de las categorías con mayor
-- participación en la facturación del negocio.

SELECT c.nombre_categoria AS categoria,
SUM(v.cantidad) AS unidades_vendidas,
SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas AS v
JOIN productos AS p
ON v.producto_id = p.producto_id
JOIN categorias AS c
ON p.id_categoria = c.categoria_id
GROUP BY c.nombre_categoria
HAVING SUM(v.cantidad * p.precio) > 100000;


-- 2. CLIENTES SIN COMPRAS

-- Esta consulta permite identificar a los clientes registrados
-- que todavía no realizaron ninguna compra.
-- La información puede utilizarse para desarrollar campañas de marketing
-- y estrategias comerciales destinadas a incentivar su primera compra.

SELECT c.cliente_id,
c.nombre,
COALESCE(v.venta_id, 0) AS venta_id
FROM clientes AS c
LEFT JOIN ventas AS v
ON c.cliente_id = v.cliente_id
WHERE v.venta_id IS NULL;


-- 3. TOP DE COMPRAS POR CLIENTE

-- Esta consulta permite identificar cuál es el producto que cada cliente
-- compra con mayor frecuencia y cuándo realizó su última transacción.
-- La información puede utilizarse para personalizar ofertas
-- y detectar hábitos de consumo.

SELECT c.nombre AS cliente,
(SELECT p2.nombre
FROM ventas AS v2
JOIN productos AS p2
ON v2.producto_id = p2.producto_id
WHERE v2.cliente_id = c.cliente_id
GROUP BY p2.producto_id, p2.nombre
ORDER BY COUNT(*) DESC
LIMIT 1) AS producto_mas_comprado,
MAX(v.fecha) AS ultima_transaccion
FROM clientes AS c
JOIN ventas AS v
ON c.cliente_id = v.cliente_id
GROUP BY c.cliente_id, c.nombre;