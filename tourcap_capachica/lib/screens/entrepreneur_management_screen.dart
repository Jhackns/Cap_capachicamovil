import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entrepreneur.dart';
import '../providers/entrepreneur_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/entrepreneur_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/no_results_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../utils/connectivity_checker.dart';

class EntrepreneurManagementScreen extends StatefulWidget {
  const EntrepreneurManagementScreen({Key? key}) : super(key: key);

  @override
  State<EntrepreneurManagementScreen> createState() => _EntrepreneurManagementScreenState();
}

class _EntrepreneurManagementScreenState extends State<EntrepreneurManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar emprendedores al iniciar la pantalla
    Future.microtask(() =>
      Provider.of<EntrepreneurProvider>(context, listen: false).fetchEntrepreneurs()
    );
  }

  @override
  Widget build(BuildContext context) {
    final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestión de Emprendedores'),
      body: RefreshIndicator(
        onRefresh: () async {
          final isConnected = await ConnectivityChecker.isConnected();
          if (!isConnected && mounted) {
            ConnectivityChecker.showConnectivitySnackBar(context, false);
          }
          return entrepreneurProvider.fetchEntrepreneurs();
        },
        child: entrepreneurProvider.isLoading
            ? const LoadingWidget(message: 'Cargando emprendedores...')
            : entrepreneurProvider.error != null
                ? CustomErrorWidget(
                    message: entrepreneurProvider.error!,
                    onRetry: () => entrepreneurProvider.fetchEntrepreneurs(),
                  )
                : entrepreneurProvider.entrepreneurs.isEmpty
                    ? NoResultsWidget(
                        message: 'No hay emprendedores disponibles',
                        icon: Icons.store_mall_directory_outlined,
                        onRefresh: () => entrepreneurProvider.fetchEntrepreneurs(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: entrepreneurProvider.entrepreneurs.length,
                        itemBuilder: (context, index) {
                          final entrepreneur = entrepreneurProvider.entrepreneurs[index];
                          return EntrepreneurCard(
                            entrepreneur: entrepreneur,
                            isAdmin: true,
                            onTap: () => _showEntrepreneurDetails(context, entrepreneur),
                            onEdit: () => _showEntrepreneurForm(context, entrepreneur),
                            onDelete: () => _confirmDelete(context, entrepreneur),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntrepreneurForm(context),
        child: const Icon(Icons.add),
      ),
    );
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
                        Text(
                          entrepreneur.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            entrepreneur.tipoServicio,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  void _showEntrepreneurForm(BuildContext context, [Entrepreneur? entrepreneur]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EntrepreneurForm(entrepreneur: entrepreneur),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Entrepreneur entrepreneur) async {
    // Verificar conectividad
    final isConnected = await ConnectivityChecker.isConnected();
    if (!isConnected && mounted) {
      ConnectivityChecker.showConnectivitySnackBar(context, false);
      return;
    }
    
    // Mostrar diálogo de confirmación
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Confirmar eliminación',
      message: '¿Estás seguro de eliminar a ${entrepreneur.name}?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Colors.red,
      icon: Icons.delete_forever,
    );
    
    if (confirmed && mounted) {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Eliminando...'),
            ],
          ),
        ),
      );
      
      // Realizar eliminación
      final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context, listen: false);
      final result = await entrepreneurProvider.deleteEntrepreneur(entrepreneur.id);
      
      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar resultado
      if (mounted) {
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
    }
  }
}

class EntrepreneurForm extends StatefulWidget {
  final Entrepreneur? entrepreneur;
  
  const EntrepreneurForm({Key? key, this.entrepreneur}) : super(key: key);

  @override
  State<EntrepreneurForm> createState() => _EntrepreneurFormState();
}

class _EntrepreneurFormState extends State<EntrepreneurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tipoServicioController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactInfoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, llenar el formulario con los datos del emprendedor
    if (widget.entrepreneur != null) {
      _nameController.text = widget.entrepreneur!.name;
      _descriptionController.text = widget.entrepreneur!.description ?? '';
      _imageUrlController.text = widget.entrepreneur!.imageUrl ?? '';
      _tipoServicioController.text = widget.entrepreneur!.tipoServicio;
      _locationController.text = widget.entrepreneur!.location;
      _contactInfoController.text = widget.entrepreneur!.contactInfo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _tipoServicioController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entrepreneur != null;
    final title = isEditing ? 'Editar Emprendedor' : 'Nuevo Emprendedor';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ingrese el nombre del emprendedor',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo de Servicio
                    TextFormField(
                      controller: _tipoServicioController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Servicio',
                        hintText: 'Ej: Hospedaje, Gastronomía, Artesanía',
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el tipo de servicio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Ingrese una descripción del emprendedor',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // URL de Imagen
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de Imagen',
                        hintText: 'Ingrese la URL de la imagen',
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una URL de imagen';
                        }
                        if (!Uri.tryParse(value)!.isAbsolute) {
                          return 'Por favor ingrese una URL válida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Ubicación
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        hintText: 'Ingrese la ubicación (opcional)',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Información de Contacto
                    TextFormField(
                      controller: _contactInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Información de Contacto',
                        hintText: 'Ingrese información de contacto (opcional)',
                        prefixIcon: Icon(Icons.contact_phone),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Actualizar' : 'Crear'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final isConnected = await ConnectivityChecker.isConnected();
        if (!isConnected) {
          if (mounted) {
            ConnectivityChecker.showConnectivitySnackBar(context, false);
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context, listen: false);
        final isEditing = widget.entrepreneur != null;
        
        final entrepreneur = Entrepreneur(
          id: isEditing ? widget.entrepreneur!.id : 0, // El backend asignará un ID para nuevos emprendedores
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          tipoServicio: _tipoServicioController.text.trim(),
          location: _locationController.text.trim(),
          contactInfo: _contactInfoController.text.trim(),
          email: isEditing ? widget.entrepreneur!.email : 'contacto@example.com',
          horarioAtencion: isEditing ? widget.entrepreneur!.horarioAtencion : '08:00-18:00',
          precioRango: isEditing ? widget.entrepreneur!.precioRango : '50-100 USD',
          categoria: isEditing ? widget.entrepreneur!.categoria : 'Turismo',
          estado: isEditing ? widget.entrepreneur!.estado : true,
        );

        final result = isEditing
            ? await entrepreneurProvider.updateEntrepreneur(entrepreneur)
            : await entrepreneurProvider.addEntrepreneur(entrepreneur);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result != null
                    ? isEditing
                        ? 'Emprendedor actualizado con éxito'
                        : 'Emprendedor creado con éxito'
                    : 'Error: ${entrepreneurProvider.error}',
              ),
              backgroundColor: result != null ? Colors.green : Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}