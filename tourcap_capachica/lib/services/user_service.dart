import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/backend_routes.dart';
import '../utils/error_handler.dart';

class UserService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    return await ApiConfig.token;
  }

  Future<List<Map<String, dynamic>>> getUsers({Map<String, dynamic>? filters}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final queryParams = <String, String>{};
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            queryParams[key] = value.toString();
          }
        });
      }

      final uri = Uri.parse('$_baseUrl${BackendRoutes.users}').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener usuarios');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${BackendRoutes.userSearch}?q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Error al buscar usuarios');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${BackendRoutes.users}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener usuario');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${BackendRoutes.users}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al crear usuario');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final url = '$_baseUrl${BackendRoutes.users}/$id';
      print('🔄 === ACTUALIZANDO USUARIO ===');
      print('URL: $url');
      print('ID: $id');
      print('Token: ${token.isNotEmpty ? "Presente" : "NULO"}');
      print('Datos a enviar: $userData');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Usuario actualizado exitosamente');
          return Map<String, dynamic>.from(data['data']);
        } else {
          print('❌ Error en respuesta: ${data['message']}');
          throw Exception(data['message'] ?? 'Error al actualizar usuario');
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Excepción: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final url = '$_baseUrl${BackendRoutes.users}/$id';
      print('🗑️ === ELIMINANDO USUARIO ===');
      print('URL: $url');
      print('ID: $id');
      print('Token: ${token.isNotEmpty ? "Presente" : "NULO"}');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        print('❌ Error al eliminar: ${data['message']}');
        throw Exception(data['message'] ?? 'Error al eliminar usuario');
      }
      
      print('✅ Usuario eliminado exitosamente');
    } catch (e) {
      print('❌ Excepción al eliminar: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> activateUser(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${BackendRoutes.users}/$id/activate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al activar usuario');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> deactivateUser(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${BackendRoutes.users}/$id/deactivate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al desactivar usuario');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
} 