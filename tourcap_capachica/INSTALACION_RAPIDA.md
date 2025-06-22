# Instalación Rápida - Tour Capachica

## Pasos Rápidos para Configurar el Proyecto

### 1. Backend Laravel

```bash
# Navegar al directorio del backend
cd turismo-backend

# Instalar dependencias
composer install

# Copiar archivo de configuración
cp .env.example .env

# Configurar base de datos PostgreSQL en .env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=turismo_capachica
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

# Generar clave de aplicación
php artisan key:generate

# Ejecutar migraciones y seeders
php artisan migrate --seed

# Iniciar servidor
php artisan serve
```

### 2. Aplicación Flutter

```bash
# Navegar al directorio de la aplicación
cd tourcap_capachica

# Instalar dependencias
flutter pub get

# Configurar IP del backend en lib/config/api_config.dart
# Cambiar la IP según tu configuración de red

# Ejecutar aplicación
flutter run
```

## Credenciales de Prueba

### Administrador
- **Email**: `admin@turismo.com`
- **Password**: `password123`

### Usuario Alternativo
- **Email**: `admin@example.com`
- **Password**: `password`

## Verificación

1. **Backend**: Verificar que esté corriendo en `http://127.0.0.1:8000`
2. **Aplicación**: Verificar que se conecte al backend
3. **Login**: Probar login con credenciales de administrador
4. **Dashboard**: Verificar que se muestre el dashboard de administrador

## Solución de Problemas Comunes

### Error de Conexión
- Verificar que PostgreSQL esté corriendo
- Verificar configuración de red
- Verificar IP en `api_config.dart`

### Error de Autenticación
- Verificar que se ejecutó `php artisan migrate --seed`
- Verificar credenciales del administrador
- Verificar configuración de Sanctum

### Error de CORS
- Verificar configuración de CORS en Laravel
- Verificar que el backend esté en el puerto correcto

## Comandos Útiles

### Backend
```bash
# Limpiar cache
php artisan cache:clear
php artisan config:clear

# Ver rutas disponibles
php artisan route:list

# Verificar estado de la base de datos
php artisan migrate:status
```

### Flutter
```bash
# Limpiar cache
flutter clean
flutter pub get

# Ejecutar en modo debug
flutter run --debug

# Construir APK
flutter build apk
``` 