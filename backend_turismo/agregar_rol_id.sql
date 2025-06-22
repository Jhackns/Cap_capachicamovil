-- Script simple para agregar la columna rol_id a la tabla usuarios
-- Ejecutar en pgAdmin o cualquier cliente SQL

-- 1. Agregar columna rol_id a la tabla usuarios
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS rol_id INTEGER;

-- 2. Verificar que la columna se agregó
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'usuarios' AND column_name = 'rol_id';

-- 3. Mostrar la estructura actual de la tabla usuarios
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position; 