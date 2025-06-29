import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TestWhatsApp extends StatelessWidget {
  const TestWhatsApp({Key? key}) : super(key: key);

  Future<void> _testWhatsApp() async {
    const numero = '+51999999999';
    const mensaje = 'Hola! Este es un mensaje de prueba.';
    final url = 'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}';

    try {
      final uri = Uri.parse(url);
      print('Intentando abrir: $url');
      
      final canLaunch = await canLaunchUrl(uri);
      print('¿Se puede abrir? $canLaunch');
      
      if (canLaunch) {
        final result = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Resultado: $result');
      } else {
        print('No se puede abrir la URL');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test WhatsApp'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _testWhatsApp,
          child: const Text('Probar WhatsApp'),
        ),
      ),
    );
  }
} 