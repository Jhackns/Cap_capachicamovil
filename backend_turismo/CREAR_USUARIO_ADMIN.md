# Crear Usuario Administrador

## Instrucciones para crear el primer usuario administrador

### 1. Configuración de la Base de Datos
Asegúrate de que la base de datos esté configurada y que las tablas de roles estén creadas.

### 2. Inicializar Roles (OBLIGATORIO)
Antes de crear usuarios, debes inicializar los roles básicos:

#### Endpoint:
```
POST http://localhost:8080/api/auth/init-roles
```

#### Headers:
```
Content-Type: application/json
```

#### Body: (vacío)

#### Respuesta esperada:
```json
{
    "message": "Roles inicializados correctamente",
    "roles_creados": true
}
```

### 3. Verificar Roles Creados (OPCIONAL)
Para verificar que los roles se crearon correctamente:

#### Endpoint:
```
GET http://localhost:8080/api/auth/roles
```

#### Respuesta esperada:
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

### 4. Crear Usuario Admin usando Postman

#### Endpoint:
```
POST http://localhost:8080/api/auth/register
```

#### Headers:
```
Content-Type: application/json
```

#### Body (JSON):
```json
{
    "email": "admin@example.com",
    "password": "password123",
    "rol": "admin",
    "nombre": "admin",
    "apellido": "admin"
}
```

#### Respuesta esperada:
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

### 5. Verificar el registro

#### Endpoint para verificar:
```
GET http://localhost:8080/api/admin/usuarios
```

#### Headers:
```
Authorization: Bearer {token_del_admin}
Content-Type: application/json
```

### 6. Notas importantes:

- **OBLIGATORIO**: Siempre inicializar roles antes de crear usuarios
- **Seguridad**: Cambia la contraseña del admin después del primer login
- **Roles disponibles**: `admin`, `regular`, `emprendedor`
- **Validaciones**: El sistema valida que el email no esté duplicado
- **Token**: Guarda el token para futuras operaciones administrativas

### 7. Endpoints disponibles para autenticación:

- `POST /api/auth/init-roles` - Inicializar roles básicos
- `POST /api/auth/register` - Registro de usuarios
- `POST /api/auth/login` - Login de usuarios
- `GET /api/auth/roles` - Obtener roles disponibles

### 8. Endpoints de administración (requieren rol admin):

- `GET /api/admin/usuarios` - Listar todos los usuarios
- `GET /api/admin/usuarios/{id}` - Obtener usuario por ID
- `POST /api/admin/usuarios` - Crear usuario (admin)
- `PUT /api/admin/usuarios/{id}` - Actualizar usuario
- `DELETE /api/admin/usuarios/{id}` - Eliminar usuario

### 9. Endpoints de gestión de roles (requieren rol admin):

- `GET /api/admin/roles` - Listar todos los roles
- `GET /api/admin/roles/{id}` - Obtener rol por ID
- `POST /api/admin/roles` - Crear rol
- `PUT /api/admin/roles/{id}` - Actualizar rol
- `DELETE /api/admin/roles/{id}` - Eliminar rol
- `POST /api/admin/roles/init` - Inicializar roles básicos

### 10. Ejemplo de creación de otros tipos de usuarios:

#### Usuario Regular:
```json
{
    "email": "usuario@ejemplo.com",
    "password": "password123",
    "rol": "regular",
    "nombre": "Juan",
    "apellido": "Pérez"
}
```

#### Usuario Emprendedor:
```json
{
    "email": "emprendedor@ejemplo.com",
    "password": "password123",
    "rol": "emprendedor",
    "nombre": "María",
    "apellido": "García"
}
```

### 11. Solución de Problemas Comunes

#### Error: "El rol 'admin' no existe"
**Causa:** Los roles no han sido inicializados en la base de datos.
**Solución:** Ejecutar primero el endpoint `/api/auth/init-roles`.

#### Error: "constraint [null]"
**Causa:** El rol_id está siendo insertado como null.
**Solución:** Asegurarse de que el rol existe antes de crear el usuario.

#### Error: "el valor nulo en la columna «rol» de la relación «usuarios» viola la restricción de no nulo"
**Causa:** El rol no se encuentra en la base de datos.
**Solución:** Verificar que los roles estén creados usando el endpoint `/api/auth/roles`. 