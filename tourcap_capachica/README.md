# Tour Capachica - Aplicación Móvil

Aplicación móvil desarrollada en Flutter para el sistema de turismo de Capachica, conectada con un backend Laravel.

## Configuración del Backend

### Requisitos
- Laravel 10+
- PostgreSQL
- PHP 8.1+

### Instalación del Backend
1. Navegar al directorio del backend:
```bash
cd turismo-backend
```

2. Instalar dependencias:
```bash
composer install
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
```

4. Configurar la base de datos PostgreSQL en `.env`:
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=tu_base_de_datos
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password
```

5. Generar clave de aplicación:
```bash
php artisan key:generate
```

6. Ejecutar migraciones:
```bash
php artisan migrate
```

7. Ejecutar seeders:
```bash
php artisan db:seed
```

8. Iniciar el servidor:
```bash
php artisan serve
```

El backend estará disponible en `http://127.0.0.1:8000`

## Configuración de la Aplicación Móvil

### Requisitos
- Flutter 3.7.2+
- Dart SDK
- Android Studio / VS Code

### Instalación
1. Navegar al directorio de la aplicación:
```bash
cd tourcap_capachica
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar la URL del backend en `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://192.168.1.64:8000';
```

**Nota**: Cambiar la IP según tu configuración de red local.

### Credenciales de Administrador

Según el seeder del backend, las credenciales del administrador son:

- **Email**: `admin@turismo.com`
- **Password**: `password123`

O alternativamente:
- **Email**: `admin@example.com`
- **Password**: `password`

## Estructura del Proyecto

### Backend (Laravel)
```
turismo-backend/
├── app/
│   ├── Http/Controllers/API/
│   │   ├── Auth/           # Controladores de autenticación
│   │   ├── AccessControl/  # Controladores de roles y permisos
│   │   └── Dashboard/      # Controladores del dashboard
│   ├── Models/             # Modelos de datos
│   ├── Services/           # Servicios de negocio
│   └── Http/Resources/     # Recursos de API
├── database/
│   ├── migrations/         # Migraciones de base de datos
│   └── seeders/           # Seeders con datos iniciales
└── routes/
    └── api.php            # Rutas de la API
```

### Frontend (Flutter)
```
tourcap_capachica/
├── lib/
│   ├── config/            # Configuración de la aplicación
│   ├── models/            # Modelos de datos
│   ├── services/          # Servicios de API
│   ├── providers/         # Providers de estado
│   ├── screens/           # Pantallas de la aplicación
│   ├── widgets/           # Widgets reutilizables
│   └── utils/             # Utilidades
└── assets/
    └── images/            # Imágenes de la aplicación
```

## Funcionalidades

### Autenticación
- Login con email y contraseña
- Registro de usuarios
- Gestión de roles (admin, user, emprendedor)
- Logout seguro

### Dashboard de Administrador
- Estadísticas generales del sistema
- Gestión de usuarios
- Gestión de emprendedores
- Acciones rápidas

### Gestión de Emprendedores
- Lista de emprendedores
- Crear/editar emprendedores
- Eliminar emprendedores
- Gestión de servicios

## API Endpoints

### Autenticación
- `POST /api/login` - Iniciar sesión
- `POST /api/register` - Registrar usuario
- `POST /api/logout` - Cerrar sesión
- `GET /api/profile` - Obtener perfil del usuario

### Dashboard
- `GET /api/dashboard/summary` - Estadísticas del dashboard

### Emprendedores
- `GET /api/emprendedores` - Listar emprendedores
- `POST /api/emprendedores` - Crear emprendedor
- `PUT /api/emprendedores/{id}` - Actualizar emprendedor
- `DELETE /api/emprendedores/{id}` - Eliminar emprendedor

## Desarrollo

### Ejecutar la aplicación
```bash
flutter run
```

### Ejecutar en modo debug
```bash
flutter run --debug
```

### Construir APK
```bash
flutter build apk
```

## Notas Importantes

1. **Configuración de Red**: Asegúrate de que la IP configurada en `api_config.dart` sea accesible desde el emulador o dispositivo físico.

2. **CORS**: El backend Laravel debe estar configurado para permitir peticiones desde la aplicación móvil.

3. **SSL**: En desarrollo, es posible que necesites configurar el backend para aceptar conexiones HTTP sin SSL.

4. **Base de Datos**: Asegúrate de que PostgreSQL esté corriendo y accesible.

## Troubleshooting

### Error de conexión
- Verificar que el backend esté corriendo en el puerto correcto
- Verificar la IP configurada en `api_config.dart`
- Verificar la configuración de red del emulador/dispositivo

### Error de autenticación
- Verificar las credenciales del administrador
- Verificar que el seeder se haya ejecutado correctamente
- Verificar la configuración de Sanctum en Laravel

### Error de permisos
- Verificar que los roles y permisos se hayan creado correctamente
- Verificar que el usuario tenga el rol de administrador asignado
