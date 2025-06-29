import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ConnectivityService {
  // Probar conectividad básica con el backend
  static Future<bool> testBackendConnection() async {
    try {
      print('=== PRUEBA DE CONECTIVIDAD ===');
      print('URL base: ${ApiConfig.baseUrl}');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('ERROR: Timeout al conectar con el backend');
          throw Exception('Timeout: No se pudo conectar con el servidor');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('ERROR de conectividad: $e');
      return false;
    }
  }

  // Probar endpoint de status
  static Future<bool> testStatusEndpoint() async {
    try {
      print('=== PRUEBA ENDPOINT STATUS ===');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('ERROR: Timeout al conectar con status endpoint');
          throw Exception('Timeout: No se pudo conectar con el servidor');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Backend status: ${data['status']}');
        print('Backend version: ${data['version']}');
        return true;
      }
      
      return false;
    } catch (e) {
      print('ERROR en status endpoint: $e');
      return false;
    }
  }

  // Probar endpoint de login sin autenticación
  static Future<bool> testLoginEndpoint() async {
    try {
      print('=== PRUEBA ENDPOINT LOGIN ===');
      
      final response = await http.post(
        Uri.parse(ApiConfig.getLoginUrl()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'test@test.com',
          'password': 'wrongpassword',
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('ERROR: Timeout al conectar con login endpoint');
          throw Exception('Timeout: No se pudo conectar con el servidor');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      
      // Si recibimos una respuesta (aunque sea de error), el endpoint está funcionando
      return response.statusCode > 0;
    } catch (e) {
      print('ERROR en login endpoint: $e');
      return false;
    }
  }

  // Obtener información de diagnóstico completa
  static Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final results = {
      'baseUrl': ApiConfig.baseUrl,
      'loginUrl': ApiConfig.getLoginUrl(),
      'backendConnection': false,
      'statusEndpoint': false,
      'loginEndpoint': false,
      'errors': <String>[],
    };

    try {
      // Probar conectividad básica
      results['backendConnection'] = await testBackendConnection();
      if (results['backendConnection'] == false) {
        (results['errors'] as List<String>).add('No se puede conectar al backend');
      }

      // Probar endpoint de status
      results['statusEndpoint'] = await testStatusEndpoint();
      if (results['statusEndpoint'] == false) {
        (results['errors'] as List<String>).add('Endpoint de status no responde');
      }

      // Probar endpoint de login
      results['loginEndpoint'] = await testLoginEndpoint();
      if (results['loginEndpoint'] == false) {
        (results['errors'] as List<String>).add('Endpoint de login no responde');
      }

    } catch (e) {
      (results['errors'] as List<String>).add('Error general: $e');
    }

    return results;
  }

  // Método para ejecutar diagnóstico completo y devolver resultados formateados
  Future<Map<String, String>> runDiagnostics() async {
    final results = <String, String>{};
    
    try {
      // Probar conectividad básica
      final backendConnected = await testBackendConnection();
      results['backend_base'] = backendConnected ? 'Conectado' : 'Error de conexión';
      
      // Probar endpoint de login
      final loginConnected = await testLoginEndpoint();
      results['api_login'] = loginConnected ? 'Conectado' : 'Error de conexión';
      
      // Probar endpoint de usuarios (sin autenticación)
      try {
        final response = await http.get(
          Uri.parse(ApiConfig.getUsersUrl()),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        results['api_users'] = response.statusCode > 0 ? 'Conectado' : 'Error de conexión';
      } catch (e) {
        results['api_users'] = 'Error de conexión';
      }
      
      // Probar endpoint de roles (sin autenticación)
      try {
        final response = await http.get(
          Uri.parse(ApiConfig.getRolesUrl()),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        results['api_roles'] = response.statusCode > 0 ? 'Conectado' : 'Error de conexión';
      } catch (e) {
        results['api_roles'] = 'Error de conexión';
      }
      
    } catch (e) {
      results['backend_base'] = 'Error: $e';
      results['api_login'] = 'Error: $e';
      results['api_users'] = 'Error: $e';
      results['api_roles'] = 'Error: $e';
    }
    
    return results;
  }
} 