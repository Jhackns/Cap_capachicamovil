import 'environment.dart';
import 'backend_routes.dart';

class ApiConfig {
  // Usar la configuración de entorno para la URL base
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  static const String apiPrefix = '/api';
  
  // Endpoints de autenticación (usando BackendRoutes)
  static const String login = BackendRoutes.login;
  static const String register = BackendRoutes.register;
  static const String logout = BackendRoutes.logout;
  static const String profile = BackendRoutes.profile;
  
  // Endpoints de emprendedores
  static const String entrepreneurs = BackendRoutes.emprendedores;
  
  // Endpoints de dashboard
  static const String dashboard = BackendRoutes.dashboard;
  static const String dashboardSummary = BackendRoutes.dashboardSummary;

  // Rutas completas para uso directo
  static String getLoginUrl() => '$baseUrl$apiPrefix$login';
  static String getRegisterUrl() => '$baseUrl$apiPrefix$register';
  static String getLogoutUrl() => '$baseUrl$apiPrefix$logout';
  static String getProfileUrl() => '$baseUrl$apiPrefix$profile';
  static String getEntrepreneursUrl() => '$baseUrl$apiPrefix$entrepreneurs';
  static String getDashboardUrl() => '$baseUrl$apiPrefix$dashboard';
  static String getDashboardSummaryUrl() => '$baseUrl$apiPrefix$dashboardSummary';
  
  static String getEntrepreneurByIdUrl(int id) => '$baseUrl$apiPrefix${BackendRoutes.emprendedorById.replaceAll('{id}', id.toString())}';
  
  // Endpoints adicionales según las rutas del backend
  static String getUsersUrl() => '$baseUrl$apiPrefix${BackendRoutes.users}';
  static String getRolesUrl() => '$baseUrl$apiPrefix${BackendRoutes.roles}';
  static String getPermissionsUrl() => '$baseUrl$apiPrefix${BackendRoutes.permissions}';
  
  // Endpoints de municipalidades
  static String getMunicipalidadesUrl() => '$baseUrl$apiPrefix${BackendRoutes.municipalidades}';
  
  // Endpoints de categorías
  static String getCategoriasUrl() => '$baseUrl$apiPrefix${BackendRoutes.categorias}';
  
  // Endpoints de servicios
  static String getServiciosUrl() => '$baseUrl$apiPrefix${BackendRoutes.servicios}';
  
  // Endpoints de eventos
  static String getEventosUrl() => '$baseUrl$apiPrefix${BackendRoutes.eventos}';
  
  // Endpoints de planes
  static String getPlanesUrl() => '$baseUrl$apiPrefix${BackendRoutes.planes}';
  static String getPlanesPublicosUrl() => '$baseUrl$apiPrefix${BackendRoutes.planesPublicos}';
  
  // Endpoints de reservas
  static String getReservasUrl() => '$baseUrl$apiPrefix${BackendRoutes.reservas}';
  static String getMisReservasUrl() => '$baseUrl$apiPrefix${BackendRoutes.misReservas}';
  
  // Endpoints de inscripciones
  static String getInscripcionesUrl() => '$baseUrl$apiPrefix${BackendRoutes.inscripciones}';
  static String getMisInscripcionesUrl() => '$baseUrl$apiPrefix${BackendRoutes.misInscripciones}';
}