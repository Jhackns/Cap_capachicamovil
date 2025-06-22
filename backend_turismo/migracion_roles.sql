-- Script de migración para agregar sistema de roles
-- Ejecutar este script para actualizar la base de datos existente

-- 1. Crear tabla de roles
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- 2. Crear tabla de permisos
CREATE TABLE IF NOT EXISTS permisos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- 3. Crear tabla de relación roles_permisos
CREATE TABLE IF NOT EXISTS roles_permisos (
    rol_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    permiso_id INTEGER REFERENCES permisos(id) ON DELETE CASCADE,
    PRIMARY KEY (rol_id, permiso_id)
);

-- 4. Insertar roles básicos
INSERT INTO roles (nombre, titulo, descripcion) VALUES 
('admin', 'Administrador', 'Rol con acceso completo al sistema'),
('regular', 'Usuario Regular', 'Usuario con acceso básico al sistema'),
('emprendedor', 'Emprendedor', 'Usuario que puede gestionar sus servicios y alojamientos')
ON CONFLICT (nombre) DO NOTHING;

-- 5. Agregar columna rol_id a la tabla usuarios
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS rol_id INTEGER REFERENCES roles(id);

-- 6. Migrar datos existentes de rol (String) a rol_id (Integer)
-- Primero, actualizar usuarios que tienen rol = 'admin' o similar
UPDATE usuarios SET rol_id = (SELECT id FROM roles WHERE nombre = 'admin') 
WHERE rol = 'admin' OR rol = 'ADMIN' OR rol = 'administrador';

UPDATE usuarios SET rol_id = (SELECT id FROM roles WHERE nombre = 'regular') 
WHERE rol = 'regular' OR rol = 'REGULAR' OR rol = 'user' OR rol = 'USER' OR rol = 'usuario';

UPDATE usuarios SET rol_id = (SELECT id FROM roles WHERE nombre = 'emprendedor') 
WHERE rol = 'emprendedor' OR rol = 'EMPRENDEDOR';

-- 7. Asignar rol 'regular' por defecto a usuarios sin rol asignado
UPDATE usuarios SET rol_id = (SELECT id FROM roles WHERE nombre = 'regular') 
WHERE rol_id IS NULL;

-- 8. Hacer rol_id NOT NULL después de migrar todos los datos
ALTER TABLE usuarios ALTER COLUMN rol_id SET NOT NULL;

-- 9. Eliminar la columna rol antigua (opcional - comentar si quieres mantenerla)
-- ALTER TABLE usuarios DROP COLUMN rol;

-- 10. Verificar la migración
SELECT 
    u.id,
    u.email,
    u.nombre,
    u.apellidos,
    r.nombre as rol_nombre,
    r.titulo as rol_titulo
FROM usuarios u
LEFT JOIN roles r ON u.rol_id = r.id
ORDER BY u.id;

-- 11. Mostrar roles creados
SELECT * FROM roles; 