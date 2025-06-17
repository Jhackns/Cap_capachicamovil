import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectivityChecker {
  // Check if internet connection is available
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Show a snackbar with connection status
  static void showConnectivitySnackBar(BuildContext context, bool isConnected) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.signal_wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Sin conexión a internet'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 8),
              Text('Conexión a internet restaurada'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Check connectivity and show a dialog if not connected
  static Future<bool> checkConnectivityWithDialog(BuildContext context) async {
    final isConnected = await ConnectivityChecker.isConnected();
    
    if (!isConnected) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sin conexión a internet'),
          content: const Text(
            'Esta acción requiere conexión a internet. Por favor, verifica tu conexión e intenta nuevamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return false;
    }
    
    return true;
  }
}
