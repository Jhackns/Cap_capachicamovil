# 🏖️ Capachica Móvil - Manual de Usuario

## 📋 Descripción del Proyecto

Capachica Móvil es una aplicación de turismo desarrollada con **Flutter** para el frontend móvil y **Laravel** para el backend. La aplicación permite a los usuarios explorar y gestionar servicios turísticos en la región de Capachica.

## 🛠️ Requisitos Previos

### Software Necesario

Antes de comenzar, asegúrate de tener instalado:

- **PHP** (versión 8.0 o superior)
- **Composer** (gestor de dependencias de PHP)
- **PostgreSQL** (base de datos)
- **Node.js** (para algunas dependencias)
- **Android Studio** (editor de código para Flutter)
- **Flutter SDK** (framework de desarrollo móvil)

## 🚀 Configuración del Backend (Laravel)

### 1. Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd Capachica-movil/turismo-backend
```

### 2. Configurar Variables de Entorno

```bash
# Copiar el archivo de configuración de ejemplo
cp .env.example .env
```

### 3. Instalar PostgreSQL

1. Descarga e instala PostgreSQL desde [postgresql.org](https://www.postgresql.org/download/)
2. **IMPORTANTE**: Durante la instalación, establece la contraseña como: `123456`
3. Asegúrate de que PostgreSQL esté ejecutándose como servicio

### 4. Instalar Dependencias de PHP

```bash
# Instalar dependencias de Composer
composer install
```

### 5. Configurar la Base de Datos

```bash
# Crear las tablas en la base de datos
php artisan migrate

# Migrar y poblar la base de datos con datos de ejemplo
php artisan migrate:fresh --seed
```

### 6. Generar Clave de Aplicación

```bash
# Generar la llave maestra de Laravel
php artisan generate:key
```

### 7. Iniciar el Servidor Backend

**IMPORTANTE**: Usar PowerShell en Windows (no CMD)

```bash
# Iniciar el servidor Laravel
php artisan serve --host=0.0.0.0 --port=8000
```

Si todo está configurado correctamente, deberías ver un mensaje indicando que el servidor está ejecutándose en `http://0.0.0.0:8000`.

## 📱 Configuración de la Aplicación Móvil (Flutter)

### 1. Navegar al Directorio de la App

```bash
cd ../tourcap_capachica
```

### 2. Instalar Dependencias de Flutter

```bash
# Obtener todas las dependencias del proyecto
flutter pub get
```

### 3. Configurar la IP del Servidor

Debes actualizar la dirección IP del servidor backend en dos archivos:

#### Archivo: `lib/config/environment.dart`
Busca esta línea:
```dart
return 'http://192.168.1.64:8000';
```
Y cámbiala por tu IP local (mantén el puerto 8000):
```dart
return 'http://TU_IP_LOCAL:8000';
```

#### Archivo: `lib/config/api_config.dart`
Busca esta línea:
```dart
static const String baseUrl = 'http://192.168.1.64:8080';
```
Y cámbiala por tu IP local (mantén el puerto 8000):
```dart
static const String baseUrl = 'http://TU_IP_LOCAL:8000';
```

### 4. Configurar el Emulador o Dispositivo

#### Opción A: Emulador de Android
1. Abre Android Studio
2. Ve a **Tools > AVD Manager**
3. Crea un nuevo dispositivo virtual o usa uno existente
4. Inicia el emulador

#### Opción B: Dispositivo Físico
1. Habilita las **Opciones de desarrollador** en tu dispositivo Android
2. Activa la **Depuración USB**
3. Conecta tu dispositivo por USB
4. Acepta la instalación de aplicaciones desde tu computadora

### 5. Ejecutar la Aplicación

```bash
# Verificar que Flutter esté configurado correctamente
flutter doctor

# Ejecutar la aplicación
flutter run
```

Si todo está configurado correctamente, la aplicación debería compilar y ejecutarse sin errores.

## 🔧 Solución de Problemas Comunes

### Backend (Laravel)

**Error: "Class 'PDO' not found"**
- Instala la extensión PDO para PHP
- En Windows: descomenta `extension=pdo_pgsql` en `php.ini`

**Error: "Connection refused"**
- Verifica que PostgreSQL esté ejecutándose
- Confirma que la contraseña sea `123456`
- Revisa la configuración en el archivo `.env`

**Error: "Permission denied"**
- Ejecuta PowerShell como administrador
- Verifica los permisos de escritura en el directorio

### Aplicación Móvil (Flutter)

**Error: "Could not find a device"**
- Verifica que el emulador esté ejecutándose
- O que el dispositivo esté conectado y autorizado

**Error: "Connection timeout"**
- Verifica que la IP en `environment.dart` y `api_config.dart` sea correcta
- Confirma que el servidor backend esté ejecutándose
- Verifica que no haya firewall bloqueando la conexión

**Error: "Dependencies not found"**
- Ejecuta `flutter clean` seguido de `flutter pub get`
- Verifica que tengas una conexión a internet estable

## 📁 Estructura del Proyecto

```
Capachica-movil/
├── turismo-backend/          # Backend Laravel
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
└── tourcap_capachica/        # App Flutter
    ├── lib/
    │   ├── config/           # Configuraciones
    │   ├── screens/          # Pantallas de la app
    │   ├── services/         # Servicios API
    │   └── ...
    ├── assets/
    └── ...
```

## 🎯 Comandos Útiles

### Backend
```bash
# Ver logs de Laravel
php artisan log:clear

# Limpiar caché
php artisan cache:clear
php artisan config:clear

# Verificar estado de la aplicación
php artisan route:list
```

### Flutter
```bash
# Limpiar build
flutter clean

# Actualizar dependencias
flutter pub upgrade

# Ver dispositivos conectados
flutter devices

# Build para producción
flutter build apk
```

## 📞 Soporte

Si encuentras problemas durante la configuración:

1. Verifica que todos los requisitos previos estén instalados correctamente
2. Revisa los logs de error en la consola
3. Confirma que las versiones de software sean compatibles
4. Consulta la documentación oficial de Laravel y Flutter

---

**¡Disfruta desarrollando con Capachica Móvil! 🚀**
