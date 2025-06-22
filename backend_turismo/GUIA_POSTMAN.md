# Guía Rápida de Postman

## 🚀 Configuración Inicial

### 1. Crear Colección
- Abre Postman
- Crea una nueva colección llamada "Turismo Backend"
- Crea carpetas: "Auth", "Admin", "Turismo"

### 2. Configurar Variables de Entorno
- Crea un nuevo environment llamado "Turismo Local"
- Agrega variables:
  - `base_url`: `http://localhost:8080`
  - `token`: (se llenará automáticamente)

## 📋 Peticiones Esenciales

### 🔐 **1. Login Admin (Auth)**
```
POST {{base_url}}/api/auth/login
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
    "email": "admin@capachica.com",
    "password": "admin123"
}
```

**Script de Test (para guardar token automáticamente):**
```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("token", response.token);
    console.log("Token guardado:", response.token);
}
```

### 👥 **2. Listar Usuarios (Admin)**
```
GET {{base_url}}/api/admin/usuarios
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

### 👤 **3. Crear Usuario (Admin)**
```
POST {{base_url}}/api/admin/usuarios
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

**Body (raw JSON):**
```json
{
    "email": "usuario@ejemplo.com",
    "password": "password123",
    "nombre": "Juan",
    "apellido": "Pérez",
    "rol": "regular"
}
```

### 📊 **4. Listar Roles (Admin)**
```
GET {{base_url}}/api/admin/roles
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

### 🏨 **5. Listar Alojamientos (Público)**
```
GET {{base_url}}/api/alojamientos
```

**Headers:**
```
Content-Type: application/json
```

## 🔄 Flujo de Trabajo

### **Paso 1: Iniciar Aplicación**
```bash
mvn spring-boot:run
```

### **Paso 2: Login Admin**
1. Ejecuta la petición "Login Admin"
2. El token se guarda automáticamente
3. Verifica que recibiste el token en la respuesta

### **Paso 3: Crear Usuarios**
1. Usa el token para crear usuarios adicionales
2. Puedes crear usuarios con roles: `admin`, `regular`, `emprendedor`

### **Paso 4: Gestionar Sistema**
1. Listar usuarios existentes
2. Crear/editar/eliminar usuarios
3. Gestionar roles y permisos

## 📝 Ejemplos de Usuarios

### **Usuario Regular:**
```json
{
    "email": "usuario@ejemplo.com",
    "password": "password123",
    "nombre": "Juan",
    "apellido": "Pérez",
    "rol": "regular"
}
```

### **Usuario Emprendedor:**
```json
{
    "email": "emprendedor@ejemplo.com",
    "password": "password123",
    "nombre": "María",
    "apellido": "García",
    "rol": "emprendedor"
}
```

### **Otro Admin:**
```json
{
    "email": "admin2@ejemplo.com",
    "password": "password123",
    "nombre": "Carlos",
    "apellido": "López",
    "rol": "admin"
}
```

## ⚠️ Solución de Problemas

### **Error 403 Forbidden:**
- Verifica que el token esté en el header `Authorization: Bearer {{token}}`
- Asegúrate de que el usuario tenga permisos de admin

### **Error 401 Unauthorized:**
- El token ha expirado, haz login nuevamente
- Verifica que el token esté correctamente formateado

### **Error 400 Bad Request:**
- Verifica el formato del JSON en el body
- Asegúrate de que todos los campos requeridos estén presentes

### **Error 500 Internal Server Error:**
- Revisa los logs de la aplicación
- Verifica que la base de datos esté funcionando

## 🎯 Tips de Postman

### **1. Usar Variables de Entorno**
- Siempre usa `{{base_url}}` en lugar de la URL completa
- Usa `{{token}}` para el token de autorización

### **2. Scripts de Test**
- Guarda automáticamente el token al hacer login
- Valida las respuestas automáticamente

### **3. Organización**
- Usa carpetas para organizar las peticiones
- Nombra las peticiones de forma descriptiva

### **4. Pre-request Scripts**
- Puedes usar scripts para preparar datos antes de las peticiones
- Útil para generar datos dinámicos

## 🔐 Seguridad

### **Credenciales por Defecto:**
- **Admin:** `admin@capachica.com` / `admin123`
- **Cambia la contraseña** después del primer login

### **Tokens:**
- Los tokens expiran después de cierto tiempo
- Guarda el token en variables de entorno
- No compartas tokens en producción

### **Roles:**
- `admin`: Acceso completo al sistema
- `regular`: Usuario básico
- `emprendedor`: Puede gestionar servicios y alojamientos 