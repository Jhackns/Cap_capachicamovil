# Prueba de Creación de Usuario Admin

## Pasos para crear el usuario administrador

### Paso 1: Inicializar Roles
**Endpoint:** `POST http://localhost:8080/api/auth/init-roles`

**Headers:**
```
Content-Type: application/json
```

**Body:** (vacío)

**Respuesta esperada:**
```json
{
    "message": "Roles inicializados correctamente",
    "roles_creados": true
}
```

### Paso 2: Verificar Roles Creados
**Endpoint:** `GET http://localhost:8080/api/auth/roles`

**Headers:**
```
Content-Type: application/json
```

**Respuesta esperada:**
```json
[
    {
        "id": 1,
        "nombre": "admin",
        "titulo": "Administrador",
        "descripcion": "Rol con acceso completo al sistema"
    },
    {
        "id": 2,
        "nombre": "regular",
        "titulo": "Usuario Regular",
        "descripcion": "Usuario con acceso básico al sistema"
    },
    {
        "id": 3,
        "nombre": "emprendedor",
        "titulo": "Emprendedor",
        "descripcion": "Usuario que puede gestionar sus servicios y alojamientos"
    }
]
```

### Paso 3: Crear Usuario Admin
**Endpoint:** `POST http://localhost:8080/api/auth/register`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
    "email": "admin@example.com",
    "password": "password123",
    "nombre": "admin",
    "apellido": "admin",
    "rol": "admin"
}
```

**Respuesta esperada:**
```json
{
    "message": "¡Bienvenido admin!",
    "rol": "Administrador",
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "usuario": {
        "id": 1,
        "email": "admin@example.com",
        "nombre": "admin",
        "apellido": "admin",
        "rol": "admin"
    }
}
```

### Paso 4: Verificar Login
**Endpoint:** `POST http://localhost:8080/api/auth/login`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
    "email": "admin@example.com",
    "password": "password123"
}
```

**Respuesta esperada:**
```json
{
    "message": "¡Bienvenido de vuelta admin!",
    "rol": "Administrador",
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "usuario": {
        "id": 1,
        "email": "admin@example.com",
        "nombre": "admin",
        "apellido": "admin",
        "rol": "admin"
    }
}
```

## Solución de Problemas

### Error: "El rol 'admin' no existe"
**Causa:** Los roles no han sido inicializados en la base de datos.
**Solución:** Ejecutar primero el Paso 1 (inicializar roles).

### Error: "constraint [null]"
**Causa:** El rol_id está siendo insertado como null.
**Solución:** Asegurarse de que el rol existe antes de crear el usuario.

### Error: "el valor nulo en la columna «rol» de la relación «usuarios» viola la restricción de no nulo"
**Causa:** El rol no se encuentra en la base de datos.
**Solución:** Verificar que los roles estén creados usando el endpoint `/api/auth/roles`.

## Verificación Final

Después de crear el usuario admin, puedes verificar que todo funciona correctamente:

1. **Login exitoso** con las credenciales del admin
2. **Token válido** que se puede usar para endpoints protegidos
3. **Rol correcto** asignado al usuario

## Notas Importantes

- **Siempre inicializar roles** antes de crear usuarios
- **Verificar que los roles existen** antes de intentar crear usuarios
- **Guardar el token** para futuras operaciones administrativas
- **Cambiar la contraseña** del admin después del primer login por seguridad 