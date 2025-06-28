/// Configuración de rutas del backend Laravel
/// Basado en el archivo routes/api.php
class BackendRoutes {
  // ===== RUTAS PÚBLICAS =====
  
  // Autenticación
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String profile = '/api/profile';
  
  // Verificación de correo
  static const String verifyEmail = '/api/email/verify';
  static const String resendVerification = '/api/email/verification-notification';
  
  // Recuperación de contraseña
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password';
  
  // Google Auth routes
  static const String googleAuth = '/api/auth/google';
  static const String googleCallback = '/api/auth/google/callback';
  static const String googleVerifyToken = '/api/auth/google/verify-token';
  
  // ===== RUTAS PÚBLICAS DEL SISTEMA =====
  
  // Municipalidades
  static const String municipalidades = '/api/municipalidad';
  static const String municipalidadById = '/municipalidad/{id}';
  
  // Reseñas
  static const String resenas = '/api/resenas';
  static const String resenasByEmprendedor = '/resenas/emprendedor/{id}';
  
  // Sliders
  static const String sliders = '/api/sliders';
  static const String sliderById = '/sliders/{id}';
  
  // Asociaciones
  static const String asociaciones = '/api/asociaciones';
  static const String asociacionById = '/asociaciones/{id}';
  
  // Emprendedores
  static const String emprendedores = '/api/emprendedores';
  static const String emprendedorById = '/emprendedores/{id}';
  static const String emprendedoresByCategoria = '/emprendedores/categoria/{categoria}';
  static const String emprendedoresByAsociacion = '/emprendedores/asociacion/{asociacionId}';
  static const String emprendedoresSearch = '/emprendedores/search';
  
  // Servicios
  static const String servicios = '/api/servicios';
  static const String serviciosByEmprendedor = '/servicios/emprendedor/{emprendedorId}';
  static const String serviciosByCategoria = '/servicios/categoria/{categoriaId}';
  static const String serviciosVerificarDisponibilidad = '/servicios/verificar-disponibilidad';
  static const String serviciosByUbicacion = '/servicios/ubicacion';
  
  // Categorías
  static const String categorias = '/api/categorias';
  static const String categoriaById = '/categorias/{id}';
  
  // Búsqueda de usuarios
  static const String userSearch = '/api/users/search';
  
  // Eventos
  static const String eventos = '/api/eventos';
  static const String eventosProximos = '/eventos/proximos';
  static const String eventosActivos = '/eventos/activos';
  static const String eventosByEmprendedor = '/eventos/emprendedor/{emprendedorId}';
  
  // Planes
  static const String planes = '/api/planes';
  static const String planesPublicos = '/api/public/planes';
  static const String planesSearch = '/planes/search';
  static const String planesByEmprendedor = '/planes/{id}/emprendedores';
  
  // ===== RUTAS PROTEGIDAS =====
  
  // Menú dinámico
  static const String menu = '/api/menu';
  
  // Mis Emprendimientos
  static const String misEmprendimientos = '/api/mis-emprendimientos';
  static const String misEmprendimientosById = '/mis-emprendimientos/{id}';
  static const String misEmprendimientosDashboard = '/mis-emprendimientos/{id}/dashboard';
  static const String misEmprendimientosCalendario = '/mis-emprendimientos/{id}/calendario';
  static const String misEmprendimientosServicios = '/mis-emprendimientos/{id}/servicios';
  static const String misEmprendimientosReservas = '/mis-emprendimientos/{id}/reservas';
  
  // Inscripciones
  static const String inscripciones = '/api/inscripciones';
  static const String misInscripciones = '/api/inscripciones/mis-inscripciones';
  static const String inscripcionesProximas = '/inscripciones/proximas';
  static const String inscripcionesEnProgreso = '/inscripciones/en-progreso';
  
  // Reservas
  static const String reservas = '/api/reservas';
  static const String reservasCarrito = '/reservas/carrito';
  static const String reservasCarritoAgregar = '/reservas/carrito/agregar';
  static const String reservasCarritoEliminar = '/reservas/carrito/servicio/{id}';
  static const String reservasCarritoConfirmar = '/reservas/carrito/confirmar';
  static const String reservasCarritoVaciar = '/reservas/carrito/vaciar';
  static const String misReservas = '/api/reservas/mis-reservas';
  static const String reservasByEmprendedor = '/reservas/emprendedor/{emprendedorId}';
  static const String reservasByServicio = '/reservas/servicio/{servicioId}';
  
  // Reserva Servicios
  static const String reservaServicios = '/api/reserva-servicios';
  static const String reservaServiciosByReserva = '/reserva-servicios/reserva/{reservaId}';
  static const String reservaServiciosEstado = '/reserva-servicios/{id}/estado';
  static const String reservaServiciosCalendario = '/reserva-servicios/calendario';
  static const String reservaServiciosVerificarDisponibilidad = '/reserva-servicios/verificar-disponibilidad';
  
  // ===== RUTAS DE ADMINISTRACIÓN =====
  
  // Roles
  static const String roles = '/api/roles';
  static const String roleById = '/roles/{id}';
  
  // Permisos
  static const String permissions = '/api/permissions';
  static const String userPermissions = '/api/users/{id}/permissions';
  static const String assignPermissionsToUser = '/permissions/assign-to-user';
  static const String assignPermissionsToRole = '/permissions/assign-to-role';
  
  // Usuarios
  static const String users = '/api/users';
  static const String userById = '/users/{id}';
  static const String userActivate = '/users/{id}/activate';
  static const String userDeactivate = '/users/{id}/deactivate';
  static const String userRoles = '/users/{id}/roles';
  static const String userProfilePhoto = '/users/{id}/profile-photo';
  
  // Dashboard
  static const String dashboard = '/dashboard';
  static const String dashboardSummary = '/api/dashboard/summary';
  
  // Admin Planes
  static const String adminPlanes = '/admin/planes';
  static const String adminPlanesTodos = '/admin/planes/todos';
  static const String adminPlanesEstadisticas = '/admin/planes/estadisticas-generales';
  static const String adminPlanesInscripciones = '/admin/planes/inscripciones/todas';
  
  // Status
  static const String status = '/api/status';
  static const String testAuth = '/api/test-auth';
} 