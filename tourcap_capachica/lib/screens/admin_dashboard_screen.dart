import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/user.dart';
import '../services/dashboard_service.dart';
import 'admin/municipalidad_management_screen.dart';
import 'admin/emprendedores/emprendedores_management_screen.dart';
import '../blocs/entrepreneur/entrepreneur_bloc.dart';
import '../blocs/entrepreneur/entrepreneur_event.dart';
import '../blocs/municipalidad/municipalidad_bloc.dart';
import '../blocs/users/users_bloc.dart';
import '../blocs/roles/roles_bloc.dart';
import '../blocs/permissions/permissions_bloc.dart';
import '../blocs/asociaciones/asociaciones_bloc.dart';
import '../blocs/asociaciones/asociaciones_event.dart';
import 'MenuDashboard/ReservasDashboard/reservas_dashboard_screen.dart';
import 'MenuDashboard/Usuarios/users_management_screen.dart';
import 'MenuDashboard/Usuarios/roles_management_screen.dart';
import 'MenuDashboard/Usuarios/permissions_management_screen.dart';
import 'MenuDashboard/AsociacionesDashboard/asociaciones_management_screen.dart';
import 'MenuDashboard/ServiciosDashboard/servicios_management_screen.dart';
import '../blocs/servicios/servicios_bloc.dart';
import '../../../blocs/servicios/servicios_event.dart';

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
    const _PlaceholderScreen(title: 'Mis Reservas'),
    const _PlaceholderScreen(title: 'Mis Inscripciones'),
    const _PlaceholderScreen(title: 'Gestionar Planes'),
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
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedIndex > 0)
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() => _isGridView = !_isGridView);
              },
              tooltip: _isGridView ? 'Vista de lista' : 'Vista de cuadrícula',
            ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
          PopupMenuButton<String>(
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
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: IndexedStack(index: _selectedIndex, children: _screens),
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF9C27B0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 32,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Administrador',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'admin@email.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () => _onDrawerItemTapped(0),
          ),
          const Divider(),
          const _DrawerHeader('GESTIÓN DE USUARIOS'),
          ExpansionTile(
            leading: const Icon(Icons.people_alt_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Usuarios'),
            initiallyExpanded: _selectedIndex >= 1 && _selectedIndex <= 3,
            children: [
              _buildSubListTile(title: 'Gestión de Usuarios', index: 1),
              _buildSubListTile(title: 'Roles', index: 2),
              _buildSubListTile(title: 'Permisos', index: 3),
            ],
          ),
          const Divider(),
          const _DrawerHeader('GESTIÓN DE CONTENIDO'),
          ExpansionTile(
            leading: const Icon(Icons.store_mall_directory_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Emprendedores'),
            initiallyExpanded: _selectedIndex == 4 || _selectedIndex == 5,
            children: [
              _buildSubListTile(title: 'Gestión de Emprendedores', index: 4),
              _buildSubListTile(title: 'Gestión de Asociaciones', index: 5),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.location_city_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Municipalidad'),
            selected: _selectedIndex == 6,
            onTap: () => _onDrawerItemTapped(6),
          ),
          ExpansionTile(
            leading: const Icon(Icons.miscellaneous_services_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Servicios'),
            initiallyExpanded: _selectedIndex == 7 || _selectedIndex == 8,
            children: [
              _buildSubListTile(title: 'Gestión de Servicios', index: 7),
              _buildSubListTile(title: 'Categorías', index: 8),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Reservas'),
            initiallyExpanded: _selectedIndex >= 9 && _selectedIndex <= 11,
            children: [
              _buildSubListTile(title: 'Gestión de Reservas', index: 9),
              _buildSubListTile(title: 'Mis Reservas', index: 10),
              _buildSubListTile(title: 'Mis Inscripciones', index: 11),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.assignment_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Gestionar Planes'),
            selected: _selectedIndex == 12,
            onTap: () => _onDrawerItemTapped(12),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFF9C27B0)),
            title: const Text('Cerrar Sesión'),
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
    );
  }

  Widget _buildSubListTile({required String title, required int index}) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: ListTile(
        title: Text(title),
        selected: _selectedIndex == index,
        onTap: () => _onDrawerItemTapped(index),
        dense: true,
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String title;
  const _DrawerHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final DashboardService dashboardService;
  final void Function(int index) onNavigateToSection;

  const _DashboardContent({required this.dashboardService, required this.onNavigateToSection});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  // Datos de ejemplo para mostrar mientras se cargan los datos reales
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
    final stats = _stats ?? _exampleStats;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 32,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido, ${user?.name ?? 'Administrador'}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Panel de Control de Administración',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Última actualización: ${DateTime.now().toString().substring(11, 16)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tarjetas de estadísticas
            Text(
              'Estadísticas Generales',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                final crossAxisCount = isSmallScreen ? 1 : 2;
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isSmallScreen ? 1.5 : 1.2,
                  children: [
                    _buildStatCard(
                      'Usuarios',
                      '${stats['total_users']}',
                      Icons.people_rounded,
                      Colors.blue,
                      '${stats['active_users']} activos',
                    ),
                    _buildStatCard(
                      'Emprendedores',
                      '${stats['total_entrepreneurs']}',
                      Icons.store_rounded,
                      Colors.green,
                      'Registrados',
                    ),
                    _buildStatCard(
                      'Municipalidades',
                      '${stats['total_municipalities']}',
                      Icons.location_city_rounded,
                      Colors.orange,
                      'Activas',
                    ),
                    _buildStatCard(
                      'Servicios',
                      '${stats['total_services']}',
                      Icons.miscellaneous_services_rounded,
                      Colors.purple,
                      'Disponibles',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Actividad reciente
            Text(
              'Actividad Reciente',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats['recent_activities']?.length ?? 0,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = stats['recent_activities'][index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getActivityColor(activity['type']),
                      child: Icon(
                        _getActivityIcon(activity['type']),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity['message'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Hace ${activity['time']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Acciones rápidas
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                
                if (isSmallScreen) {
                  // En pantallas pequeñas, apilar verticalmente
                  return Column(
                    children: [
                      _buildQuickActionCard(
                        'Gestionar Usuarios',
                        Icons.people_alt_rounded,
                        Colors.blue,
                        () {
                          widget.onNavigateToSection(1); // Ir a gestión de usuarios
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        'Emprendedores',
                        Icons.store_rounded,
                        Colors.green,
                        () {
                          widget.onNavigateToSection(4); // Ir a gestión de emprendedores
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        'Municipalidades',
                        Icons.location_city_rounded,
                        Colors.orange,
                        () {
                          widget.onNavigateToSection(6); // Ir a gestión de municipalidades
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        'Configuración',
                        Icons.settings_rounded,
                        Colors.purple,
                        () => Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  );
                } else {
                  // En pantallas grandes, usar GridView
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Gestionar Usuarios',
                              Icons.people_alt_rounded,
                              Colors.blue,
                              () {
                                widget.onNavigateToSection(1); // Ir a gestión de usuarios
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              'Emprendedores',
                              Icons.store_rounded,
                              Colors.green,
                              () {
                                widget.onNavigateToSection(4); // Ir a gestión de emprendedores
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Municipalidades',
                              Icons.location_city_rounded,
                              Colors.orange,
                              () {
                                widget.onNavigateToSection(6); // Ir a gestión de municipalidades
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              'Configuración',
                              Icons.settings_rounded,
                              Colors.purple,
                              () => Navigator.pushNamed(context, '/settings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_registration':
        return Colors.blue;
      case 'entrepreneur_approved':
        return Colors.green;
      case 'reservation_created':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
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
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Funcionalidad próximamente disponible',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 