# Estructura del Proyecto Backend

## Organización de Carpetas

### 📁 `controller/`
Contiene todos los controladores REST organizados por funcionalidad:

#### 📁 `turismo/`
Controladores relacionados con la funcionalidad de turismo:
- **`AlojamientosController.java`** - Gestión de alojamientos
- **`AlojamientoServicioController.java`** - Servicios de alojamientos
- **`CategoriaAlojamientoController.java`** - Categorías de alojamientos
- **`DireccionController.java`** - Gestión de direcciones
- **`DisponibilidadController.java`** - Disponibilidad de alojamientos
- **`EmprendedorController.java`** - Gestión de emprendedores
- **`ExperienciasController.java`** - Experiencias turísticas
- **`FavoritosController.java`** - Favoritos de usuarios
- **`FotoAlojamientoController.java`** - Fotos de alojamientos
- **`MensajesController.java`** - Sistema de mensajería
- **`PagosController.java`** - Gestión de pagos
- **`ReportesController.java`** - Reportes del sistema
- **`ResenasController.java`** - Reseñas de alojamientos
- **`ReservaController.java`** - Reservas de alojamientos
- **`Reservas_ExperienciasController.java`** - Reservas de experiencias
- **`ServicioController.java`** - Gestión de servicios
- **`MigracionController.java`** - Controlador de migración

### 📁 `auth/`
Entidades y servicios relacionados con autenticación:
- **`entity/`**
  - `Rol.java` - Entidad de roles
  - `Permiso.java` - Entidad de permisos
- **`service/`**
  - `RolService.java` - Servicio de roles
  - `RolServiceImpl.java` - Implementación del servicio de roles
- **`repository/`**
  - `RolRepository.java` - Repositorio de roles
  - `PermisoRepository.java` - Repositorio de permisos
- **`controller/`**
  - `AuthController.java` - Login y registro de usuarios

### 📁 `admin/`
Controladores de administración:
- **`controller/`**
  - `UsuarioAdminController.java` - CRUD de usuarios (admin)
  - `RolAdminController.java` - Gestión de roles (admin)

### 📁 `entity/`
Entidades del dominio de negocio:
- `Usuario.java` - Entidad de usuario
- `Alojamiento.java` - Entidad de alojamiento
- `Alojamientos.java` - Entidad de alojamientos
- `AlojamientoServicio.java` - Servicios de alojamiento
- `CategoriaAlojamiento.java` - Categorías de alojamiento
- `Direccion.java` - Direcciones
- `Disponibilidad.java` - Disponibilidad
- `Emprendedor.java` - Emprendedores
- `Experiencias.java` - Experiencias turísticas
- `Favoritos.java` - Favoritos
- `FotoAlojamiento.java` - Fotos de alojamientos
- `Mensajes.java` - Mensajes
- `Pagos.java` - Pagos
- `Reportes.java` - Reportes
- `Resenas.java` - Reseñas
- `Reserva.java` - Reservas
- `Reservas_Experiencias.java` - Reservas de experiencias
- `Servicio.java` - Servicios
- `UserRole.java` - Enum de roles de usuario

### 📁 `service/`
Servicios de negocio organizados por funcionalidad

### 📁 `repository/`
Repositorios de acceso a datos

### 📁 `config/`
Configuraciones de Spring Boot

### 📁 `security/`
Configuraciones de seguridad y JWT

## Endpoints Principales

### Autenticación
- `POST /api/auth/register` - Registro de usuarios
- `POST /api/auth/login` - Login de usuarios
- `GET /api/auth/roles` - Obtener roles disponibles

### Gestión de Usuarios (Admin)
- `GET /api/admin/usuarios` - Listar usuarios
- `GET /api/admin/usuarios/{id}` - Obtener usuario
- `POST /api/admin/usuarios` - Crear usuario
- `PUT /api/admin/usuarios/{id}` - Actualizar usuario
- `DELETE /api/admin/usuarios/{id}` - Eliminar usuario

### Gestión de Roles (Admin)
- `GET /api/admin/roles` - Listar roles
- `GET /api/admin/roles/{id}` - Obtener rol
- `POST /api/admin/roles` - Crear rol
- `PUT /api/admin/roles/{id}` - Actualizar rol
- `DELETE /api/admin/roles/{id}` - Eliminar rol
- `POST /api/admin/roles/init` - Inicializar roles básicos

### Turismo
- `GET /api/alojamientos` - Listar alojamientos
- `GET /api/experiencias` - Listar experiencias
- `GET /api/reservas` - Listar reservas
- Y otros endpoints específicos de cada entidad

## Problemas Resueltos

### ✅ Conflictos de Beans
- **Problema**: Había controladores y repositorios duplicados con el mismo nombre
- **Solución**: Eliminé los duplicados y mantuve solo los que están en los paquetes correctos

### ✅ Imports Incorrectos
- **Problema**: Los servicios y repositorios importaban entidades desde paquetes incorrectos
- **Solución**: Corregí todos los imports para que apunten a `auth.entity`

### ✅ Estructura Organizada
- **Problema**: Código desorganizado y duplicado
- **Solución**: Reorganicé la estructura en carpetas específicas por funcionalidad

## Beneficios de la Nueva Estructura

1. **Separación de Responsabilidades**: Autenticación separada de funcionalidad de turismo
2. **Mantenibilidad**: Código organizado y fácil de mantener
3. **Escalabilidad**: Fácil agregar nuevas funcionalidades
4. **Claridad**: Estructura clara y comprensible
5. **Reutilización**: Evita duplicación de código
6. **Sin Conflictos**: No hay beans duplicados

## Notas Importantes

- Se eliminaron todos los controladores y repositorios duplicados
- Se corrigieron todos los imports para usar las entidades correctas
- Se mantiene la compatibilidad con el frontend existente
- Los endpoints están organizados por funcionalidad
- La aplicación compila correctamente sin errores 