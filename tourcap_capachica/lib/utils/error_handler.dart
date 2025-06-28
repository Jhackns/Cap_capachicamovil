import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    
    if (error.toString().contains('SocketException')) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'Tiempo de espera agotado. Intenta nuevamente.';
    }
    
    if (error.toString().contains('401')) {
      return 'Credenciales inválidas. Verifica tu email y contraseña.';
    }
    
    if (error.toString().contains('403')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    
    if (error.toString().contains('404')) {
      return 'Recurso no encontrado.';
    }
    
    if (error.toString().contains('500')) {
      return 'Error interno del servidor. Intenta más tarde.';
    }
    
    return 'Ha ocurrido un error inesperado. Intenta nuevamente.';
  }

  static Exception handleError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    
    String message = getErrorMessage(error);
    return Exception(message);
  }

  static Widget buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  static Widget buildLoadingWidget({String message = 'Cargando...'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyWidget({
    required String message,
    IconData icon = Icons.inbox_outlined,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 