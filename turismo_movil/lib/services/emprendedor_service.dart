import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class EmprendedorService {
  final String baseUrl = ApiConfig.getEmprendedoresUrl();
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> fetchEntrepreneurs({String? query}) async {
    final url = query != null && query.isNotEmpty
        ? '${baseUrl}/search?q=$query'
        : baseUrl;
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'] is List ? data['data'] : data['data']['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Error al obtener emprendedores');
      }
    } else {
      throw Exception('Error de red: ${response.statusCode}');
    }
  }

  Future<dynamic> createEntrepreneur(Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode(data),
    );
    final res = json.decode(response.body);
    if (response.statusCode == 201 && res['success'] == true) {
      return res['data'];
    } else {
      print('=== ERROR AL CREAR EMPRENDEDOR ===');
      print('Status code: [31m${response.statusCode}[0m');
      print('Response body: ${response.body}');
      print('Headers: ${response.headers}');
      throw Exception(res['message'] ?? 'Error al crear emprendedor');
    }
  }

  Future<dynamic> updateEntrepreneur(int id, Map<String, dynamic> data) async {
    final url = '$baseUrl/$id';
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    final res = json.decode(response.body);
    if (response.statusCode == 200 && res['success'] == true) {
      return res['data'];
    } else {
      print('=== ERROR AL EDITAR EMPRENDEDOR ===');
      print('Status code: [31m${response.statusCode}[0m');
      print('Response body: ${response.body}');
      print('Headers: ${response.headers}');
      throw Exception(res['message'] ?? 'Error al actualizar emprendedor');
    }
  }

  Future<void> deleteEntrepreneur(int id) async {
    final url = '$baseUrl/$id';
    final headers = await _getAuthHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);
    final res = json.decode(response.body);
    if (response.statusCode == 200 && res['success'] == true) {
      return;
    } else {
      throw Exception(res['message'] ?? 'Error al eliminar emprendedor');
    }
  }
} 