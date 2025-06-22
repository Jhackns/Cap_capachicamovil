import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// BLoCs
import 'blocs/entrepreneur/entrepreneur_bloc.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/entrepreneurs_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/entrepreneur_management_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/categories/hospedaje_screen.dart';
import 'screens/categories/gastronomia_screen.dart';
import 'screens/categories/turismo_screen.dart';
import 'screens/categories/artesania_screen.dart';
import 'screens/splash_screen.dart';

// Utils
import 'utils/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => EntrepreneurBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Tour Capachica',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        initialRoute: '/home',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/entrepreneurs': (context) => const EntrepreneursScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/entrepreneur-management': (context) => const EntrepreneurManagementScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/hospedaje': (context) => const HospedajeScreen(),
          '/gastronomia': (context) => const GastronomiaScreen(),
          '/turismo': (context) => const TurismoScreen(),
          '/artesania': (context) => const ArtesaniaScreen(),
        },
      ),
    );
  }
}
