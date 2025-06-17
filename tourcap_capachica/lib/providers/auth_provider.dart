import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.post(
        ApiConfig.getLoginUrl(),
        {'email': email, 'password': password},
        requiresAuth: false
      );
      
      if (data != null && data['token'] != null) {
        final token = data['token'] as String;
        
        // Crear usuario a partir de la información del token o respuesta
        final userId = data['id'] ?? 1;
        final username = data['username'] ?? email.split('@')[0];
        final isAdmin = data['rol'] == 'ADMIN';
        
        final user = User(
          id: userId,
          username: username,
          email: email,
          isAdmin: isAdmin,
          token: token,
        );
        
        // Guardar token y datos de usuario
        await _authService.saveUserData(user, token);
        
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Datos de inicio de sesión inválidos');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.post(
        ApiConfig.getRegisterUrl(),
        {
          'username': username,
          'email': email,
          'password': password,
          'rol': 'REGULAR'
        },
        requiresAuth: false
      );
      
      if (data != null && data['token'] != null) {
        final token = data['token'] as String;
        
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
        
        // Guardar token y datos de usuario
        await _authService.saveUserData(user, token);
        
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Error en el registro');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _user = null;
      // No intentamos navegar aquí, lo haremos desde la UI
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
