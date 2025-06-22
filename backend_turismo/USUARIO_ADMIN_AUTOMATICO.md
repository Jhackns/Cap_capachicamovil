# Usuario Administrador Automático

## Sistema de Inicialización Automática

El sistema ahora crea automáticamente los roles y el usuario administrador al iniciar la aplicación.

### 🔧 **Qué hace el sistema al arrancar:**

1. **Crea los roles básicos** (si no existen):
   - `admin` - Administrador
   - `regular` - Usuario Regular  
   - `emprendedor` - Emprendedor

2. **Crea el usuario administrador** (si no existe):
   - **Email:** `admin@capachica.com`
   - **Contraseña:** `admin123`
   - **Nombre:** `Administrador`
   - **Apellido:** `Sistema`
   - **Rol:** `admin`

### 📋 **Credenciales del Admin:**

```
Email: admin@capachica.com
Contraseña: admin123
```

### 🚀 **Cómo usar:**

#### 1. Iniciar la aplicación
```bash
mvn spring-boot:run
```

#### 2. Verificar en los logs
Deberías ver algo como:
```
🚀 Inicializando sistema...
📋 Inicializando roles...
✅ Rol 'admin' creado
✅ Rol 'regular' creado
✅ Rol 'emprendedor' creado
👤 Inicializando usuario administrador...
✅ Usuario admin creado con ID: 1
📧 Email: admin@capachica.com
🔑 Contraseña: admin123
⚠️ IMPORTANTE: Cambia la contraseña después del primer login
✅ Sistema inicializado correctamente
```

#### 3. Hacer login con Postman
```
POST http://localhost:8080/api/auth/login
```

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
    "email": "admin@capachica.com",
    "password": "admin123"
}
```

**Respuesta esperada:**
```json
{
    "message": "¡Bienvenido de vuelta Administrador!",
    "rol": "Administrador",
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "usuario": {
        "id": 1,
        "email": "admin@capachica.com",
        "nombre": "Administrador",
        "apellido": "Sistema",
        "rol": "admin"
    }
}
```

### 🔐 **Después del Login:**

1. **Guarda el token** de la respuesta
2. **Usa el token** para endpoints de administración:
   ```
   Authorization: Bearer {tu_token_aqui}
   ```

3. **Endpoints disponibles con el token:**
   - `GET /api/admin/usuarios` - Listar usuarios
   - `POST /api/admin/usuarios` - Crear usuarios
   - `GET /api/admin/roles` - Listar roles
   - Y otros endpoints administrativos

### ⚠️ **Importante:**

- **Cambia la contraseña** después del primer login por seguridad
- **El usuario admin se crea solo una vez** (si ya existe, no se vuelve a crear)
- **Los roles se crean automáticamente** cada vez que arranca la aplicación
- **No necesitas crear manualmente** roles ni usuarios admin

### 🔄 **Si necesitas recrear el admin:**

Si por alguna razón necesitas recrear el usuario admin, puedes:

1. **Eliminar el usuario** de la base de datos
2. **Reiniciar la aplicación** - se creará automáticamente

O usar el endpoint de administración para crear uno nuevo.

### 📝 **Ejemplo de uso completo:**

1. **Iniciar aplicación** → Se crean roles y admin automáticamente
2. **Login con admin** → Obtener token
3. **Crear más usuarios** usando el token
4. **Gestionar el sistema** con los permisos de admin

### 🎯 **Ventajas de este enfoque:**

- ✅ **No hay problemas de "huevo y gallina"**
- ✅ **Sistema siempre funcional** al arrancar
- ✅ **Credenciales consistentes** y conocidas
- ✅ **Fácil de usar** en desarrollo y producción
- ✅ **Seguro** - contraseña se puede cambiar después 