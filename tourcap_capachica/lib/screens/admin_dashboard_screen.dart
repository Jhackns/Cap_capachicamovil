import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../widgets/entrepreneur_card.dart';
import '../models/entrepreneur.dart';
import '../blocs/entrepreneur/entrepreneur_bloc.dart';
import '../blocs/entrepreneur/entrepreneur_event.dart';
import '../blocs/entrepreneur/entrepreneur_state.dart';
import '../services/dashboard_service.dart';
import '../widgets/custom_app_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>>? _recentUsers;
  List<Map<String, dynamic>>? _usersByRole;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Datos de ejemplo para mostrar mientras se cargan los datos reales
    _recentUsers = [
      {
        'name': 'Admin User',
        'email': 'admin@example.com',
        'roles': ['admin'],
      },
      {
        'name': 'Juan Pérez',
        'email': 'juan@example.com',
        'roles': ['user'],
      },
      {
        'name': 'María García',
        'email': 'maria@example.com',
        'roles': ['user'],
      },
    ];
    
    _usersByRole = [
      {
        'role': 'admin',
        'count': 1,
        'color': Colors.red,
      },
      {
        'role': 'user',
        'count': 25,
        'color': Colors.blue,
      },
    ];
    
    // Fetch entrepreneurs when screen loads
    Future.microtask(() => 
      context.read<EntrepreneurBloc>().add(FetchEntrepreneurs())
    );
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _tipoServicioController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    _emailController.dispose();
    _horarioAtencionController.dispose();
    _precioRangoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
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

    return BlocListener<EntrepreneurBloc, EntrepreneurState>(
      listener: (context, state) {
        if (state is EntrepreneurSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          if (_currentEntrepreneur != null) {
            _resetForm();
            _tabController.animateTo(0);
          }
        } else if (state is EntrepreneurError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Panel de Administración'),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorWidget()
                : _buildDashboardContent(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/entrepreneur-management');
          },
          child: const Icon(Icons.add),
          tooltip: 'Gestionar Emprendedores',
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
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

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de estadísticas
            _buildStatsCards(),
            const SizedBox(height: 24),
            
            // Usuarios por rol
            _buildUsersByRoleSection(),
            const SizedBox(height: 24),
            
            // Usuarios recientes
            _buildRecentUsersSection(),
            const SizedBox(height: 24),
            
            // Acciones rápidas
            _buildQuickActions(),
            
            // Espacio adicional para evitar problemas con el RefreshIndicator
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    // Usar datos de ejemplo si _stats es null
    final stats = _stats ?? {
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
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Usuarios',
          stats['total_users']?.toString() ?? '0',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Usuarios Activos',
          stats['active_users']?.toString() ?? '0',
          Icons.person,
          Colors.green,
        ),
        _buildStatCard(
          'Roles',
          stats['total_roles']?.toString() ?? '0',
          Icons.security,
          Colors.orange,
        ),
        _buildStatCard(
          'Permisos',
          stats['total_permissions']?.toString() ?? '0',
          Icons.lock,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildUsersByRoleSection() {
    final usersByRole = _stats?['users_by_role'] as List? ?? _usersByRole;
    if (usersByRole == null || usersByRole.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuarios por Rol',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...usersByRole.map((roleData) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    roleData['role']?.toString().toUpperCase() ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsersSection() {
    final recentUsers = _stats?['recent_users'] as List? ?? _recentUsers;
    if (recentUsers == null || recentUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuarios Recientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recentUsers.take(5).map((user) => ListTile(
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
              trailing: SizedBox(
                width: 60, // Ancho fijo para evitar que consuma todo el espacio
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
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionButton(
                  'Gestionar Emprendedores',
                  Icons.business,
                  () => Navigator.pushNamed(context, '/entrepreneur-management'),
                ),
                _buildActionButton(
                  'Ver Usuarios',
                  Icons.people,
                  () => Navigator.pushNamed(context, '/users'),
                ),
                _buildActionButton(
                  'Configuración',
                  Icons.settings,
                  () => Navigator.pushNamed(context, '/settings'),
                ),
                _buildActionButton(
                  'Cerrar Sesión',
                  Icons.logout,
                  () async {
                    await context.read<AuthProvider>().logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar estadísticas del dashboard
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

  Widget _buildEntrepreneursList() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EntrepreneurBloc>().add(FetchEntrepreneurs());
      },
      child: BlocBuilder<EntrepreneurBloc, EntrepreneurState>(
        builder: (context, state) {
          if (state is EntrepreneurLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EntrepreneurError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar emprendedores',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<EntrepreneurBloc>().add(FetchEntrepreneurs()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (state is EntrepreneurLoaded) {
            if (state.entrepreneurs.isEmpty) {
              return const Center(
                child: Text('No hay emprendedores disponibles'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: state.entrepreneurs.length,
              itemBuilder: (context, index) {
                final entrepreneur = state.entrepreneurs[index];
                return EntrepreneurCard(
                  entrepreneur: entrepreneur,
                  isAdmin: true,
                  onTap: () {
                    _showEntrepreneurDetails(context, entrepreneur);
                  },
                  onEdit: () {
                    _tabController.animateTo(1);
                    _showEditEntrepreneurForm(context, entrepreneur);
                  },
                  onDelete: () {
                    _confirmDelete(context, entrepreneur);
                  },
                  showEditButton: true,
                  showDeleteButton: true,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tipoServicioController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _emailController = TextEditingController();
  final _horarioAtencionController = TextEditingController();
  final _precioRangoController = TextEditingController();
  Entrepreneur? _currentEntrepreneur;
  String? _selectedTipoServicio;
  String? _selectedLocation;
  String? _selectedCategoria;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _estado = true;
  
  // Variables para el horario
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 18, minute: 0);
  final Set<int> _diasSeleccionados = {1, 2, 3, 4, 5, 6, 7}; // Por defecto todos los días
  final List<String> _diasSemana = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  
  // Opciones predefinidas para tipo de servicio
  final List<String> _tipoServicioOptions = [
    'Hospedaje',
    'Gastronomía',
    'Artesanía',
    'Turismo vivencial',
    'Transporte',
    'Guía turístico',
    'Otro'
  ];
  
  // Opciones predefinidas para ubicación
  final List<String> _locationOptions = [
    'Capachica - Centro',
    'Llachón',
    'Chifrón',
    'Ccotos',
    'Siale',
    'Escallani',
    'Paramis',
    'Otro lugar en Capachica'
  ];

  // Opciones predefinidas para categoría
  final List<String> _categoriaOptions = [
    'Turismo',
    'Hospedaje',
    'Gastronomía',
    'Artesanía',
    'Otro'
  ];

  Widget _buildManageEntrepreneurForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentEntrepreneur == null ? 'Agregar Emprendedor' : 'Editar Emprendedor',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Nombre del emprendedor',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Tipo de Servicio dropdown
            DropdownButtonFormField<String>(
              value: _selectedTipoServicio,
              decoration: const InputDecoration(
                labelText: 'Tipo de Servicio',
                prefixIcon: Icon(Icons.category),
              ),
              items: _tipoServicioOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTipoServicio = newValue;
                  _tipoServicioController.text = newValue ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona el tipo de servicio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción del emprendedor',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                hintText: 'ejemplo@dominio.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un correo electrónico';
                }
                // Validación de correo electrónico
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value)) {
                  return 'Ingresa un correo electrónico válido';
                }
                if (value.length > 100) {
                  return 'El correo no debe exceder los 100 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Horario de Atención field
            InkWell(
              onTap: _showHorarioSelector,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Horario de Atención',
                  hintText: 'Selecciona el horario',
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _horarioAtencionController.text.isEmpty
                          ? 'Seleccionar horario'
                          : _horarioAtencionController.text,
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _showDiasSelector,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Rango de Precios field
            TextFormField(
              controller: _precioRangoController,
              decoration: const InputDecoration(
                labelText: 'Rango de Precios',
                hintText: 'Ej: 50-100 USD',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un rango de precios';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Categoría dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categoriaOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategoria = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Estado switch
            SwitchListTile(
              title: const Text('Activo'),
              value: _estado,
              onChanged: (bool value) {
                setState(() {
                  _estado = value;
                });
              },
              secondary: const Icon(Icons.toggle_on),
            ),
            const SizedBox(height: 16),
            
            // Image selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imagen del emprendedor',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _imageUrlController.text.isNotEmpty && !_imageUrlController.text.startsWith('/')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.broken_image, size: 40),
                                      );
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                                ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Seleccionar de galería'),
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (_selectedImage != null || _imageUrlController.text.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Quitar imagen', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _imageUrlController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location dropdown
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _locationOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue;
                  _locationController.text = newValue ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona la ubicación';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Contact info field (Teléfono)
            TextFormField(
              controller: _contactInfoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                hintText: 'Ej: +51987654321 o 987654321',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 12, // +51 + 9 dígitos
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un número de teléfono';
                }
                // Validar formato: +51 seguido de 9 dígitos O 9 dígitos
                if (!RegExp(r'^(\+51\d{9}|\d{9})$').hasMatch(value)) {
                  return 'Ingresa un número válido (+51 + 9 dígitos o 9 dígitos)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _resetForm();
                      _tabController.animateTo(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<EntrepreneurBloc, EntrepreneurState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is EntrepreneurLoading
                            ? null
                            : () => _saveEntrepreneur(context),
                        child: state is EntrepreneurLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_currentEntrepreneur == null ? 'Agregar' : 'Actualizar'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEntrepreneurForm(BuildContext context, Entrepreneur entrepreneur) {
    setState(() {
      _currentEntrepreneur = entrepreneur;
      _nameController.text = entrepreneur.name;
      _descriptionController.text = entrepreneur.description ?? '';
      _imageUrlController.text = entrepreneur.imageUrl ?? '';
      _tipoServicioController.text = entrepreneur.tipoServicio;
      _locationController.text = entrepreneur.location;
      _contactInfoController.text = entrepreneur.contactInfo;
      _emailController.text = entrepreneur.email;
      
      // Parsear el horario de atención
      final horarioParts = entrepreneur.horarioAtencion.split(' ');
      if (horarioParts.isNotEmpty) {
        final horas = horarioParts[0].split('-');
        if (horas.length == 2) {
          final inicio = horas[0].split(':');
          final fin = horas[1].split(':');
          if (inicio.length == 2 && fin.length == 2) {
            _horaInicio = TimeOfDay(
              hour: int.parse(inicio[0]),
              minute: int.parse(inicio[1]),
            );
            _horaFin = TimeOfDay(
              hour: int.parse(fin[0]),
              minute: int.parse(fin[1]),
            );
          }
        }
        
        // Parsear días
        if (horarioParts.length > 1) {
          final diasStr = horarioParts[1].replaceAll('(', '').replaceAll(')', '');
          _diasSeleccionados.clear();
          for (var i = 0; i < _diasSemana.length; i++) {
            if (diasStr.contains(_diasSemana[i])) {
              _diasSeleccionados.add(i + 1);
            }
          }
        }
      }
      
      _horarioAtencionController.text = entrepreneur.horarioAtencion;
      _precioRangoController.text = entrepreneur.precioRango;
      _selectedCategoria = entrepreneur.categoria;
      _estado = entrepreneur.estado;
      
      // Actualizar los valores seleccionados en los dropdowns
      _selectedTipoServicio = _tipoServicioOptions.contains(entrepreneur.tipoServicio) 
          ? entrepreneur.tipoServicio 
          : _tipoServicioOptions.firstWhere(
              (option) => option.toLowerCase().contains(entrepreneur.tipoServicio.toLowerCase()) || 
                          entrepreneur.tipoServicio.toLowerCase().contains(option.toLowerCase()),
              orElse: () => _tipoServicioOptions.last
            );
      
      _selectedLocation = _locationOptions.contains(entrepreneur.location) 
          ? entrepreneur.location 
          : _locationOptions.firstWhere(
              (option) => option.toLowerCase().contains(entrepreneur.location.toLowerCase()) || 
                          entrepreneur.location.toLowerCase().contains(option.toLowerCase()),
              orElse: () => _locationOptions.last
            );
      
      _selectedImage = null;
      
      if (entrepreneur.imageUrl != null && entrepreneur.imageUrl!.startsWith('/')) {
        _selectedImage = File(entrepreneur.imageUrl!);
      }
    });
  }

  void _resetForm() {
    setState(() {
      _currentEntrepreneur = null;
      _nameController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _tipoServicioController.clear();
      _locationController.clear();
      _contactInfoController.clear();
      _emailController.clear();
      _horarioAtencionController.clear();
      _precioRangoController.clear();
      _selectedTipoServicio = null;
      _selectedLocation = null;
      _selectedCategoria = null;
      _selectedImage = null;
      _estado = true;
      
      // Resetear horario
      _horaInicio = const TimeOfDay(hour: 8, minute: 0);
      _horaFin = const TimeOfDay(hour: 18, minute: 0);
      _diasSeleccionados.clear();
      _diasSeleccionados.addAll([1, 2, 3, 4, 5, 6, 7]);
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
          // Podemos guardar la ruta en el controlador de imagen para mantener compatibilidad
          _imageUrlController.text = pickedImage.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _saveEntrepreneur(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = _imageUrlController.text.isEmpty ? null : _imageUrlController.text;
      
      final entrepreneur = Entrepreneur(
        id: _currentEntrepreneur?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: imageUrl,
        tipoServicio: _selectedTipoServicio ?? _tipoServicioOptions[0],
        location: _selectedLocation ?? _locationOptions[0],
        contactInfo: _contactInfoController.text,
        email: _emailController.text,
        categoria: _selectedCategoria ?? _categoriaOptions[0],
        horarioAtencion: _horarioAtencionController.text,
        precioRango: _precioRangoController.text,
        estado: _estado,
      );

      if (_currentEntrepreneur == null) {
        context.read<EntrepreneurBloc>().add(AddEntrepreneur(entrepreneur.toJson()));
        // Reset form and navigate to list after successful creation
        _resetForm();
        _tabController.animateTo(0);
      } else {
        context.read<EntrepreneurBloc>().add(UpdateEntrepreneur(entrepreneur.toJson()));
      }
    }
  }

  void _showEntrepreneurDetails(BuildContext context, Entrepreneur entrepreneur) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      entrepreneur.imageUrl ?? 'https://via.placeholder.com/400x300?text=No+disponible',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 40),
                        );
                      },
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entrepreneur.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/dashboard');
                              },
                            ),
                          ],
                        ),
                        if (entrepreneur.location.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                entrepreneur.location,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          entrepreneur.description ?? 'Sin descripción',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (entrepreneur.contactInfo.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Información de contacto',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entrepreneur.contactInfo,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Entrepreneur entrepreneur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar a ${entrepreneur.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<EntrepreneurBloc>().add(DeleteEntrepreneur(entrepreneur.id));
            },
            child: const Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  // Método para mostrar el selector de horario
  Future<void> _showHorarioSelector() async {
    final TimeOfDay? horaInicioSeleccionada = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaInicioSeleccionada != null) {
      setState(() {
        _horaInicio = horaInicioSeleccionada;
      });

      final TimeOfDay? horaFinSeleccionada = await showTimePicker(
        context: context,
        initialTime: _horaFin,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (horaFinSeleccionada != null) {
        setState(() {
          _horaFin = horaFinSeleccionada;
          _actualizarHorarioAtencion();
        });
      }
    }
  }

  // Método para actualizar el texto del horario
  void _actualizarHorarioAtencion() {
    final diasSeleccionados = _diasSeleccionados.map((d) => _diasSemana[d - 1]).join(',');
    _horarioAtencionController.text = '${_formatearHora(_horaInicio)}-${_formatearHora(_horaFin)} ($diasSeleccionados)';
  }

  // Método para formatear la hora
  String _formatearHora(TimeOfDay hora) {
    final horaStr = hora.hour.toString().padLeft(2, '0');
    final minutoStr = hora.minute.toString().padLeft(2, '0');
    return '$horaStr:$minutoStr';
  }

  // Método para mostrar el selector de días
  void _showDiasSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar días de atención'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final dia = index + 1;
                final isSelected = _diasSeleccionados.contains(dia);
                return FilterChip(
                  label: Text(_diasSemana[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _diasSeleccionados.add(dia);
                      } else {
                        _diasSeleccionados.remove(dia);
                      }
                    });
                  },
                );
              }),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _actualizarHorarioAtencion();
              });
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
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
        // Si es un objeto, extraer el nombre del rol
        return (firstRole['name'] ?? firstRole['NAME'] ?? 'USER').toString().toUpperCase();
      }
    }
    
    return 'USER';
  }
}
