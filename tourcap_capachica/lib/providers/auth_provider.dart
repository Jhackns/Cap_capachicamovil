import 'package:flutter/foundation.dart';
import 'dart:io';
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
  bool _isAuthenticated = false;
  String? _token;

  User? get currentUser => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _user?.hasRole('admin') ?? false;
  String? get token => _token;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        _isAuthenticated = true;
        _token = _user!.token;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _user = null;
      _token = null;
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
      // Limpiar estado anterior antes del login
      _user = null;
      _token = null;
      _isAuthenticated = false;
      
      final result = await _authService.login(email, password);
      
      if (result['user'] != null) {
        _user = result['user'] as User;
        _token = result['token'] as String;
        _isAuthenticated = true;
        _error = null;
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Datos de inicio de sesión inválidos');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      _user = null;
      _token = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        country: country,
        birthDate: birthDate,
        address: address,
        gender: gender,
        language: language,
        profileImage: profileImage,
      );
      
      if (user != null) {
        _user = user;
        _token = user.token;
        _isAuthenticated = true;
        _error = null;
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Error en el registro');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      _user = null;
      _token = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
    } catch (e) {
      // Ignorar errores en logout, siempre limpiar el estado local
      print('Error en logout: $e');
    } finally {
      // Siempre limpiar el estado local
      _user = null;
      _isAuthenticated = false;
      _token = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAuthState() {
    _user = null;
    _isAuthenticated = false;
    _token = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void setAuth(bool isAuthenticated, {String? token}) {
    _isAuthenticated = isAuthenticated;
    _token = token;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    _isAuthenticated = true;
    _token = user.token;
    notifyListeners();
  }
}
