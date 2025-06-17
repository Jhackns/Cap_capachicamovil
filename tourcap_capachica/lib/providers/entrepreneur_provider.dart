import 'package:flutter/foundation.dart';
import '../models/entrepreneur.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class EntrepreneurProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Entrepreneur> _entrepreneurs = [];
  bool _isLoading = false;
  String? _error;
  Map<int, Entrepreneur> _entrepreneurCache = {};

  List<Entrepreneur> get entrepreneurs => List.unmodifiable(_entrepreneurs);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener todos los emprendedores
  Future<void> fetchEntrepreneurs() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get(ApiConfig.getEntrepreneursUrl());
      
      if (data != null) {
        _entrepreneurs = (data as List)
            .map((item) => Entrepreneur.fromJson(item))
            .toList();
      } else {
        _entrepreneurs = [];
      }
      
      _updateCache(_entrepreneurs);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error en fetchEntrepreneurs: $e');
    }
  }

  void _updateCache(List<Entrepreneur> entrepreneurs) {
    for (var entrepreneur in entrepreneurs) {
      _entrepreneurCache[entrepreneur.id] = entrepreneur;
    }
  }

  // Obtener emprendedor por ID
  Future<Entrepreneur?> getEntrepreneurById(int id) async {
    // Primero buscar en la caché
    if (_entrepreneurCache.containsKey(id)) {
      return _entrepreneurCache[id];
    }

    try {
      final data = await _apiService.get(
        ApiConfig.getEntrepreneurByIdUrl(id), 
        requiresAuth: true
      );
      
      if (data != null) {
        final entrepreneur = Entrepreneur.fromJson(data);
        _entrepreneurCache[id] = entrepreneur;
        return entrepreneur;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Error en getEntrepreneurById: $e');
      return null;
    }
  }

  // Agregar emprendedor (solo administrador)
  Future<Entrepreneur?> addEntrepreneur(Entrepreneur entrepreneur) async {
    if (_isLoading) return null;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.post(
        ApiConfig.getEntrepreneursUrl(),
        entrepreneur.toJson(),
        requiresAuth: true
      );
      
      if (data != null) {
        final newEntrepreneur = Entrepreneur.fromJson(data);
        _entrepreneurs.add(newEntrepreneur);
        _entrepreneurCache[newEntrepreneur.id] = newEntrepreneur;
        _isLoading = false;
        notifyListeners();
        return newEntrepreneur;
      }
      return null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error en addEntrepreneur: $e');
      return null;
    }
  }

  // Actualizar emprendedor (solo administrador)
  Future<Entrepreneur?> updateEntrepreneur(Entrepreneur entrepreneur) async {
    if (_isLoading) return null;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.put(
        ApiConfig.getEntrepreneurByIdUrl(entrepreneur.id),
        entrepreneur.toJson(),
        requiresAuth: true
      );
      
      if (data != null) {
        final updatedEntrepreneur = Entrepreneur.fromJson(data);
        final index = _entrepreneurs.indexWhere((e) => e.id == entrepreneur.id);
        if (index != -1) {
          _entrepreneurs[index] = updatedEntrepreneur;
        }
        _entrepreneurCache[updatedEntrepreneur.id] = updatedEntrepreneur;
        _isLoading = false;
        notifyListeners();
        return updatedEntrepreneur;
      }
      return null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error en updateEntrepreneur: $e');
      return null;
    }
  }

  // Eliminar emprendedor (solo administrador)
  Future<bool> deleteEntrepreneur(int id) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.delete(
        ApiConfig.getEntrepreneurByIdUrl(id),
        requiresAuth: true
      );
      
      if (success) {
        _entrepreneurs.removeWhere((e) => e.id == id);
        _entrepreneurCache.remove(id);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error en deleteEntrepreneur: $e');
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpiar caché
  void clearCache() {
    _entrepreneurCache.clear();
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}
