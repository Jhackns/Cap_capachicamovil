import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/user.dart';
import '../services/dashboard_service.dart';

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
  
  // Datos del dashboard
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _permissions = [];
  
  final DashboardService _dashboardService = DashboardService();

  final List<Widget> _screens = [
    const _DashboardContent(),
    const _UsersManagementScreen(),
    const _RolesManagementScreen(),
    const _PermissionsManagementScreen(),
    const _EntrepreneursManagementScreen(),
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
      // Cargar estadísticas del dashboard
      final stats = await _dashboardService.getDashboardStats();
      
      // Cargar datos completos
      final users = await _dashboardService.getUsers();
      final roles = await _dashboardService.getRoles();
      final permissions = await _dashboardService.getPermissions();
      
      if (mounted) {
        setState(() {
          _stats = stats;
          _users = users;
          _roles = roles;
          _permissions = permissions;
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
    Navigator.pop(context); // Cierra el drawer
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;
    
    // Check if user is admin, if not redirect to home
    if (!authProvider.isAuthenticated) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!authProvider.isAdmin) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/dashboard'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Toggle de vista (solo para pantallas de gestión)
          if (_selectedIndex > 0)
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              tooltip: _isGridView ? 'Vista de lista' : 'Vista de cuadrícula',
            ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $_error', textAlign: TextAlign.center),
                  ),
                )
              : _screens[_selectedIndex],
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF9C27B0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.name?.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Administrador',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'admin@email.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Administrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFF9C27B0)),
            title: const Text('Panel de Control'),
            selected: _selectedIndex == 0,
            onTap: () => _onDrawerItemTapped(0),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'GESTIÓN DE USUARIOS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Color(0xFF9C27B0)),
            title: const Text('Usuarios'),
            selected: _selectedIndex == 1,
            onTap: () => _onDrawerItemTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Color(0xFF9C27B0)),
            title: const Text('Roles'),
            selected: _selectedIndex == 2,
            onTap: () => _onDrawerItemTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Color(0xFF9C27B0)),
            title: const Text('Permisos'),
            selected: _selectedIndex == 3,
            onTap: () => _onDrawerItemTapped(3),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'GESTIÓN DE CONTENIDO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Color(0xFF9C27B0)),
            title: const Text('Emprendedores'),
            selected: _selectedIndex == 4,
            onTap: () => _onDrawerItemTapped(4),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF9C27B0)),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF9C27B0)),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF9C27B0)),
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
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  final DashboardService _dashboardService = DashboardService();

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
      final stats = await _dashboardService.getDashboardStats();
      
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final stats = _stats ?? {};
    final recentUsers = stats['recent_users'] as List? ?? [];
    final usersByRole = stats['users_by_role'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 30,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panel de Administración',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gestión completa del sistema',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Estadísticas rápidas
            const Text(
              'Estadísticas del Sistema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Total Usuarios',
                  value: stats['total_users']?.toString() ?? '0',
                  icon: Icons.people,
                  color: const Color(0xFF9C27B0),
                ),
                _StatCard(
                  title: 'Usuarios Activos',
                  value: stats['active_users']?.toString() ?? '0',
                  icon: Icons.person,
                  color: const Color(0xFF38A169),
                ),
                _StatCard(
                  title: 'Roles',
                  value: stats['total_roles']?.toString() ?? '0',
                  icon: Icons.security,
                  color: const Color(0xFFE53E3E),
                ),
                _StatCard(
                  title: 'Permisos',
                  value: stats['total_permissions']?.toString() ?? '0',
                  icon: Icons.lock,
                  color: const Color(0xFFD69E2E),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Usuarios por rol
            if (usersByRole.isNotEmpty) ...[
              const Text(
                'Usuarios por Rol',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: usersByRole.map((roleData) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getRoleColor(roleData['role']),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                roleData['role']?.toString().toUpperCase() ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            roleData['count']?.toString() ?? '0',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Usuarios recientes
            if (recentUsers.isNotEmpty) ...[
              const Text(
                'Usuarios Recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: recentUsers.map((user) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(user['name'] ?? 'Usuario'),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user['active'] == true)
                            const Icon(Icons.check_circle, color: Colors.green, size: 16)
                          else
                            const Icon(Icons.cancel, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _extractRoleName(user['roles']),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
            
            // Espacio adicional para evitar problemas con el RefreshIndicator
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return const Color(0xFFE53E3E); // Red
      case 'user':
        return const Color(0xFF3182CE); // Blue
      case 'emprendedor':
        return const Color(0xFF38A169); // Green
      case 'moderador':
        return const Color(0xFFD69E2E); // Yellow
      default:
        return const Color(0xFF718096); // Gray
    }
  }

  String _extractRoleName(dynamic roles) {
    if (roles == null) return 'USER';
    
    if (roles is List) {
      if (roles.isEmpty) return 'USER';
      
      final firstRole = roles.first;
      if (firstRole is String) {
        return firstRole.toUpperCase();
      } else if (firstRole is Map) {
        return (firstRole['name'] ?? firstRole['NAME'] ?? 'USER').toString().toUpperCase();
      }
    }
    
    return 'USER';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersManagementScreen extends StatefulWidget {
  const _UsersManagementScreen();

  @override
  State<_UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<_UsersManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  final DashboardService _dashboardService = DashboardService();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
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
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e')),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _users.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final role = _extractRoleName(user['roles']).toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) ||
            email.contains(searchLower) ||
            role.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterUsers,
            decoration: InputDecoration(
              labelText: 'Buscar usuarios...',
              hintText: 'Buscar por nombre, email o rol',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay usuarios registrados'
                                : 'No se encontraron usuarios',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(user['name'] ?? 'Usuario'),
                              subtitle: Text(user['email'] ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (user['active'] == true)
                                    const Icon(Icons.check_circle, color: Colors.green, size: 16)
                                  else
                                    const Icon(Icons.cancel, color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _extractRoleName(user['roles']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  String _extractRoleName(dynamic roles) {
    if (roles == null) return 'USER';
    
    if (roles is List) {
      if (roles.isEmpty) return 'USER';
      
      final firstRole = roles.first;
      if (firstRole is String) {
        return firstRole.toUpperCase();
      } else if (firstRole is Map) {
        return (firstRole['name'] ?? firstRole['NAME'] ?? 'USER').toString().toUpperCase();
      }
    }
    
    return 'USER';
  }
}

class _RolesManagementScreen extends StatelessWidget {
  const _RolesManagementScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Color(0xFF9C27B0),
          ),
          SizedBox(height: 16),
          Text(
            'Gestión de Roles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Funcionalidad próximamente disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsManagementScreen extends StatefulWidget {
  const _PermissionsManagementScreen();

  @override
  State<_PermissionsManagementScreen> createState() => __PermissionsManagementScreenState();
}

class __PermissionsManagementScreenState extends State<_PermissionsManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _permissions = [];
  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    try {
      final permissions = await _dashboardService.getPermissions();
      if (mounted) {
        setState(() {
          _permissions = permissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar permisos: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadPermissions,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _permissions.length,
              itemBuilder: (context, index) {
                final permission = _permissions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.lock_person, color: Color(0xFF9C27B0)),
                    title: Text(permission['name'] ?? 'Permiso sin nombre'),
                    subtitle: Text('ID: ${permission['id']} | Guard: ${permission['guard_name']}'),
                  ),
                );
              },
            ),
          );
  }
}

class _EntrepreneursManagementScreen extends StatelessWidget {
  const _EntrepreneursManagementScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: Color(0xFF9C27B0),
          ),
          SizedBox(height: 16),
          Text(
            'Gestión de Emprendedores',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Funcionalidad próximamente disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
