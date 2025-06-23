import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import '../config/backend_routes.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';
  final String _userKey = 'user_data';
  final String _roleKey = 'user_role';

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final loginUrl = ApiConfig.getLoginUrl();
      print('=== INICIO DE LOGIN ===');
      print('URL de login: $loginUrl');
      print('Email: $email');
      print('Intentando conectar al backend...');
      
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('ERROR: Timeout al conectar con el backend');
          throw Exception('Timeout: No se pudo conectar con el servidor');
        },
      );

      print('=== RESPUESTA DEL SERVIDOR ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
          
          // Verificar si la respuesta es exitosa según el formato del backend Laravel
          if (data['success'] == false) {
            print('ERROR: Respuesta exitosa pero success = false');
            print('Mensaje: ${data['message']}');
            throw Exception(data['message'] ?? 'Error en la autenticación');
          }
          
          // Extraer datos de la respuesta
          final responseData = data['data'] ?? data;
          final accessToken = responseData['access_token'];
          final userData = responseData['user'];
          final roles = responseData['roles'] ?? [];
          
          print('Token recibido: ${accessToken != null ? 'SÍ' : 'NO'}');
          print('Datos de usuario: ${userData != null ? 'SÍ' : 'NO'}');
          print('Roles: $roles');
          
          if (accessToken == null) {
            print('ERROR: No se recibió el token de autenticación');
            throw Exception('No se recibió el token de autenticación');
          }
          
          // Crear usuario a partir de la respuesta
          final user = User.fromAuthResponse(responseData);
          
          print('Usuario creado exitosamente: ${user.name}');
          print('Es admin: ${user.isAdmin}');
          
          // Guardar el token y la información del usuario
          await _storage.write(key: _tokenKey, value: accessToken);
          await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
          await _storage.write(key: _roleKey, value: roles.isNotEmpty ? roles.first : 'user');
          
          print('=== LOGIN EXITOSO ===');
          
          return {
            'user': user,
            'token': accessToken,
            'roles': roles,
            'message': data['message'] ?? 'Inicio de sesión exitoso',
          };
        } catch (e) {
          print('ERROR al procesar la respuesta: $e');
          throw Exception('Error al procesar la respuesta del servidor: $e');
        }
      } else {
        print('ERROR: Status code no exitoso');
        String errorMessage = 'Error de autenticación (${response.statusCode})';
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message']?.toString() ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }
        print('Mensaje de error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('=== ERROR EN EL PROCESO DE LOGIN ===');
      print('Error: $e');
      rethrow;
    }
  }

  // Register user
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
    required DateTime birthDate,
    required String address,
    required String gender,
    required String language,
    File? profileImage,
  }) async {
    try {
      final registerUrl = ApiConfig.getRegisterUrl();
      print('=== INICIO DE REGISTRO ===');
      print('URL de registro: $registerUrl');
      print('URL base: ${ApiConfig.baseUrl}');
      print('API prefix: ${ApiConfig.apiPrefix}');
      print('Register route: ${BackendRoutes.register}');
      print('URL completa generada: $registerUrl');
      
      // Verificar que la URL sea accesible
      print('=== VERIFICANDO ACCESIBILIDAD DE LA URL ===');
      try {
        final testResponse = await http.get(Uri.parse(registerUrl));
        print('Test GET response status: ${testResponse.statusCode}');
        print('Test GET response body: ${testResponse.body}');
      } catch (e) {
        print('Error en test GET: $e');
      }
      
      // Crear request multipart si hay imagen de perfil
      http.Response response;
      
      if (profileImage != null) {
        var request = http.MultipartRequest('POST', Uri.parse(registerUrl));
        
        // Agregar campos de texto
        request.fields['name'] = name;
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.fields['password_confirmation'] = password;
        request.fields['phone'] = phone;
        request.fields['country'] = country;
        request.fields['birth_date'] = birthDate.toIso8601String();
        request.fields['address'] = address;
        request.fields['gender'] = gender;
        request.fields['preferred_language'] = language;
        
        print('=== DATOS ENVIADOS (MULTIPART) ===');
        print('name: $name');
        print('email: $email');
        print('phone: $phone');
        print('country: $country');
        print('birth_date: ${birthDate.toIso8601String()}');
        print('address: $address');
        print('gender: $gender');
        print('preferred_language: $language');
        print('profileImage: ${profileImage != null ? "SÍ" : "NO"}');
        
        // Agregar imagen de perfil
        final stream = http.ByteStream(profileImage.openRead());
        final length = await profileImage.length();
        final multipartFile = http.MultipartFile(
          'foto_perfil',
          stream,
          length,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
        
        // Agregar header Accept
        request.headers['Accept'] = 'application/json';
        
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Request normal sin imagen
        final requestBody = {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
          'country': country,
          'birth_date': birthDate.toIso8601String(),
          'address': address,
          'gender': gender,
          'preferred_language': language,
        };
        
        print('=== DATOS ENVIADOS (JSON) ===');
        print('Request body: ${json.encode(requestBody)}');
        
        response = await http.post(
          Uri.parse(registerUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(requestBody),
        );
      }

      print('=== RESPUESTA DEL SERVIDOR ===');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Error en el registro');
        }
        
        final responseData = data['data'] ?? data;
        final accessToken = responseData['access_token'];
        final userData = responseData['user'];
        
        // Crear usuario a partir de la información del token o respuesta
        final user = User.fromAuthResponse(responseData);
        
        // Guardar datos en el almacenamiento seguro
        await _storage.write(key: _tokenKey, value: accessToken);
        await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
        await _storage.write(key: _roleKey, value: 'user');
        
        print('=== REGISTRO EXITOSO ===');
        return user;
      } else {
        print('Error en registro: ${response.body}');
        String errorMessage = 'Error en el registro (${response.statusCode})';
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message']?.toString() ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('=== ERROR EN EL PROCESO DE REGISTRO ===');
      print('Error: $e');
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
        
        // Verificar si el token sigue siendo válido haciendo una petición al perfil
        try {
          final response = await http.get(
            Uri.parse(ApiConfig.getProfileUrl()),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              // Actualizar datos del usuario con la información más reciente
              final updatedUser = User.fromAuthResponse(data['data']);
              await _storage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));
              return updatedUser;
            }
          }
        } catch (e) {
          print('Error al verificar token: $e');
          // Si hay error, limpiar datos y devolver null
          await logout();
          return null;
        }
        
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
  
  // Get authorization header with Bearer token
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Guardar datos de usuario y token
  Future<void> saveUserData(User user, String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
      await _storage.write(key: _roleKey, value: user.roles.isNotEmpty ? user.roles.first : 'user');
    } catch (e) {
      print('Error al guardar datos de usuario: $e');
      throw Exception('Error al guardar datos de usuario: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Intentar hacer logout en el servidor
        try {
          await http.post(
            Uri.parse(ApiConfig.getLogoutUrl()),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        } catch (e) {
          print('Error al hacer logout en servidor: $e');
        }
      }
      
      // Limpiar datos locales
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _roleKey);
    } catch (e) {
      print('Error en logout: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
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
