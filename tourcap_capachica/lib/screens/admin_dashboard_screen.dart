import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/entrepreneur_provider.dart';
import '../providers/auth_provider.dart';
// Importaciones necesarias
import '../widgets/entrepreneur_card.dart';
import '../models/entrepreneur.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch entrepreneurs when screen loads
    Future.microtask(() => 
      Provider.of<EntrepreneurProvider>(context, listen: false).fetchEntrepreneurs()
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is admin, if not redirect to home
    if (!authProvider.isAdmin) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Emprendedores', icon: Icon(Icons.list)),
              Tab(text: 'Gestionar', icon: Icon(Icons.edit)),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Entrepreneurs list tab
                _buildEntrepreneursList(entrepreneurProvider),
                
                // Manage tab (Add/Edit form)
                _buildManageEntrepreneurForm(context, entrepreneurProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrepreneursList(EntrepreneurProvider entrepreneurProvider) {
    return RefreshIndicator(
      onRefresh: () => entrepreneurProvider.fetchEntrepreneurs(),
      child: entrepreneurProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : entrepreneurProvider.error != null
              ? Center(
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
                        entrepreneurProvider.error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => entrepreneurProvider.fetchEntrepreneurs(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : entrepreneurProvider.entrepreneurs.isEmpty
                  ? const Center(
                      child: Text('No hay emprendedores disponibles'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: entrepreneurProvider.entrepreneurs.length,
                      itemBuilder: (context, index) {
                        final entrepreneur = entrepreneurProvider.entrepreneurs[index];
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
                        );
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
  Entrepreneur? _currentEntrepreneur;
  String? _selectedTipoServicio;
  String? _selectedLocation;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
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

  Widget _buildManageEntrepreneurForm(BuildContext context, EntrepreneurProvider entrepreneurProvider) {
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
                    // Vista previa de la imagen
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
                    // Botones para gestionar la imagen
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
                // Campo oculto para URL de imagen (para compatibilidad)
                Visibility(
                  visible: false,
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de imagen (opcional)',
                    ),
                  ),
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
            
            // Contact info field
            TextFormField(
              controller: _contactInfoController,
              decoration: const InputDecoration(
                labelText: 'Información de contacto',
                hintText: 'Teléfono, correo, etc.',
                prefixIcon: Icon(Icons.contact_phone),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Error message
            if (entrepreneurProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  entrepreneurProvider.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: entrepreneurProvider.isLoading
                        ? null
                        : () {
                            _resetForm();
                            // Cambiar a la pestaña de listado
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
                  child: ElevatedButton(
                    onPressed: entrepreneurProvider.isLoading
                        ? null
                        : () => _saveEntrepreneur(entrepreneurProvider),
                    child: entrepreneurProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_currentEntrepreneur == null ? 'Agregar' : 'Actualizar'),
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
      
      // Actualizar los valores seleccionados en los dropdowns asegurando que coincidan con las opciones disponibles
      // Para tipo de servicio, buscar la opción más cercana
      String tipoServicio = entrepreneur.tipoServicio;
      _selectedTipoServicio = _tipoServicioOptions.contains(tipoServicio) 
          ? tipoServicio 
          : _tipoServicioOptions.firstWhere(
              (option) => option.toLowerCase().contains(tipoServicio.toLowerCase()) || 
                          tipoServicio.toLowerCase().contains(option.toLowerCase()),
              orElse: () => _tipoServicioOptions.last // Usar 'Otro' como fallback
            );
      
      // Para ubicación, buscar la opción más cercana
      String location = entrepreneur.location;
      _selectedLocation = _locationOptions.contains(location) 
          ? location 
          : _locationOptions.firstWhere(
              (option) => option.toLowerCase().contains(location.toLowerCase()) || 
                          location.toLowerCase().contains(option.toLowerCase()),
              orElse: () => _locationOptions.last // Usar 'Otro lugar en Capachica' como fallback
            );
      
      // Resetear la imagen seleccionada
      _selectedImage = null;
      
      // Si la URL de la imagen es una ruta local, cargar la imagen
      if (entrepreneur.imageUrl != null && entrepreneur.imageUrl!.startsWith('/')) {
        _selectedImage = File(entrepreneur.imageUrl!);
      }
      
      // Imprimir información de depuración
      print('Editando emprendedor: ${entrepreneur.id}');
      print('Tipo de servicio: ${entrepreneur.tipoServicio} => $_selectedTipoServicio');
      print('Ubicación: ${entrepreneur.location} => $_selectedLocation');
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
      _selectedTipoServicio = null;
      _selectedLocation = null;
      _selectedImage = null;
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

  Future<void> _saveEntrepreneur(EntrepreneurProvider entrepreneurProvider) async {
    if (_formKey.currentState!.validate()) {
      // Preparar la URL de la imagen
      String? imageUrl = _imageUrlController.text.isEmpty ? null : _imageUrlController.text;
      
      // Si tenemos una imagen seleccionada, aquí iría el código para subirla al servidor
      // Por ahora, solo usamos la ruta local o la URL existente
      if (_selectedImage != null) {
        // En una implementación real, aquí se subiría la imagen al servidor
        // y se obtendría la URL para guardarla en la base de datos
        // Por ahora, guardamos la ruta local (esto es solo para demostración)
        imageUrl = _selectedImage!.path;
      }
      
      // Crear o actualizar el emprendedor con todos los campos requeridos por el backend
      final entrepreneur = Entrepreneur(
        id: _currentEntrepreneur?.id ?? 0, // Usar 0 como valor predeterminado si es null
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: imageUrl,
        tipoServicio: _selectedTipoServicio ?? _tipoServicioController.text,
        location: _selectedLocation ?? _locationController.text,
        contactInfo: _contactInfoController.text,
        // Campos adicionales requeridos por el backend
        email: _currentEntrepreneur?.email ?? 'contacto@example.com',
        horarioAtencion: _currentEntrepreneur?.horarioAtencion ?? '08:00-18:00',
        precioRango: _currentEntrepreneur?.precioRango ?? '50-100 USD',
        categoria: _currentEntrepreneur?.categoria ?? 'Turismo',
        estado: _currentEntrepreneur?.estado ?? true,
      );
      
      print('Enviando emprendedor: ${entrepreneur.toJson()}');
      
      Entrepreneur? result;
      
      if (_currentEntrepreneur == null) {
        // Crear nuevo emprendedor
        result = await entrepreneurProvider.addEntrepreneur(entrepreneur);
      } else {
        // Actualizar emprendedor existente
        result = await entrepreneurProvider.updateEntrepreneur(entrepreneur);
      }
      
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentEntrepreneur == null
                  ? 'Emprendedor agregado con éxito'
                  : 'Emprendedor actualizado con éxito',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        _resetForm();
        _tabController.animateTo(0);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${entrepreneurProvider.error ?? "No se pudo procesar la solicitud"}',
            ),
            backgroundColor: Colors.red,
          ),
        );
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
              final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context, listen: false);
              final result = await entrepreneurProvider.deleteEntrepreneur(entrepreneur.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? 'Emprendedor eliminado con éxito'
                          : 'Error al eliminar: ${entrepreneurProvider.error}',
                    ),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
