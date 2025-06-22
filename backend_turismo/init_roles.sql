-- Script para inicializar roles en la base de datos
-- Ejecutar este script antes de crear usuarios

-- Insertar roles si no existen
INSERT INTO roles (nombre, titulo, descripcion) 
VALUES 
    ('admin', 'Administrador', 'Rol con acceso completo al sistema')
ON DUPLICATE KEY UPDATE 
    titulo = VALUES(titulo), 
    descripcion = VALUES(descripcion);

INSERT INTO roles (nombre, titulo, descripcion) 
VALUES 
    ('regular', 'Usuario Regular', 'Usuario con acceso básico al sistema')
ON DUPLICATE KEY UPDATE 
    titulo = VALUES(titulo), 
    descripcion = VALUES(descripcion);

INSERT INTO roles (nombre, titulo, descripcion) 
VALUES 
    ('emprendedor', 'Emprendedor', 'Usuario que puede gestionar sus servicios y alojamientos')
ON DUPLICATE KEY UPDATE 
    titulo = VALUES(titulo), 
    descripcion = VALUES(descripcion);

-- Verificar que los roles se crearon correctamente
SELECT * FROM roles WHERE nombre IN ('admin', 'regular', 'emprendedor'); 