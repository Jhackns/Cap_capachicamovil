# Sistema de Roles y Usuarios - Backend Turismo

## Configuración Inicial

### 1. Configurar el Sistema
Antes de usar el sistema, necesitas inicializarlo para crear los roles y el usuario administrador.

**Endpoint:** `POST http://localhost:8080/api/init/setup`

Este endpoint:
- Crea los roles: `admin`, `regular`, `emprendedor`
- Crea el usuario administrador con credenciales:
  - Email: `admin@example.com`
  - Contraseña: `password123`

### 2. Verificar Estado del Sistema
**Endpoint:** `GET http://localhost:8080/api/init/status`

## Estructura de Roles

### Roles Disponibles:
1. **admin** - Administrador del sistema
   - Acceso completo a todas las funcionalidades
   - Puede gestionar usuarios, roles y permisos
   - Puede ver todas las reservas y datos del sistema

2. **regular** - Usuario regular
   - Puede hacer reservas
   - Puede ver alojamientos y servicios
   - Acceso básico al sistema

3. **emprendedor** - Emprendedor
   - Puede gestionar sus propios alojamientos y servicios
   - Puede hacer reservas
   - Acceso intermedio al sistema

## Endpoints de Usuarios

### Registro de Usuario
**Endpoint:** `POST http://localhost:8080/api/usuarios/register`

**Body:**
```json
{
    "email": "usuario@example.com",
    "password": "password123",
    "nombre": "Juan",
    "apellido": "Pérez",
    "rol": "regular"
}
```

**Respuesta:**
```json
{
    "message": "¡Bienvenido Juan!",
    "rol": "Usuario Regular",
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "usuario": {
        "id": 1,
        "email": "usuario@example.com",
        "nombre": "Juan",
        "apellido": "Pérez",
        "rol": "regular"
    }
}
```

### Login de Usuario
**Endpoint:** `POST http://localhost:8080/api/usuarios/login`

**Body:**
```json
{
    "email": "usuario@example.com",
    "password": "password123"
}
```

### Gestión de Usuarios (Solo ADMIN)
- `GET /api/usuarios` - Listar todos los usuarios
- `GET /api/usuarios/{id}` - Obtener usuario por ID
- `POST /api/usuarios` - Crear usuario
- `PUT /api/usuarios/{id}` - Actualizar usuario
- `DELETE /api/usuarios/{id}` - Eliminar usuario
- `GET /api/usuarios/roles` - Obtener roles disponibles

## Endpoints de Roles (Solo ADMIN)
- `GET /api/roles` - Listar todos los roles
- `GET /api/roles/{id}` - Obtener rol por ID
- `GET /api/roles/nombre/{nombre}` - Obtener rol por nombre
- `POST /api/roles` - Crear rol
- `PUT /api/roles/{id}` - Actualizar rol
- `DELETE /api/roles/{id}` - Eliminar rol

## Autenticación

### Uso del Token Bearer
Para endpoints que requieren autenticación, incluir el header:
```
Authorization: Bearer <token>
```

### Ejemplo con Postman:
1. Hacer POST a `/api/usuarios/login` o `/api/usuarios/register`
2. Copiar el token de la respuesta
3. En las siguientes peticiones, agregar el header:
   ```
   Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
   ```

## Flujo de Configuración

1. **Inicializar el sistema:**
   ```bash
   POST http://localhost:8080/api/init/setup
   ```

2. **Login como administrador:**
   ```bash
   POST http://localhost:8080/api/usuarios/login
   {
       "email": "admin@example.com",
       "password": "password123"
   }
   ```

3. **Usar el token para gestionar usuarios:**
   ```bash
   GET http://localhost:8080/api/usuarios
   Authorization: Bearer <token_admin>
   ```

## Estructura de Base de Datos

### Tabla: roles
- `id` (PK)
- `nombre` (unique, not null)
- `titulo` (not null)
- `descripcion` (text)

### Tabla: permisos
- `id` (PK)
- `nombre` (unique, not null)
- `titulo` (not null)
- `descripcion` (text)

### Tabla: roles_permisos (relación many-to-many)
- `rol_id` (FK)
- `permiso_id` (FK)

### Tabla: usuarios (actualizada)
- `id` (PK)
- `email` (unique, not null)
- `password` (not null)
- `rol_id` (FK a roles, not null)
- `nombre` (not null)
- `apellidos` (not null)

## Notas Importantes

1. **Seguridad:** Las contraseñas se encriptan con BCrypt
2. **Tokens JWT:** Tienen una duración de 7 días
3. **Roles por defecto:** Si no se especifica un rol al registrar, se asigna "regular"
4. **Validaciones:** Todos los campos requeridos son validados
5. **Respuestas:** Las contraseñas nunca se devuelven en las respuestas

## Solución de Problemas

### Error 403 Forbidden
- Verificar que el token sea válido
- Verificar que el usuario tenga el rol necesario
- Verificar que el endpoint esté correctamente configurado

### Error 401 Unauthorized
- Verificar que el token esté presente en el header Authorization
- Verificar que el token no haya expirado

### Error al crear usuario
- Verificar que el email no esté duplicado
- Verificar que todos los campos requeridos estén presentes
- Verificar que el rol especificado exista 