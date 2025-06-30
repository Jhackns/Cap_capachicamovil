import '../config/backend_routes.dart';
import '../services/auth_service.dart';

class ApiConfig {
  // URL base del backend
  static const String baseUrl = 'http://192.168.195.160:8000';
  
  // Token de autenticación
  static Future<String?> get token async {
    final authService = AuthService();
    return await authService.getToken();
  }
  
  // Endpoints de autenticación
  static String getLoginUrl() => '$baseUrl${BackendRoutes.login}';
  static String getRegisterUrl() => '$baseUrl${BackendRoutes.register}';
  static String getLogoutUrl() => '$baseUrl${BackendRoutes.logout}';
  static String getProfileUrl() => '$baseUrl${BackendRoutes.profile}';
  static String getVerifyEmailUrl() => '$baseUrl${BackendRoutes.verifyEmail}';
  static String getResendVerificationUrl() => '$baseUrl${BackendRoutes.resendVerification}';
  static String getForgotPasswordUrl() => '$baseUrl${BackendRoutes.forgotPassword}';
  static String getResetPasswordUrl() => '$baseUrl${BackendRoutes.resetPassword}';
  static String getGoogleAuthUrl() => '$baseUrl${BackendRoutes.googleAuth}';
  static String getGoogleCallbackUrl() => '$baseUrl${BackendRoutes.googleCallback}';
  static String getGoogleVerifyTokenUrl() => '$baseUrl${BackendRoutes.googleVerifyToken}';

  // Endpoints de usuarios
  static String getUsersUrl() => '$baseUrl${BackendRoutes.users}';
  static String getUserByIdUrl(int id) => '$baseUrl${BackendRoutes.userById.replaceAll('{id}', id.toString())}';
  static String getUserActivateUrl(int id) => '$baseUrl${BackendRoutes.userActivate.replaceAll('{id}', id.toString())}';
  static String getUserDeactivateUrl(int id) => '$baseUrl${BackendRoutes.userDeactivate.replaceAll('{id}', id.toString())}';
  static String getUserRolesUrl(int id) => '$baseUrl${BackendRoutes.userRoles.replaceAll('{id}', id.toString())}';
  static String getUserProfilePhotoUrl(int id) => '$baseUrl${BackendRoutes.userProfilePhoto.replaceAll('{id}', id.toString())}';
  static String getUserSearchUrl() => '$baseUrl${BackendRoutes.userSearch}';

  // Endpoints de roles
  static String getRolesUrl() => '$baseUrl${BackendRoutes.roles}';
  static String getRoleByIdUrl(int id) => '$baseUrl${BackendRoutes.roleById.replaceAll('{id}', id.toString())}';

  // Endpoints de permisos
  static String getPermissionsUrl() => '$baseUrl${BackendRoutes.permissions}';
  static String getUserPermissionsUrl(int id) => '$baseUrl${BackendRoutes.userPermissions.replaceAll('{id}', id.toString())}';
  static String getAssignPermissionsToUserUrl() => '$baseUrl${BackendRoutes.assignPermissionsToUser}';
  static String getAssignPermissionsToRoleUrl() => '$baseUrl${BackendRoutes.assignPermissionsToRole}';

  // Endpoints de municipalidades
  static String getMunicipalidadesUrl() => '$baseUrl${BackendRoutes.municipalidades}';
  static String getMunicipalidadUrl(int id) => '$baseUrl${BackendRoutes.municipalidadById.replaceAll('{id}', id.toString())}';

  // Endpoints de emprendedores
  static String getEmprendedoresUrl() => '$baseUrl${BackendRoutes.emprendedores}';
  static String getEmprendedorByIdUrl(int id) => '$baseUrl${BackendRoutes.emprendedorById.replaceAll('{id}', id.toString())}';
  static String getEmprendedoresByCategoriaUrl(String categoria) => '$baseUrl${BackendRoutes.emprendedoresByCategoria.replaceAll('{categoria}', categoria)}';
  static String getEmprendedoresByAsociacionUrl(int asociacionId) => '$baseUrl${BackendRoutes.emprendedoresByAsociacion.replaceAll('{asociacionId}', asociacionId.toString())}';
  static String getEmprendedoresSearchUrl() => '$baseUrl${BackendRoutes.emprendedoresSearch}';

  // Endpoints de asociaciones
  static String getAsociacionesUrl() => '$baseUrl${BackendRoutes.asociaciones}';
  static String getAsociacionByIdUrl(int id) => '$baseUrl${BackendRoutes.asociacionById.replaceAll('{id}', id.toString())}';

  // Endpoints de categorías
  static String getCategoriasUrl() => '$baseUrl${BackendRoutes.categorias}';
  static String getCategoriaByIdUrl(int id) => '$baseUrl${BackendRoutes.categoriaById.replaceAll('{id}', id.toString())}';

  // Endpoints de servicios (rutas públicas)
  static String getServiciosUrl() => '$baseUrl${BackendRoutes.servicios}';
  static String getServiciosByEmprendedorUrl(int emprendedorId) => '$baseUrl${BackendRoutes.serviciosByEmprendedor.replaceAll('{emprendedorId}', emprendedorId.toString())}';
  static String getServiciosByCategoriaUrl(int categoriaId) => '$baseUrl${BackendRoutes.serviciosByCategoria.replaceAll('{categoriaId}', categoriaId.toString())}';
  static String getServiciosVerificarDisponibilidadUrl() => '$baseUrl${BackendRoutes.serviciosVerificarDisponibilidad}';
  static String getServiciosByUbicacionUrl() => '$baseUrl${BackendRoutes.serviciosByUbicacion}';

  // Endpoints de eventos (rutas públicas)
  static String getEventosUrl() => '$baseUrl${BackendRoutes.eventos}';
  static String getEventosProximosUrl() => '$baseUrl${BackendRoutes.eventosProximos}';
  static String getEventosActivosUrl() => '$baseUrl${BackendRoutes.eventosActivos}';
  static String getEventosByEmprendedorUrl(int emprendedorId) => '$baseUrl${BackendRoutes.eventosByEmprendedor.replaceAll('{emprendedorId}', emprendedorId.toString())}';

  // Endpoints de planes
  static String getPlanesUrl() => '$baseUrl${BackendRoutes.planes}';
  static String getPlanByIdUrl(int id) => '$baseUrl${BackendRoutes.planes}/$id';
  static String getPlanesPublicosUrl() => '$baseUrl${BackendRoutes.planesPublicos}';
  static String getPlanesSearchUrl() => '$baseUrl${BackendRoutes.planesSearch}';
  static String getPlanesByEmprendedorUrl(int id) => '$baseUrl${BackendRoutes.planesByEmprendedor.replaceAll('{id}', id.toString())}';

  // Endpoints de reservas (rutas protegidas)
  static String getReservasUrl() => '$baseUrl${BackendRoutes.reservas}';
  static String getMisReservasUrl() => '$baseUrl${BackendRoutes.misReservas}';

  // Endpoints de inscripciones (rutas protegidas)
  static String getInscripcionesUrl() => '$baseUrl${BackendRoutes.inscripciones}';
  static String getMisInscripcionesUrl() => '$baseUrl${BackendRoutes.misInscripciones}';

  // Endpoints de dashboard
  static String getDashboardSummaryUrl() => '$baseUrl${BackendRoutes.dashboardSummary}';

  // Endpoints de status y test
  static String getStatusUrl() => '$baseUrl${BackendRoutes.status}';
  static String getTestAuthUrl() => '$baseUrl${BackendRoutes.testAuth}';
}