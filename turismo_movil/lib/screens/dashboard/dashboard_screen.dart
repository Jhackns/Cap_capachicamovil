import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/theme_switcher.dart';

const Color kPurplePrimary = Color(0xFF9C27B0); // Purple 500

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar el rol del usuario y redirigir después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRoleAndRedirect();
    });
  }

  void _checkUserRoleAndRedirect() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      if (authProvider.isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/user-dashboard');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando permisos...'),
            ],
        ),
      ),
    );
  }
}
