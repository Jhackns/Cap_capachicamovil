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
    _DashboardContent(dashboardService: _dashboardService),
    const _UsersManagementScreen(),
    const _RolesManagementScreen(),
    const _PermissionsManagementScreen(),
    BlocProvider(
      create: (_) => EntrepreneurBloc()..add(LoadEntrepreneurs()),
      child: const EmprendedoresManagementScreen(),
    ),
    const AsociacionesManagementScreen(),
    BlocProvider(
      create: (context) {
        final dashboardService = Provider.of<DashboardService>(context, listen: false);
        return MunicipalidadBloc(dashboardService: dashboardService)..add(FetchMunicipalidades());
      },
      child: const MunicipalidadManagementScreen(),
    ),
    const _PlaceholderScreen(title: 'Gestión de Servicios'),
    const _PlaceholderScreen(title: 'Gestión de Categorías'),
    const _PlaceholderScreen(title: 'Gestión de Reservas'),
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
      // No es necesario cargar todo aquí si cada pantalla lo hace por su cuenta
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
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person), SizedBox(width: 8), Text('Mi Perfil')])),
              const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings), SizedBox(width: 8), Text('Configuración')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Cerrar Sesión')])),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
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
                  child: Icon(Icons.admin_panel_settings_rounded, size: 32, color: Color(0xFF9C27B0)),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Administrador',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.7)),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final DashboardService dashboardService;

  const _DashboardContent({required this.dashboardService});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    
    // El resto del build de _DashboardContent se omite por brevedad
    // pero debería estar aquí. Asumimos que ya existe.
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Estadísticas del Dashboard', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            if (_stats != null) ...[
              Text('Total Usuarios: ${_stats!['total_users']}'),
              Text('Usuarios Activos: ${_stats!['active_users']}'),
            ]
          ],
        ),
      ),
    );
  }
}

class _UsersManagementScreen extends StatelessWidget {
  const _UsersManagementScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(title: 'Gestión de Usuarios');
}

class _RolesManagementScreen extends StatelessWidget {
  const _RolesManagementScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(title: 'Gestión de Roles');
}

class _PermissionsManagementScreen extends StatelessWidget {
  const _PermissionsManagementScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(title: 'Gestión de Permisos');
}

class AsociacionesManagementScreen extends StatelessWidget {
  const AsociacionesManagementScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen(title: 'Gestión de Asociaciones');
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
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