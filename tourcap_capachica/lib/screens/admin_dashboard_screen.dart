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
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';

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
      create:
          (_) =>
              MunicipalidadBloc(dashboardService: _dashboardService)
                ..add(FetchMunicipalidades()),
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
      Future.microtask(
        () => Navigator.pushReplacementNamed(context, '/dashboard'),
      );
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
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed:
                () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
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
            itemBuilder:
                (context) => [
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
            leading: const Icon(
              Icons.dashboard_rounded,
              color: Color(0xFF9C27B0),
            ),
            title: const Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () => _onDrawerItemTapped(0),
          ),
          const Divider(),
          const _DrawerHeader('GESTIÓN DE USUARIOS'),
          ExpansionTile(
            leading: const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF9C27B0),
            ),
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
            leading: const Icon(
              Icons.store_mall_directory_rounded,
              color: Color(0xFF9C27B0),
            ),
            title: const Text('Emprendedores'),
            initiallyExpanded: _selectedIndex == 4 || _selectedIndex == 5,
            children: [
              _buildSubListTile(title: 'Gestión de Emprendedores', index: 4),
              _buildSubListTile(title: 'Gestión de Asociaciones', index: 5),
            ],
          ),
          ListTile(
            leading: const Icon(
              Icons.location_city_rounded,
              color: Color(0xFF9C27B0),
            ),
            title: const Text('Municipalidad'),
            selected: _selectedIndex == 6,
            onTap: () => _onDrawerItemTapped(6),
          ),
          ExpansionTile(
            leading: const Icon(
              Icons.miscellaneous_services_rounded,
              color: Color(0xFF9C27B0),
            ),
            title: const Text('Servicios'),
            initiallyExpanded: _selectedIndex == 7 || _selectedIndex == 8,
            children: [
              _buildSubListTile(title: 'Gestión de Servicios', index: 7),
              _buildSubListTile(title: 'Categorías', index: 8),
            ],
          ),
          ExpansionTile(
            leading: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF9C27B0),
            ),
            title: const Text('Reservas'),
            initiallyExpanded: _selectedIndex >= 9 && _selectedIndex <= 11,
            children: [
              _buildSubListTile(title: 'Gestión de Reservas', index: 9),
              _buildSubListTile(title: 'Mis Reservas', index: 10),
              _buildSubListTile(title: 'Mis Inscripciones', index: 11),
            ],
          ),
          ListTile(
            leading: const Icon(
              Icons.assignment_rounded,
              color: Color(0xFF9C27B0),
            ),
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
            leading: const Icon(
              Icons.settings_rounded,
              color: Color(0xFF9C27B0),
            ),
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

  const _DashboardContent({required this.dashboardService});

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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
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
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Gestionar Usuarios',
                    Icons.people_alt_rounded,
                    Colors.blue,
                    () {
                      // Navegar a la pantalla de usuarios
                      Navigator.pushNamed(context, '/admin/users');
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
                      // Navegar a la pantalla de emprendedores
                      Navigator.pushNamed(context, '/admin/entrepreneurs');
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
                      // Navegar a la pantalla de municipalidades
                      Navigator.pushNamed(context, '/admin/municipalities');
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

class _UsersManagementScreen extends StatefulWidget {
  const _UsersManagementScreen();

  @override
  State<_UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback? onCancel;
  const _UserFormScreen({this.user, this.onCancel});

  @override
  State<_UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<_UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Campos del formulario
  String _name = '';
  String _email = '';
  String _phone = '';
  String _country = '';
  String _address = '';
  DateTime? _birthDate;
  String? _gender;
  String? _preferredLanguage;
  String _password = '';
  String _confirmPassword = '';
  bool _active = true;
  List<String> _selectedRoles = [];

  bool get isEditing => widget.user != null;

  final Map<String, String> _genderOptions = {
    'male': 'Masculino',
    'female': 'Femenino',
    'other': 'Otro',
    'prefer_not_to_say': 'Prefiero no decirlo',
  };
  final List<String> _languageOptions = ['es', 'en', 'fr', 'pt'];
  final Map<String, String> _languageLabels = {
    'es': 'Español',
    'en': 'Inglés',
    'fr': 'Francés',
    'pt': 'Portugués',
  };
  final List<Map<String, dynamic>> _rolesOptions = [
    {'id': 1, 'name': 'admin'},
    {'id': 2, 'name': 'user'},
    {'id': 3, 'name': 'emprendedor'},
    {'id': 4, 'name': 'moderador'},
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final user = widget.user!;
      _name = user['name'] ?? '';
      _email = user['email'] ?? '';
      _phone = user['phone'] ?? '';
      _country = user['country'] ?? '';
      _address = user['address'] ?? '';
      _birthDate =
          user['birth_date'] != null
              ? DateTime.tryParse(user['birth_date'])
              : null;

      final genderValue = user['gender']?.toString().toLowerCase();
      if (_genderOptions.keys.contains(genderValue)) {
        _gender = genderValue;
      } else {
        _gender = null;
      }

      final lang = user['preferred_language'];
      if (_languageOptions.contains(lang)) {
        _preferredLanguage = lang;
      } else if (_languageLabels.containsValue(lang)) {
        _preferredLanguage = _languageLabels.entries.firstWhere((e) => e.value == lang, orElse: () => const MapEntry('es', 'Español')).key;
      } else {
        _preferredLanguage = null;
      }
      _active = user['active'] ?? true;
      _selectedRoles = List<String>.from((user['roles'] ?? []).map((role) {
        if (role is Map && role.containsKey('name')) return role['name'].toString();
        return role.toString();
      }));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_password.isNotEmpty && _password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final isEditing = widget.user != null;
      final url = isEditing
          ? Uri.parse(ApiConfig.getUserUrl(widget.user!['id']))
          : Uri.parse(ApiConfig.getUsersUrl());
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? token = authProvider.token;
      if (token == null) {
        print('Token en AuthProvider es null, intentando obtener de AuthService...');
        token = await AuthService().getToken();
        if (token == null) {
          print('Token sigue siendo null. Redirigiendo a login.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.'), backgroundColor: Colors.red),
          );
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      }
      final request = http.MultipartRequest(isEditing ? 'POST' : 'POST', url);
      if (isEditing) request.fields['_method'] = 'PUT';
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      // Campos básicos
      request.fields['name'] = _name;
      request.fields['email'] = _email;
      if (!isEditing || _password.isNotEmpty) {
        request.fields['password'] = _password;
      }
      if (_phone.isNotEmpty) request.fields['phone'] = _phone;
      if (_country.isNotEmpty) request.fields['country'] = _country;
      if (_address.isNotEmpty) request.fields['address'] = _address;
      if (_birthDate != null) request.fields['birth_date'] = _birthDate!.toIso8601String().split('T').first;
      if (_gender != null && _gender!.isNotEmpty) request.fields['gender'] = _gender!;
      if (_preferredLanguage != null && _preferredLanguage!.isNotEmpty) request.fields['preferred_language'] = _preferredLanguage!;
      request.fields['active'] = _active ? '1' : '0';
      // Roles como nombres
      for (final role in _selectedRoles) {
        request.fields['roles[]'] = role;
      }
      // Foto de perfil
      if (_profileImage != null) {
        final mimeType = lookupMimeType(_profileImage!.path) ?? 'image/jpeg';
        final file = await http.MultipartFile.fromPath(
          'foto_perfil',
          _profileImage!.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);
      }
      print('--- CREAR/EDITAR USUARIO ---');
      print('Token: $token');
      print('URL: $url');
      print('Campos: ${request.fields}');
      print('Archivos: ${request.files.map((f) => f.filename).toList()}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      final data = response.body;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario ${isEditing ? 'actualizado' : 'creado'} exitosamente'), backgroundColor: Colors.green),
        );
        if (widget.onCancel != null) widget.onCancel!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data.toString()}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Error en submit usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Crear Usuario'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel ?? () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!) as ImageProvider
                              : (isEditing &&
                                      widget.user!['foto_perfil'] != null
                                  ? NetworkImage(widget.user!['foto_perfil'])
                                  : null),
                      child:
                          _profileImage == null &&
                                  (widget.user?['foto_perfil'] == null)
                              ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey,
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Ingrese el nombre completo'
                            : null,
                onChanged: (v) => _name = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) => v == null || v.isEmpty ? 'Ingrese el correo' : null,
                onChanged: (v) => _email = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                onChanged: (v) => _phone = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _country,
                decoration: const InputDecoration(labelText: 'País'),
                onChanged: (v) => _country = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Dirección'),
                onChanged: (v) => _address = v,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      hintText: 'dd/mm/aaaa',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text:
                          _birthDate != null
                              ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                              : '',
                    ),
                    validator:
                        (v) =>
                            _birthDate == null && !isEditing
                                ? 'Seleccione la fecha de nacimiento'
                                : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                items: _genderOptions.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
                decoration: const InputDecoration(labelText: 'Género'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _languageOptions.contains(_preferredLanguage) ? _preferredLanguage : null,
                items: _languageOptions
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(_languageLabels[l] ?? l.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _preferredLanguage = v),
                decoration: const InputDecoration(
                  labelText: 'Idioma preferido',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  helperText:
                      isEditing ? 'Dejar en blanco para no cambiar' : null,
                ),
                obscureText: true,
                validator:
                    (v) =>
                        !isEditing && (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                onChanged: (v) => _password = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                obscureText: true,
                validator:
                    (v) =>
                        _password.isNotEmpty && v != _password
                            ? 'Las contraseñas no coinciden'
                            : null,
                onChanged: (v) => _confirmPassword = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<bool>(
                value: _active,
                items: const [
                  DropdownMenuItem(value: true, child: Text('Activo')),
                  DropdownMenuItem(value: false, child: Text('Inactivo')),
                ],
                onChanged: (v) => setState(() => _active = v ?? true),
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              const SizedBox(height: 12),
              Text(
                'Roles',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children:
                    _rolesOptions
                        .map(
                          (role) => FilterChip(
                            label: Text('${role['name']} (ID: ${role['id']})'),
                            selected: _selectedRoles.contains(role['name']),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedRoles.add(role['name']);
                                } else {
                                  _selectedRoles.remove(role['name']);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: widget.onCancel ?? () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Guardar Cambios' : 'Crear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersManagementScreenState extends State<_UsersManagementScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _selectedUser;

  // Filtros
  String _searchQuery = '';
  String _selectedStatus = 'Todos';
  String _selectedRole = 'Todos';

  final List<String> _statusOptions = ['Todos', 'Activos', 'Inactivos'];
  final List<String> _roleOptions = [
    'Todos',
    'admin',
    'user',
    'emprendedor',
    'moderador',
  ];

  bool _showUserForm = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _dashboardService.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
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

  void _applyFilters() {
    setState(() {
      _filteredUsers =
          _users.where((user) {
            final name = (user['name'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            final roles =
                (user['roles'] as List? ?? []).map((r) {
                  if (r is Map && r.containsKey('name'))
                    return r['name'].toString();
                  return r.toString();
                }).toList();
            final status = (user['active'] == true) ? 'Activos' : 'Inactivos';

            final matchesQuery =
                _searchQuery.isEmpty ||
                name.contains(_searchQuery.toLowerCase()) ||
                email.contains(_searchQuery.toLowerCase());
            final matchesStatus =
                _selectedStatus == 'Todos' || status == _selectedStatus;
            final matchesRole =
                _selectedRole == 'Todos' || roles.contains(_selectedRole);
            return matchesQuery && matchesStatus && matchesRole;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showUserForm) {
      return _UserFormScreen(
        user: _selectedUser,
        onCancel: () {
          setState(() {
            _showUserForm = false;
            _selectedUser = null;
          });
          _fetchUsers();
        },
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestión de Usuarios',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedUser = null;
                      _showUserForm = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Usuario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Filtros de búsqueda
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o email',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            items:
                                _statusOptions
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(() => _selectedStatus = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items:
                                _roleOptions
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          role[0].toUpperCase() +
                                              role.substring(1),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(() => _selectedRole = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_alt_rounded),
                        label: const Text('Filtrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _filteredUsers.isEmpty
                      ? const Center(child: Text('No se encontraron usuarios'))
                      : Container(
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
                          itemCount: _filteredUsers.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final roles =
                                (user['roles'] as List? ?? [])
                                    .map((r) {
                                      if (r is Map && r.containsKey('name'))
                                        return r['name'].toString();
                                      return r.toString();
                                    })
                                    .toList();
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getUserRoleColor(
                                  roles.isNotEmpty ? roles.first : '',
                                ),
                                backgroundImage:
                                    user['foto_perfil'] != null
                                        ? NetworkImage(user['foto_perfil'])
                                        : null,
                                child:
                                    user['foto_perfil'] == null
                                        ? Text(
                                          (user['name'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                        : null,
                              ),
                              title: Text(
                                user['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? ''),
                                  if (user['phone'] != null &&
                                      user['phone'].toString().isNotEmpty)
                                    Text(
                                      user['phone'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (roles.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          roles
                                              .map<Widget>(
                                                (role) => Chip(
                                                  label: Text(
                                                    role,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFF9C27B0,
                                                  ).withOpacity(0.1),
                                                  labelStyle: const TextStyle(
                                                    color: Color(0xFF9C27B0),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                              )
                                              .toList(),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getUserStatusColor(
                                        user['active'] == true
                                            ? 'active'
                                            : 'inactive',
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user['active'] == true
                                          ? 'Activo'
                                          : 'Inactivo',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Editar',
                                    onPressed: () {
                                      setState(() {
                                        _selectedUser = user;
                                        _showUserForm = true;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Eliminar',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Eliminar usuario'),
                                          content: const Text('¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                          String? token = authProvider.token;
                                          if (token == null) {
                                            print('Token en AuthProvider es null, intentando obtener de AuthService...');
                                            token = await AuthService().getToken();
                                            if (token == null) {
                                              print('Token sigue siendo null. Redirigiendo a login.');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.'), backgroundColor: Colors.red),
                                              );
                                              Navigator.pushReplacementNamed(context, '/login');
                                              return;
                                            }
                                          }
                                          print('--- ELIMINAR USUARIO ---');
                                          print('Token: $token');
                                          print('URL: ${ApiConfig.getUserUrl(user['id'])}');
                                          final response = await http.delete(
                                            Uri.parse(ApiConfig.getUserUrl(user['id'])),
                                            headers: {
                                              'Authorization': 'Bearer $token',
                                              'Accept': 'application/json',
                                            },
                                          );
                                          print('Status: ${response.statusCode}');
                                          print('Body: ${response.body}');
                                          if (response.statusCode == 200) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Usuario eliminado exitosamente'), backgroundColor: Colors.green),
                                            );
                                            _fetchUsers();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: ${response.body}'), backgroundColor: Colors.red),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error al eliminar usuario: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      user['active'] == true
                                          ? Icons.block
                                          : Icons.check_circle,
                                      color:
                                          user['active'] == true
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                    tooltip:
                                        user['active'] == true
                                            ? 'Desactivar'
                                            : 'Activar',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(user['active'] == true ? 'Desactivar usuario' : 'Activar usuario'),
                                          content: Text(user['active'] == true
                                              ? '¿Estás seguro de que deseas desactivar este usuario?'
                                              : '¿Estás seguro de que deseas activar este usuario?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: user['active'] == true ? Colors.orange : Colors.green,
                                              ),
                                              child: Text(user['active'] == true ? 'Desactivar' : 'Activar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                          String? token = authProvider.token;
                                          if (token == null) {
                                            print('Token en AuthProvider es null, intentando obtener de AuthService...');
                                            token = await AuthService().getToken();
                                            if (token == null) {
                                              print('Token sigue siendo null. Redirigiendo a login.');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.'), backgroundColor: Colors.red),
                                              );
                                              Navigator.pushReplacementNamed(context, '/login');
                                              return;
                                            }
                                          }
                                          final action = user['active'] == true ? 'deactivate' : 'activate';
                                          final url = ApiConfig.getUserUrl(user['id']) + '/$action';
                                          print('--- ${action.toUpperCase()} USUARIO ---');
                                          print('Token: $token');
                                          print('URL: $url');
                                          final response = await http.post(
                                            Uri.parse(url),
                                            headers: {
                                              'Authorization': 'Bearer $token',
                                              'Accept': 'application/json',
                                            },
                                          );
                                          print('Status: ${response.statusCode}');
                                          print('Body: ${response.body}');
                                          if (response.statusCode == 200) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(user['active'] == true
                                                    ? 'Usuario desactivado exitosamente'
                                                    : 'Usuario activado exitosamente'),
                                                backgroundColor: user['active'] == true ? Colors.orange : Colors.green,
                                              ),
                                            );
                                            _fetchUsers();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: ${response.body}'), backgroundColor: Colors.red),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error al activar/desactivar usuario: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.lock,
                                      color: Color(0xFF9C27B0),
                                    ),
                                    tooltip: 'Permisos',
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUserRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'emprendedor':
        return Colors.green;
      case 'moderador':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getUserStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _RolesManagementScreen extends StatefulWidget {
  const _RolesManagementScreen();

  @override
  State<_RolesManagementScreen> createState() => _RolesManagementScreenState();
}

class _RolesManagementScreenState extends State<_RolesManagementScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<List<Map<String, dynamic>>> _rolesFuture;
  bool _showRoleForm = false;
  Map<String, dynamic>? _selectedRole;

  @override
  void initState() {
    super.initState();
    _rolesFuture = _dashboardService.getRoles();
  }

  void _refreshRoles() {
    setState(() {
      _showRoleForm = false;
      _selectedRole = null;
      _rolesFuture = _dashboardService.getRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showRoleForm) {
      return _RoleFormScreen(
        role: _selectedRole,
        onCancel: _refreshRoles,
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestión de Roles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedRole = null;
                      _showRoleForm = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Rol'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _rolesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No se encontraron roles.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshRoles,
                            child: const Text('Volver a intentar'),
                          )
                        ],
                      ),
                    );
                  }

                  final roles = snapshot.data!;
                  return ListView.builder(
                    itemCount: roles.length,
                    itemBuilder: (context, index) {
                      final role = roles[index];
                      final permissions = (role['permissions'] as List? ?? [])
                          .map((p) => p['name'].toString())
                          .toList();

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        const Color(0xFF9C27B0).withOpacity(0.1),
                                    child: Text(
                                      (role['name'] ?? 'R')[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Color(0xFF9C27B0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role['name'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          'ID: ${role['id']} | ${permissions.length} permisos',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        setState(() {
                                          _selectedRole = role;
                                          _showRoleForm = true;
                                        });
                                      }
                                      // TODO: Implementar acción de eliminar
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Editar')),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Eliminar')),
                                    ],
                                  ),
                                ],
                              ),
                              if (permissions.isNotEmpty) ...[
                                const Divider(height: 24),
                                Text('Permisos:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: permissions.take(10).map((p) => Chip(
                                    label: Text(p, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.grey[200],
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  )).toList(),
                                ),
                                if(permissions.length > 10)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('+${permissions.length - 10} más...', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                                  )
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleFormScreen extends StatefulWidget {
  final Map<String, dynamic>? role;
  final VoidCallback onCancel;

  const _RoleFormScreen({this.role, required this.onCancel});

  @override
  _RoleFormScreenState createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<_RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _dashboardService = DashboardService();

  Map<String, List<Map<String, dynamic>>> _groupedPermissions = {};
  Set<int> _selectedPermissionIds = {};
  bool _isLoading = true;
  String? _error;

  bool get isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.role!['name'];
      _selectedPermissionIds =
          (widget.role!['permissions'] as List<dynamic>?)
              ?.map<int>((p) => p['id'])
              .toSet() ??
              {};
    }
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    try {
      final permissions = await _dashboardService.getPermissions();
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (var p in permissions) {
        final name = p['name'] as String;
        final groupName = name.split('_').first;
        final capitalizedGroup = groupName[0].toUpperCase() + groupName.substring(1);
        
        if (!grouped.containsKey(capitalizedGroup)) {
          grouped[capitalizedGroup] = [];
        }
        grouped[capitalizedGroup]!.add(p);
      }
      if(mounted) {
        setState(() {
          _groupedPermissions = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
        _error = "Error al cargar permisos: $e";
        _isLoading = false;
      });
      }
    }
  }
  
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (isEditing) {
          await _dashboardService.updateRole(
            widget.role!['id'],
            _nameController.text,
            _selectedPermissionIds.toList(),
          );
        } else {
          await _dashboardService.createRole(
            _nameController.text,
            _selectedPermissionIds.toList(),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rol ${isEditing ? 'actualizado' : 'creado'} con éxito'),
          backgroundColor: Colors.green,
        ));
        widget.onCancel();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Rol' : 'Crear Rol'),
        backgroundColor: const Color(0xFF9C27B0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del rol',
                                hintText: 'editor, manager, etc.',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese un nombre para el rol';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                             Text(
                              'Permisos',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seleccione los permisos que tendrán los usuarios con este rol.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                             Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedPermissionIds = _groupedPermissions.values
                                            .expand((list) => list)
                                            .map<int>((p) => p['id'])
                                            .toSet();
                                      });
                                    },
                                    child: const Text('Seleccionar Todo'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() => _selectedPermissionIds.clear()),
                                    child: const Text('Deseleccionar Todo'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: _groupedPermissions.entries.map((entry) {
                            final groupName = entry.key;
                            final permissionsInGroup = entry.value;
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ExpansionTile(
                                title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                children: [
                                   Padding(
                                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                     child: Row(
                                       children: [
                                          Expanded(
                                            child: TextButton(
                                              child: const Text('Seleccionar Grupo'),
                                              onPressed: () => setState(() {
                                                _selectedPermissionIds.addAll(permissionsInGroup.map<int>((p) => p['id']));
                                              }),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextButton(
                                              child: const Text('Quitar Grupo'),
                                              onPressed: () => setState(() {
                                                _selectedPermissionIds.removeAll(permissionsInGroup.map<int>((p) => p['id']));
                                              }),
                                            ),
                                          ),
                                       ],
                                     ),
                                   ),
                                  ...permissionsInGroup.map((permission) {
                                    final permissionId = permission['id'] as int;
                                    return CheckboxListTile(
                                      title: Text(permission['name']),
                                      value: _selectedPermissionIds.contains(permissionId),
                                      onChanged: (bool? selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedPermissionIds.add(permissionId);
                                          } else {
                                            _selectedPermissionIds.remove(permissionId);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: widget.onCancel,
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9C27B0),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isEditing ? 'Guardar Cambios' : 'Crear Rol'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _PermissionsManagementScreen extends StatefulWidget {
  const _PermissionsManagementScreen();

  @override
  State<_PermissionsManagementScreen> createState() => _PermissionsManagementScreenState();
}

class _PermissionsManagementScreenState extends State<_PermissionsManagementScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _permissions = [];
  Map<String, List<Map<String, dynamic>>> _groupedPermissions = {};
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final permissions = await _dashboardService.getPermissions();
      setState(() {
        _permissions = permissions;
        _groupedPermissions = _groupPermissions(permissions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupPermissions(List<Map<String, dynamic>> permissions) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var p in permissions) {
      final name = p['name'] as String;
      final groupName = name.split('_').first;
      final capitalizedGroup = groupName[0].toUpperCase() + groupName.substring(1);
      if (!grouped.containsKey(capitalizedGroup)) {
        grouped[capitalizedGroup] = [];
      }
      grouped[capitalizedGroup]!.add(p);
    }
    return grouped;
  }

  Map<String, List<Map<String, dynamic>>> get _filteredGroupedPermissions {
    if (_searchQuery.isEmpty) return _groupedPermissions;
    final filtered = <String, List<Map<String, dynamic>>>{};
    _groupedPermissions.forEach((group, perms) {
      final matches = perms.where((p) => (p['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      if (matches.isNotEmpty) filtered[group] = matches;
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permisos del Sistema',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Los permisos son las acciones específicas que los usuarios pueden realizar en el sistema. Estos permisos se asignan a roles, y los roles se asignan a usuarios.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar permisos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _filteredGroupedPermissions.isEmpty
                          ? const Center(child: Text('No se encontraron permisos.'))
                          : ListView(
                              children: _filteredGroupedPermissions.entries.map((entry) {
                                final group = entry.key;
                                final perms = entry.value;
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              group,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF9C27B0).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${perms.length} permisos',
                                                style: const TextStyle(
                                                  color: Color(0xFF9C27B0),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...perms.map((p) => ListTile(
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              leading: const Icon(Icons.lock_outline, color: Color(0xFF9C27B0), size: 20),
                                              title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                              subtitle: Text('ID: ${p['id']}', style: const TextStyle(fontSize: 12)),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class AsociacionesManagementScreen extends StatelessWidget {
  const AsociacionesManagementScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderScreen(title: 'Gestión de Asociaciones');
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
