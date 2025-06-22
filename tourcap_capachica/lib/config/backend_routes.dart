/// Configuración de rutas del backend Laravel
/// Basado en el archivo routes/api.php
class BackendRoutes {
  // ===== RUTAS PÚBLICAS =====
  
  // Autenticación
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile';
  
  // Verificación de correo
  static const String emailVerify = '/email/verify/{id}/{hash}';
  
  // Recuperación de contraseña
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // ===== RUTAS PÚBLICAS DEL SISTEMA =====
  
  // Municipalidades
  static const String municipalidades = '/municipalidad';
  static const String municipalidadById = '/municipalidad/{id}';
  
  // Reseñas
  static const String resenas = '/resenas';
  static const String resenasByEmprendedor = '/resenas/emprendedor/{id}';
  
  // Sliders
  static const String sliders = '/sliders';
  static const String sliderById = '/sliders/{id}';
  
  // Asociaciones
  static const String asociaciones = '/asociaciones';
  static const String asociacionById = '/asociaciones/{id}';
  
  // Emprendedores
  static const String emprendedores = '/emprendedores';
  static const String emprendedorById = '/emprendedores/{id}';
  static const String emprendedoresByCategoria = '/emprendedores/categoria/{categoria}';
  static const String emprendedoresByAsociacion = '/emprendedores/asociacion/{asociacionId}';
  static const String emprendedoresSearch = '/emprendedores/search';
  
  // Servicios
  static const String servicios = '/servicios';
  static const String serviciosByEmprendedor = '/servicios/emprendedor/{emprendedorId}';
  static const String serviciosByCategoria = '/servicios/categoria/{categoriaId}';
  static const String serviciosVerificarDisponibilidad = '/servicios/verificar-disponibilidad';
  static const String serviciosByUbicacion = '/servicios/ubicacion';
  
  // Categorías
  static const String categorias = '/categorias';
  static const String categoriaById = '/categorias/{id}';
  
  // Búsqueda de usuarios
  static const String usersSearch = '/users/search';
  
  // Eventos
  static const String eventos = '/eventos';
  static const String eventosProximos = '/eventos/proximos';
  static const String eventosActivos = '/eventos/activos';
  static const String eventosByEmprendedor = '/eventos/emprendedor/{emprendedorId}';
  
  // Planes
  static const String planes = '/planes';
  static const String planesPublicos = '/planes/publicos';
  static const String planesSearch = '/planes/search';
  static const String planesByEmprendedor = '/planes/{id}/emprendedores';
  
  // ===== RUTAS PROTEGIDAS =====
  
  // Menú dinámico
  static const String menu = '/menu';
  
  // Mis Emprendimientos
  static const String misEmprendimientos = '/mis-emprendimientos';
  static const String misEmprendimientosById = '/mis-emprendimientos/{id}';
  static const String misEmprendimientosDashboard = '/mis-emprendimientos/{id}/dashboard';
  static const String misEmprendimientosCalendario = '/mis-emprendimientos/{id}/calendario';
  static const String misEmprendimientosServicios = '/mis-emprendimientos/{id}/servicios';
  static const String misEmprendimientosReservas = '/mis-emprendimientos/{id}/reservas';
  
  // Inscripciones
  static const String inscripciones = '/inscripciones';
  static const String misInscripciones = '/inscripciones/mis-inscripciones';
  static const String inscripcionesProximas = '/inscripciones/proximas';
  static const String inscripcionesEnProgreso = '/inscripciones/en-progreso';
  
  // Reservas
  static const String reservas = '/reservas';
  static const String reservasCarrito = '/reservas/carrito';
  static const String reservasCarritoAgregar = '/reservas/carrito/agregar';
  static const String reservasCarritoEliminar = '/reservas/carrito/servicio/{id}';
  static const String reservasCarritoConfirmar = '/reservas/carrito/confirmar';
  static const String reservasCarritoVaciar = '/reservas/carrito/vaciar';
  static const String misReservas = '/reservas/mis-reservas';
  static const String reservasByEmprendedor = '/reservas/emprendedor/{emprendedorId}';
  static const String reservasByServicio = '/reservas/servicio/{servicioId}';
  
  // ===== RUTAS DE ADMINISTRACIÓN =====
  
  // Roles
  static const String roles = '/roles';
  static const String roleById = '/roles/{id}';
  
  // Permisos
  static const String permissions = '/permissions';
  static const String userPermissions = '/users/{id}/permissions';
  static const String assignPermissionsToUser = '/permissions/assign-to-user';
  static const String assignPermissionsToRole = '/permissions/assign-to-role';
  
  // Usuarios
  static const String users = '/users';
  static const String userById = '/users/{id}';
  static const String userActivate = '/users/{id}/activate';
  static const String userDeactivate = '/users/{id}/deactivate';
  static const String userRoles = '/users/{id}/roles';
  static const String userProfilePhoto = '/users/{id}/profile-photo';
  
  // Dashboard
  static const String dashboard = '/dashboard';
  static const String dashboardSummary = '/dashboard/summary';
  
  // Admin Planes
  static const String adminPlanes = '/admin/planes';
  static const String adminPlanesTodos = '/admin/planes/todos';
  static const String adminPlanesEstadisticas = '/admin/planes/estadisticas-generales';
  static const String adminPlanesInscripciones = '/admin/planes/inscripciones/todas';
  
  // Status
  static const String status = '/status';
} 