import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmprendedorService {
  final String baseUrl = ApiConfig.getEntrepreneursUrl();

  Future<List<dynamic>> fetchEntrepreneurs({String? query}) async {
    final url = query != null && query.isNotEmpty
        ? '${baseUrl}/search?q=$query'
        : baseUrl;
    final response = await http.get(Uri.parse(url));
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
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    final res = json.decode(response.body);
    if (response.statusCode == 201 && res['success'] == true) {
      return res['data'];
    } else {
      throw Exception(res['message'] ?? 'Error al crear emprendedor');
    }
  }

  Future<dynamic> updateEntrepreneur(int id, Map<String, dynamic> data) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    final res = json.decode(response.body);
    if (response.statusCode == 200 && res['success'] == true) {
      return res['data'];
    } else {
      throw Exception(res['message'] ?? 'Error al actualizar emprendedor');
    }
  }

  Future<void> deleteEntrepreneur(int id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    final res = json.decode(response.body);
    if (response.statusCode == 200 && res['success'] == true) {
      return;
    } else {
      throw Exception(res['message'] ?? 'Error al eliminar emprendedor');
    }
  }
} 