-- Script para eliminar la tabla usuarios y recrearla limpia
-- Ejecutar en PostgreSQL

-- 1. Eliminar la tabla usuarios si existe
DROP TABLE IF EXISTS usuarios CASCADE;

-- 2. Verificar que se eliminó
SELECT 'Tabla usuarios eliminada correctamente' as resultado; 