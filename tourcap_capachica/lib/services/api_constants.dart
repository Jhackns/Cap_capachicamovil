class ApiConstants {
  // Base URL for the API
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Default for Android emulator to reach localhost
  
  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  
  // Entrepreneur endpoints
  static const String entrepreneurs = '$baseUrl/entrepreneurs';
  static String entrepreneurById(int id) => '$entrepreneurs/$id';
}
