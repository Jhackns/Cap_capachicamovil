import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/theme_switcher.dart';

const Color kPurplePrimary = Color(0xFF9C27B0); // Purple 500

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _drawerOpen = false;
  late AnimationController _controller;
  late Animation<double> _drawerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerAnimation = Tween<double>(begin: 0, end: 260).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
      if (_drawerOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onProfileTap() {
    Navigator.pushNamed(context, '/profile');
  }

  void _onSettingsTap() {
    Navigator.pushNamed(context, '/settings');
  }

  void _onLogoutTap(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar el diálogo
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login',
                  (route) => false, // Elimina todas las rutas anteriores
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final userName = authProvider.currentUser?.name ?? 'Administrador';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Panel de Control', style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: kPurplePrimary),
              tooltip: 'Configuración',
              onPressed: _onSettingsTap,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'Cerrar sesión',
              onPressed: () => _onLogoutTap(authProvider),
            ),
            const SizedBox(width: 8),
            const ThemeSwitcher(),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_drawerAnimation.value, 0),
                child: child,
              );
            },
            child: _buildDashboardContent(context, isAdmin, authProvider),
          ),
          if (isAdmin)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return Positioned(
                  left: -260 + _drawerAnimation.value,
                  top: 0,
                  bottom: 0,
                  child: _AdminDrawer(
                    userName: userName,
                    onClose: _toggleDrawer,
                    open: _drawerOpen,
                  ),
                );
              },
            ),
          if (isAdmin)
            Positioned(
              left: _drawerOpen ? 250 : 0,
              top: 80,
              child: GestureDetector(
                onTap: _toggleDrawer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 64,
                  decoration: BoxDecoration(
                    color: kPurplePrimary,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(_drawerOpen ? 0 : 16),
                      left: Radius.circular(_drawerOpen ? 16 : 0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _drawerOpen ? Icons.arrow_left : Icons.arrow_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, bool isAdmin, AuthProvider authProvider) {
    return Container(
      color: kPurplePrimary.withOpacity(0.05),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida al usuario (clickeable)
              GestureDetector(
                onTap: _onProfileTap,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: kPurplePrimary,
                          radius: 24,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido/a,',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              authProvider.currentUser?.name ?? 'Usuario',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kPurplePrimary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: kPurplePrimary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Título de secciones
              Text(
                'Panel de estadísticas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPurplePrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Estadísticas
              _buildStatsCards(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    // Datos de ejemplo (puedes conectar con backend luego)
    final stats = {
      'total_users': 26,
      'active_users': 24,
      'total_roles': 2,
      'total_permissions': 8,
    };

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Total Usuarios',
          stats['total_users'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Usuarios Activos',
          stats['active_users'].toString(),
          Icons.person,
          Colors.green,
        ),
        _buildStatCard(
          'Roles',
          stats['total_roles'].toString(),
          Icons.security,
          Colors.orange,
        ),
        _buildStatCard(
          'Permisos',
          stats['total_permissions'].toString(),
          Icons.lock,
          kPurplePrimary,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String userName;
  final VoidCallback onClose;
  final bool open;

  const _AdminDrawer({
    required this.userName,
    required this.onClose,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: kPurplePrimary,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        width: 260,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Mi dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (open)
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Colors.white),
                    onPressed: onClose,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '¡Bienvenido,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              userName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Gestiones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _DrawerOption(
              icon: Icons.edit,
              label: 'Gestionar Emprendedores',
              onTap: () {
                Navigator.pushNamed(context, '/admin-dashboard');
                onClose();
              },
            ),
            // Aquí puedes agregar más opciones de gestión por categoría
            // Ejemplo:
            // _DrawerOption(
            //   icon: Icons.category,
            //   label: 'Gestionar Categorías',
            //   onTap: () {},
            // ),
            const Spacer(),
            Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Inicio', style: TextStyle(color: Colors.white)),
              onTap: onClose,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.white10,
    );
  }
}
