import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../models/user.dart';
import '../../../services/dashboard_service.dart';
import '../../admin/municipalidad_management_screen.dart';
import '../../admin/emprendedores/emprendedores_management_screen.dart';
import '../../../blocs/entrepreneur/entrepreneur_bloc.dart';
import '../../../blocs/entrepreneur/entrepreneur_event.dart';
import '../../../blocs/municipalidad/municipalidad_bloc.dart';
import '../../../blocs/users/users_bloc.dart';
import '../../../blocs/roles/roles_bloc.dart';
import '../../../blocs/permissions/permissions_bloc.dart';
import '../../../blocs/asociaciones/asociaciones_bloc.dart';
import '../../../blocs/asociaciones/asociaciones_event.dart';
import '../../../blocs/planes/planes_bloc.dart';
import '../../../blocs/planes/planes_event.dart';
import '../../MenuDashboard/ReservasDashboard/reservas_dashboard_screen.dart';
import '../../MenuDashboard/ReservasDashboard/mis_reservas_screen.dart';
import '../../MenuDashboard/Usuarios/users_management_screen.dart';
import '../../MenuDashboard/Usuarios/roles_management_screen.dart';
import '../../MenuDashboard/Usuarios/permissions_management_screen.dart';
import '../../MenuDashboard/AsociacionesDashboard/asociaciones_management_screen.dart';
import '../../MenuDashboard/ServiciosDashboard/servicios_management_screen.dart';
import '../../MenuDashboard/PlanesDashboard/planes_management_screen.dart';
import '../../../blocs/servicios/servicios_bloc.dart';
import '../../../blocs/servicios/servicios_event.dart';
import '../user_dashboard/user_dashboard_screen.dart';
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isGridView = true;
  bool _isLoading = true;
  String? _error;

  final DashboardService _dashboardService = DashboardService();

  late final List<Widget> _screens = [
    _DashboardContent(
      dashboardService: _dashboardService,
      onNavigateToSection: _onDrawerItemTapped,
    ),
    BlocProvider(
      create: (_) => UsersBloc(),
      child: const UsersManagementScreen(),
    ),
    BlocProvider(
      create: (_) => RolesBloc(),
      child: const RolesManagementScreen(),
    ),
    BlocProvider(
      create: (_) => PermissionsBloc(),
      child: const PermissionsManagementScreen(),
    ),
    BlocProvider(
      create: (_) => EntrepreneurBloc()..add(LoadEntrepreneurs()),
      child: const EmprendedoresManagementScreen(),
    ),
    BlocProvider(
      create: (_) => AsociacionesBloc()..add(LoadAsociaciones()),
      child: const AsociacionesManagementScreen(),
    ),
    BlocProvider(
      create: (_) => MunicipalidadBloc(dashboardService: _dashboardService)..add(FetchMunicipalidades()),
      child: const MunicipalidadManagementScreen(),
    ),
    BlocProvider(
      create: (_) => ServiciosBloc()..add(LoadServicios()),
      child: const ServiciosManagementScreen(),
    ),
    const _PlaceholderScreen(title: 'Gestión de Categorías'),
    ReservasDashboardScreen(),
    const MisReservasScreen(),
    const _PlaceholderScreen(title: 'Mis Inscripciones'),
    BlocProvider(
      create: (_) => PlanesBloc()..add(LoadPlanes()),
      child: const PlanesManagementScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _dashboardService.getDashboardStats();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onDrawerItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    if (!authProvider.isAuthenticated) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAdmin) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/dashboard'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
      appBar: _buildAppBar(user, themeProvider, authProvider),
      drawer: _buildDrawer(user, themeProvider),
      body: IndexedStack(index: _selectedIndex, children: _screens),
    );
  }

  PreferredSizeWidget _buildAppBar(User? user, ThemeProvider themeProvider, AuthProvider authProvider) {
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    return AppBar(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      foregroundColor: primaryTextColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: primaryTextColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A5F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Admin Panel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
      actions: [
        if (_selectedIndex > 0)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: secondaryTextColor,
              ),
              onPressed: () {
                setState(() => _isGridView = !_isGridView);
              },
              tooltip: _isGridView ? 'Vista de lista' : 'Vista de cuadrícula',
            ),
          ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: secondaryTextColor,
            ),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: themeProvider.isDarkMode ? const Color(0xFF444444) : const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: secondaryTextColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        (user?.name ?? 'A').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: secondaryTextColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
                case 'logout':
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false,
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.person_rounded, size: 16, color: secondaryTextColor),
                    ),
                    const SizedBox(width: 12),
                    Text('Mi Perfil', style: TextStyle(fontSize: 14, color: primaryTextColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.settings_rounded, size: 16, color: secondaryTextColor),
                    ),
                    const SizedBox(width: 12),
                    Text('Configuración', style: TextStyle(fontSize: 14, color: primaryTextColor)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFFF5A5F)),
                    ),
                    const SizedBox(width: 12),
                    const Text('Cerrar Sesión', style: TextStyle(fontSize: 14, color: Color(0xFFFF5A5F))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(User? user, ThemeProvider themeProvider) {
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    return Drawer(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
                border: Border(bottom: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF444444) : const Color(0xFFEBEBEB))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5A5F),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        (user?.name ?? 'A').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Administrador',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'admin@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Contenido del drawer
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onDrawerItemTapped(0),
                  ),

                  const SizedBox(height: 24),
                  _buildDrawerSection('GESTIÓN DE USUARIOS'),
                  _buildDrawerExpandableItem(
                    icon: Icons.people_rounded,
                    title: 'Usuarios',
                    isExpanded: _selectedIndex >= 1 && _selectedIndex <= 3,
                    children: [
                      _buildDrawerSubItem('Gestión de Usuarios', 1),
                      _buildDrawerSubItem('Roles', 2),
                      _buildDrawerSubItem('Permisos', 3),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildDrawerSection('GESTIÓN DE CONTENIDO'),
                  _buildDrawerExpandableItem(
                    icon: Icons.store_rounded,
                    title: 'Emprendedores',
                    isExpanded: _selectedIndex == 4 || _selectedIndex == 5,
                    children: [
                      _buildDrawerSubItem('Gestión de Emprendedores', 4),
                      _buildDrawerSubItem('Gestión de Asociaciones', 5),
                    ],
                  ),
                  _buildDrawerItem(
                    icon: Icons.location_city_rounded,
                    title: 'Municipalidad',
                    isSelected: _selectedIndex == 6,
                    onTap: () => _onDrawerItemTapped(6),
                  ),
                  _buildDrawerExpandableItem(
                    icon: Icons.miscellaneous_services_rounded,
                    title: 'Servicios',
                    isExpanded: _selectedIndex == 7 || _selectedIndex == 8,
                    children: [
                      _buildDrawerSubItem('Gestión de Servicios', 7),
                      _buildDrawerSubItem('Categorías', 8),
                    ],
                  ),
                  _buildDrawerExpandableItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'Reservas',
                    isExpanded: _selectedIndex >= 9 && _selectedIndex <= 11,
                    children: [
                      _buildDrawerSubItem('Gestión de Reservas', 9),
                      _buildDrawerSubItem('Mis Reservas', 10),
                      _buildDrawerSubItem('Mis Inscripciones', 11),
                    ],
                  ),
                  _buildDrawerItem(
                    icon: Icons.assignment_rounded,
                    title: 'Gestionar Planes',
                    isSelected: _selectedIndex == 12,
                    onTap: () => _onDrawerItemTapped(12),
                  ),
                ],
              ),
            ),

            // Footer del drawer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF444444) : const Color(0xFFEBEBEB))),
              ),
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'Mi Perfil',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Configuración',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar Sesión',
                    iconColor: const Color(0xFFFF5A5F),
                    textColor: const Color(0xFFFF5A5F),
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<AuthProvider>().logout();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? const Color(0xFFFF5A5F)
              : (iconColor ?? secondaryTextColor),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? primaryTextColor
                : (textColor ?? secondaryTextColor),
          ),
        ),
        selected: isSelected,
        selectedTileColor: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDrawerExpandableItem({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required List<Widget> children,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: isExpanded ? const Color(0xFFFF5A5F) : secondaryTextColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w400,
            color: isExpanded ? primaryTextColor : secondaryTextColor,
          ),
        ),
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 16),
        iconColor: secondaryTextColor,
        collapsedIconColor: secondaryTextColor,
        children: children,
      ),
    );
  }

  Widget _buildDrawerSubItem(String title, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? primaryTextColor : secondaryTextColor,
          ),
        ),
        selected: isSelected,
        selectedTileColor: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        dense: true,
        onTap: () => _onDrawerItemTapped(index),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final DashboardService dashboardService;
  final void Function(int index) onNavigateToSection;

  const _DashboardContent({
    required this.dashboardService,
    required this.onNavigateToSection,
  });

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  final Map<String, dynamic> _exampleStats = {
    'total_users': 156,
    'active_users': 142,
    'total_entrepreneurs': 23,
    'total_municipalities': 8,
    'total_services': 45,
    'total_reservations': 89,
    'recent_activities': [
      {
        'type': 'user_registration',
        'message': 'Nuevo usuario registrado: María López',
        'time': '2 min',
      },
      {
        'type': 'entrepreneur_approved',
        'message': 'Emprendedor aprobado: Restaurante El Sabor',
        'time': '15 min',
      },
      {
        'type': 'reservation_created',
        'message': 'Nueva reserva creada para Tour Capachica',
        'time': '1 hora',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await widget.dashboardService.getDashboardStats();
      print('Stats: $stats'); // Debug print to inspect API response
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stats = _stats ?? _exampleStats;
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: const Color(0xFFFF5A5F)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: const Color(0xFFFF5A5F), size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los datos: $_error',
              style: TextStyle(color: primaryTextColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFFFF5A5F),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0), // Reducido de 24 para minimizar acumulación
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Hero Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF5A5F),
                      Color(0xFFE91E63),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16), // Reducido de 24
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name ?? 'A').substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12), // Reducido de 16
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola, ${user?.name?.split(' ').first ?? 'Admin'}! 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16, // Reducido de 28
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4), // Reducido de 8
                                  Text(
                                    'Bienvenido a tu panel de administración',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14, // Reducido de 16
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8), // Reducido de 24
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reducido de 16 y 8
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 8, // Reducido de 16
                              ),
                              const SizedBox(width: 4), // Reducido de 8
                              Text(
                                'Última actualización: ${DateTime.now().toString().substring(11, 16)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 8, // Reducido de 14
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16), // Reducido de 24
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        final crossAxisCount = isSmallScreen ? 2 : 4;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 4, // Reducido de 16
                          mainAxisSpacing: 4, // Reducido de 16
                          childAspectRatio: isSmallScreen ? 1.1 : 1.0,
                          children: [
                            _buildModernStatCard(
                              'Usuarios',
                              '${stats['total_users'] ?? 0}',
                              Icons.people_rounded,
                              const Color(0xFF4285F4),
                              '${stats['active_users'] ?? 0} activos',
                              onTap: () => widget.onNavigateToSection(1),
                            ),
                            _buildModernStatCard(
                              'Emprendedores',
                              '${stats['total_entrepreneurs'] ?? 0}',
                              Icons.store_rounded,
                              const Color(0xFF34A853),
                              'Registrados',
                              onTap: () => widget.onNavigateToSection(4),
                            ),
                            _buildModernStatCard(
                              'Municipalidades',
                              '${stats['total_municipalities'] ?? 0}',
                              Icons.location_city_rounded,
                              const Color(0xFFFBBC04),
                              'Activas',
                              onTap: () => widget.onNavigateToSection(6),
                            ),
                            _buildModernStatCard(
                              'Servicios',
                              '${stats['total_services'] ?? 0}',
                              Icons.miscellaneous_services_rounded,
                              const Color(0xFFE91E63),
                              'Totales',
                              onTap: () => widget.onNavigateToSection(7),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16), // Reducido de 32

                    // Recent Activities Section
                    Text(
                      'Actividad Reciente',
                      style: TextStyle(
                        fontSize: 16, // Reducido de 20
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8), // Reducido de 16
                    stats['recent_activities'] != null && stats['recent_activities'].isNotEmpty
                        ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats['recent_activities'].length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: themeProvider.isDarkMode ? const Color(0xFF444444) : const Color(0xFFEBEBEB),
                      ),
                      itemBuilder: (context, index) {
                        final activity = stats['recent_activities'][index];
                        return _buildActivityCard(
                          type: activity['type'] ?? 'unknown',
                          message: activity['message'] ?? 'Sin descripción',
                          time: activity['time'] ?? 'Sin tiempo',
                        );
                      },
                    )
                        : Container(
                      padding: const EdgeInsets.all(8), // Reducido de 16
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
                            blurRadius: 6, // Reducido de 8
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'No hay actividades recientes',
                        style: TextStyle(
                          fontSize: 8, // Reducido de 14
                          color: secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 8), // Reducido de 32

                    // Quick Actions Section
                    Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 18, // Reducido de 20
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8), // Reducido de 16
                    Wrap(
                      spacing: 8, // Reducido de 16
                      runSpacing: 8, // Reducido de 16
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.person_add_rounded,
                          label: 'Agregar Usuario',
                          onTap: () => widget.onNavigateToSection(1),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.store_rounded,
                          label: 'Nuevo Emprendedor',
                          onTap: () => widget.onNavigateToSection(4),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.miscellaneous_services_rounded,
                          label: 'Crear Servicio',
                          onTap: () => widget.onNavigateToSection(7),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.calendar_today_rounded,
                          label: 'Ver Reservas',
                          onTap: () => widget.onNavigateToSection(9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Buffer mínimo
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String type,
    required String message,
    required String time,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);
    final secondaryTextColor = themeProvider.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF717171);

    IconData getIcon() {
      switch (type) {
        case 'user_registration':
          return Icons.person_add_rounded;
        case 'entrepreneur_approved':
          return Icons.check_circle_rounded;
        case 'reservation_created':
          return Icons.calendar_today_rounded;
        default:
          return Icons.info_rounded;
      }
    }

    Color getColor() {
      switch (type) {
        case 'user_registration':
          return const Color(0xFF4285F4);
        case 'entrepreneur_approved':
          return const Color(0xFF34A853);
        case 'reservation_created':
          return const Color(0xFFE91E63);
        default:
          return secondaryTextColor;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(getIcon(), size: 20, color: getColor()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);

    return SizedBox(
      width: 160,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          foregroundColor: const Color(0xFFFF5A5F),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF444444) : const Color(0xFFEBEBEB)),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF222222);

    return Center(
      child: Text(
        '$title en desarrollo',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
      ),
    );
  }
}