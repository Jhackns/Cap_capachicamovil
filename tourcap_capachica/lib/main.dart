import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/categories/hospedaje_screen.dart';
import 'screens/categories/gastronomia_screen.dart';
import 'screens/categories/turismo_screen.dart';
import 'screens/categories/artesania_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main/main_navigation.dart';
import 'screens/main/explore_tab.dart';

// Utils
import 'utils/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),
        initialRoute: '/main',
        routes: {
          '/main': (context) => const MainNavigation(),
          '/home': (context) => const HomeScreen(),
          '/explore': (context) => const ExploreTab(),
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/user-dashboard': (context) => const UserDashboardScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
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
