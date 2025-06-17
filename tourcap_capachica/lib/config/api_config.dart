class ApiConfig {
  // Para el emulador de Android, usamos 10.0.2.2 en lugar de localhost (equivalente a localhost en el emulador)
  static const String baseUrl = 'http://192.168.1.64:8080';
  static const String apiPrefix = '/api';
  
  // Endpoints
  static const String entrepreneurs = '/emprendedores';
  static const String login = '/users/login';
  static const String register = '/users/register';

  // Rutas completas para uso directo
  static String getEntrepreneursUrl() {
    return '$baseUrl$apiPrefix$entrepreneurs';
  }
  
  static String getEntrepreneurByIdUrl(int id) {
    return '$baseUrl$apiPrefix$entrepreneurs/$id';
  }
  
  static String getLoginUrl() => '$baseUrl$apiPrefix$login';
  static String getRegisterUrl() => '$baseUrl$apiPrefix$register';
}