import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';
  final String _userKey = 'user_data';
  final String _roleKey = 'user_role';
  final _baseUrl = ApiConfig.baseUrl;

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        throw Exception('Error de autenticación: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Register user
  Future<User?> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getRegisterUrl()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'rol': 'REGULAR', // Por defecto registramos usuarios regulares
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        String token = data['token'] as String;
        
        // Imprimir para depuración
        print('Token recibido del servidor en register: $token');
        
        // Quitar el prefijo 'Bearer ' si ya viene incluido
        if (token.startsWith('Bearer ')) {
          token = token.substring(7);
          print('Token sin prefijo Bearer en register: $token');
        }
        
        // Crear usuario a partir de la información del token o respuesta
        final userId = data['id'] ?? 1;
        final isAdmin = false; // Por defecto los usuarios registrados no son admin
        
        final user = User(
          id: userId,
          username: username,
          email: email,
          isAdmin: isAdmin,
          token: token,
        );
        
        // Guardar datos en el almacenamiento seguro
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
        await _storage.write(key: _roleKey, value: 'REGULAR');
        
        return user;
      } else {
        print('Error en registro: ${response.body}');
        throw Exception('Error en el registro: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en register: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: _userKey);
      final token = await _storage.read(key: _tokenKey);
      
      if (userData != null && token != null) {
        final user = User.fromJson(json.decode(userData));
        
        // Verificar si el token sigue siendo válido
        // Aquí podríamos implementar una verificación con el backend
        // Por ahora, simplemente devolvemos el usuario si hay token
        
        return user;
      }
      return null;
    } catch (e) {
      print('Error en getCurrentUser: $e');
      return null;
    }
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // No se usa refresh token en esta versión simplificada
  
  // Get authorization header with Bearer token
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    
    // Si el token ya incluye 'Bearer ', usarlo tal cual, de lo contrario agregarlo
    final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
    
    // Imprimir para depuración
    print('Enviando token: $authHeader');
    
    return {
      'Content-Type': 'application/json',
      'Authorization': authHeader,
    };
  }

  // Guardar datos de usuario y token
  Future<void> saveUserData(User user, String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
      await _storage.write(key: _roleKey, value: user.isAdmin ? 'ADMIN' : 'REGULAR');
    } catch (e) {
      print('Error al guardar datos de usuario: $e');
      throw Exception('Error al guardar datos de usuario: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    // Implementar lógica de logout si es necesario
  }

  // Check if user is logged in
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _userKey);
  }
}
