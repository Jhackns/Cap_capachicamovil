import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class RouteGuard {
  static Route<dynamic> adminGuard(
    BuildContext context,
    Widget destination,
    RouteSettings settings,
    [String message = 'Necesitas iniciar sesión como administrador para acceder a esta sección']
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null || !user.isAdmin) {
      // Redirect to login if not authenticated or not admin
      return MaterialPageRoute(
        builder: (_) => LoginScreen(
          message: message,
        ),
        settings: settings,
      );
    }

    // Allow access to the destination for admin users
    return MaterialPageRoute(
      builder: (_) => destination,
      settings: settings,
    );
  }

  static Route<dynamic> authGuard(
    BuildContext context,
    Widget destination,
    RouteSettings settings,
    [String message = 'Necesitas iniciar sesión para acceder a esta sección']
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      // Redirect to login if not authenticated
      return MaterialPageRoute(
        builder: (_) => LoginScreen(
          message: message,
        ),
        settings: settings,
      );
    }

    // Allow access to the destination for authenticated users
    return MaterialPageRoute(
      builder: (_) => destination,
      settings: settings,
    );
  }
}
