
-- 2. MIGRAR DATOS EXISTENTES (opcional - si tienes datos)
-- Este paso extrae los IDs de productos del campo texto en proveedor.producto
-- y los inserta en la tabla junction
-- COMENTADO por defecto - descomenta si necesitas migrar datos antiguos
/*
INSERT INTO proveedor_productos (proveedor_telefono, producto_id)
SELECT DISTINCT p.telefono, prod.id
FROM proveedor p
INNER JOIN productos prod ON 
    (p.producto LIKE CONCAT('%', prod.nombre, '%') OR prod.proveedor = p.telefono)
WHERE p.producto IS NOT NULL OR prod.proveedor = p.telefono;
*/

-- 3. OPTION A: REMOVER EL CAMPO 'producto' DE PROVEEDOR (LIMPIO)
-- ALTER TABLE `proveedor` DROP COLUMN `producto`;

-- 3. OPTION B: MANTENER 'producto' COMO CAMPO RESUMEN (DENORMALIZADO)
-- Si quieres mantenerlo, simplemente no lo elimines
-- El código puede actualizar este campo manualmente cuando se asignen productos

-- 4. ACTUALIZAR TABLA productos - MANTENER O REMOVER 'proveedor'
-- OPCIÓN A: Mantener como FK al proveedor PRINCIPAL (denormalización)
-- En este caso, el campo 'proveedor' sigue siendo válido

-- OPCIÓN B: Remover 'proveedor' de productos si SOLO usas la tabla junction
-- ALTER TABLE `productos` DROP FOREIGN KEY `productos_ibfk_1`;
-- ALTER TABLE `productos` DROP COLUMN `proveedor`;

-- ============================================================
-- NUEVA ESTRUCTURA RECOMENDADA:
-- ============================================================

-- Tabla PROVEEDOR (sin campo producto, o mantenlo como resumen):
-- CREATE TABLE `proveedor` (
--     `telefono` VARCHAR(15) NOT NULL,
--     `nombre_empresa` VARCHAR(100) NOT NULL,
--     `nombre_proveedor` VARCHAR(100) NOT NULL,
--     `correo` VARCHAR(100) NULL,
--     `estado` ENUM('activo','inactivo') DEFAULT 'activo',
--     `fecha_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     `producto` VARCHAR(500) NULL,  -- RESUMEN TEXTO (actualizar manualmente)
--     PRIMARY KEY (`telefono`)
-- );

-- Tabla PRODUCTOS (mantiene FK a proveedor principal):
-- CREATE TABLE `productos` (
--     `id` INT NOT NULL AUTO_INCREMENT,
--     `nombre` VARCHAR(100) NOT NULL,
--     `descripcion` TEXT NULL,
--     `categoria` VARCHAR(50) NOT NULL,
--     `cantidad` INT DEFAULT 0,
--     `presentacion` VARCHAR(50) NULL,
--     `proveedor` VARCHAR(15) NULL,  -- PROVEEDOR PRINCIPAL (denormalizado)
--     `precio_costo` INT NULL,
--     `precio_venta` INT NULL,
--     PRIMARY KEY (`id`),
--     FOREIGN KEY (`proveedor`) REFERENCES `proveedor` (`telefono`) 
--         ON UPDATE NO ACTION ON DELETE SET NULL
-- );

-- Tabla JUNCTION para relación N:N:
-- CREATE TABLE `proveedor_productos` (
--     `id` INT NOT NULL AUTO_INCREMENT,
--     `proveedor_telefono` VARCHAR(15) NOT NULL,
--     `producto_id` INT NOT NULL,
--     `fecha_asignacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     PRIMARY KEY (`id`),
--     UNIQUE KEY (`proveedor_telefono`, `producto_id`),
--     FOREIGN KEY (`proveedor_telefono`) REFERENCES `proveedor` (`telefono`) 
--         ON UPDATE CASCADE ON DELETE CASCADE,
--     FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) 
--         ON UPDATE NO ACTION ON DELETE CASCADE
-- );

-- ============================================================
-- PARA QUERY: Obtener productos de un proveedor
-- ============================================================
-- SELECT p.* FROM productos p
-- INNER JOIN proveedor_productos pp ON p.id = pp.producto_id
-- WHERE pp.proveedor_telefono = '3001234567'
-- ORDER BY p.nombre;

-- ============================================================
-- PARA QUERY: Obtener proveedores de un producto
-- ============================================================
-- SELECT prov.* FROM proveedor prov
-- INNER JOIN proveedor_productos pp ON prov.telefono = pp.proveedor_telefono
-- WHERE pp.producto_id = 5
-- ORDER BY prov.nombre_empresa;
