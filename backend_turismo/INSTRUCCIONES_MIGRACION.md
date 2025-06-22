# Instrucciones de Migración - Sistema de Roles

## 🚨 Problema Identificado

El error que estás viendo ocurre porque la base de datos tiene una estructura antigua donde la tabla `usuarios` tiene un campo `rol` como String, pero el nuevo sistema espera un campo `rol_id` como foreign key a la tabla `roles`.

## 🔧 Solución: Migración de Base de Datos

### Opción 1: Migración Automática (Recomendada)

1. **Ejecutar migración automática:**
   ```bash
   POST http://localhost:8080/api/migracion/setup
   ```

2. **Verificar estado de migración:**
   ```bash
   GET http://localhost:8080/api/migracion/status
   ```

3. **Inicializar sistema:**
   ```bash
   POST http://localhost:8080/api/init/setup
   ```

### Opción 2: Migración Manual (Si la automática falla)

1. **Ejecutar script SQL manualmente en PostgreSQL:**
   ```sql
   -- Copiar y ejecutar el contenido del archivo migracion_roles.sql
   -- en tu cliente de PostgreSQL (pgAdmin, DBeaver, etc.)
   ```

2. **Verificar que las tablas se crearon:**
   ```sql
   SELECT * FROM roles;
   SELECT * FROM usuarios LIMIT 5;
   ```

3. **Luego ejecutar la inicialización:**
   ```bash
   POST http://localhost:8080/api/init/setup
   ```

## 📋 Pasos Detallados

### Paso 1: Preparar la Base de Datos
- Asegúrate de que PostgreSQL esté corriendo
- Verifica que la base de datos `capachica_turismodb` existe
- Haz un backup de la base de datos actual

### Paso 2: Ejecutar Migración
```bash
# Opción A: Migración automática
POST http://localhost:8080/api/migracion/setup

# Opción B: Script manual
# Ejecutar migracion_roles.sql en PostgreSQL
```

### Paso 3: Verificar Migración
```bash
GET http://localhost:8080/api/migracion/status
```

**Respuesta esperada:**
```json
{
    "migracion_completada": true,
    "roles_creados": true,
    "message": "Migración completada"
}
```

### Paso 4: Inicializar Sistema
```bash
POST http://localhost:8080/api/init/setup
```

**Respuesta esperada:**
```json
{
    "message": "Sistema configurado exitosamente",
    "admin_created": true,
    "admin": {
        "id": 1,
        "email": "admin@example.com",
        "nombre": "Administrador",
        "apellido": "Sistema",
        "rol": "admin"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### Paso 5: Probar el Sistema
```bash
# Login como admin
POST http://localhost:8080/api/usuarios/login
{
    "email": "admin@example.com",
    "password": "password123"
}

# Crear usuario regular
POST http://localhost:8080/api/usuarios/register
{
    "email": "usuario@example.com",
    "password": "password123",
    "nombre": "Juan",
    "apellido": "Pérez",
    "rol": "regular"
}
```

## 🔍 Verificación de la Migración

### Verificar en PostgreSQL:
```sql
-- Verificar que las tablas existen
\dt roles
\dt permisos
\dt roles_permisos

-- Verificar que los roles se crearon
SELECT * FROM roles;

-- Verificar que usuarios tiene rol_id
SELECT u.id, u.email, u.nombre, r.nombre as rol_nombre 
FROM usuarios u 
LEFT JOIN roles r ON u.rol_id = r.id;
```

### Verificar via API:
```bash
# Verificar roles
GET http://localhost:8080/api/roles
Authorization: Bearer <token_admin>

# Verificar usuarios
GET http://localhost:8080/api/usuarios
Authorization: Bearer <token_admin>
```

## 🚨 Posibles Errores y Soluciones

### Error: "Rol 'admin' no encontrado"
**Causa:** La migración no se ejecutó correctamente
**Solución:** Ejecutar `/api/migracion/setup` primero

### Error: "constraint [null]"
**Causa:** La columna `rol_id` no se migró correctamente
**Solución:** Ejecutar el script SQL manualmente

### Error: "table roles does not exist"
**Causa:** Las tablas no se crearon
**Solución:** Verificar que el script SQL se ejecutó completamente

## 📝 Notas Importantes

1. **Backup:** Siempre haz un backup antes de migrar
2. **Orden:** Ejecutar migración antes que inicialización
3. **Verificación:** Siempre verifica el estado después de cada paso
4. **Configuración:** El `application.properties` está configurado para `validate` en lugar de `update`

## 🎯 Flujo Completo de Configuración

```bash
1. POST /api/migracion/setup          # Migrar base de datos
2. GET /api/migracion/status          # Verificar migración
3. POST /api/init/setup               # Inicializar sistema
4. POST /api/usuarios/login           # Login como admin
5. POST /api/usuarios/register        # Crear usuarios
```

¡Sigue estos pasos en orden y el sistema funcionará correctamente! 