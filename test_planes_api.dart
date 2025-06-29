import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 === TESTING PLANES API ===');
  
  // URL base
  const String baseUrl = 'http://192.168.1.64:8000';
  const String planesUrl = '$baseUrl/api/planes';
  
  print('URL: $planesUrl');
  
  try {
    // Test 1: Sin autenticación
    print('\n📡 Test 1: Sin autenticación');
    final response1 = await http.get(Uri.parse(planesUrl));
    print('Status: ${response1.statusCode}');
    print('Body: ${response1.body}');
    
    // Test 2: Con headers básicos
    print('\n📡 Test 2: Con headers básicos');
    final response2 = await http.get(
      Uri.parse(planesUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    print('Status: ${response2.statusCode}');
    print('Body: ${response2.body}');
    
    // Test 3: Verificar si la ruta existe
    print('\n📡 Test 3: Verificar ruta de status');
    final statusResponse = await http.get(Uri.parse('$baseUrl/api/status'));
    print('Status: ${statusResponse.statusCode}');
    print('Body: ${statusResponse.body}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
} 