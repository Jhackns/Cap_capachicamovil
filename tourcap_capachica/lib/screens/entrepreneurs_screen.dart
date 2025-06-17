import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entrepreneur_provider.dart';
import '../providers/auth_provider.dart';
import '../models/entrepreneur.dart';
import '../widgets/entrepreneur_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/no_results_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../utils/connectivity_checker.dart';

class EntrepreneursScreen extends StatefulWidget {
  const EntrepreneursScreen({Key? key}) : super(key: key);

  @override
  State<EntrepreneursScreen> createState() => _EntrepreneursScreenState();
}

class _EntrepreneursScreenState extends State<EntrepreneursScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entrepreneurs when screen loads
    Future.microtask(() => 
      Provider.of<EntrepreneurProvider>(context, listen: false).fetchEntrepreneurs()
    );
  }

  @override
  Widget build(BuildContext context) {
    final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Emprendedores',
        actions: isAdmin ? [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.pushNamed(context, '/admin-dashboard');
            },
          ),
        ] : null,
      ),
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
                            isAdmin: isAdmin,
                            onTap: () => _showEntrepreneurDetails(context, entrepreneur),
                            onEdit: null,
                            onDelete: null, // Deshabilitar la eliminación en esta pantalla
                            showEditButton: false, // Deshabilitar el botón de edición
                            showDeleteButton: false // Deshabilitar el botón de eliminación
                          );
                        },
                      ),
      ),
      // Eliminado el botón flotante de agregar para que solo esté en el panel de gestión
      // Las operaciones CRUD solo están disponibles en el panel de administración
    );
  }

  Future<void> _showEntrepreneurDetails(BuildContext context, Entrepreneur entrepreneur) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final provider = Provider.of<EntrepreneurProvider>(context, listen: false);
    final detailedEntrepreneur = await provider.getEntrepreneurById(entrepreneur.id);

    if (mounted) Navigator.of(context).pop(); // Cierra el loading

    if (detailedEntrepreneur != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: MediaQuery.of(context).viewInsets + const EdgeInsets.only(top: 40),
            child: FractionallySizedBox(
              heightFactor: 0.92,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Hero(
                              tag: 'entrepreneur_image_${detailedEntrepreneur.id}',
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  detailedEntrepreneur.imageUrl ?? 'https://via.placeholder.com/400x300?text=No+disponible',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error, size: 40),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AnimatedCard(
                                child: ListTile(
                                  leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
                                  title: Text(
                                    detailedEntrepreneur.name,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      detailedEntrepreneur.description ?? 'Sin descripción',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Card: Ubicación y mapa (ahora con Mapbox)
                              _AnimatedCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.location_on, color: Colors.redAccent),
                                      title: Text(
                                        detailedEntrepreneur.location,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _AnimatedCard(
                                child: ListTile(
                                  leading: const Icon(Icons.contact_phone, color: Colors.green),
                                  title: Text('Información de contacto', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Teléfono: ${detailedEntrepreneur.contactInfo}', style: Theme.of(context).textTheme.bodyMedium),
                                        Text('Email: ${detailedEntrepreneur.email}', style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _AnimatedCard(
                                child: ListTile(
                                  leading: const Icon(Icons.info, color: Colors.deepPurple),
                                  title: Text('Detalles', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Categoría: ${detailedEntrepreneur.categoria}', style: Theme.of(context).textTheme.bodyMedium),
                                        Text('Tipo de servicio: ${detailedEntrepreneur.tipoServicio}', style: Theme.of(context).textTheme.bodyMedium),
                                        Text('Horario de atención: ${detailedEntrepreneur.horarioAtencion}', style: Theme.of(context).textTheme.bodyMedium),
                                        Text('Rango de precios: ${detailedEntrepreneur.precioRango}', style: Theme.of(context).textTheme.bodyMedium),
                                        const SizedBox(height: 8),
                                        Text('Estado: ${detailedEntrepreneur.estado ? 'Activo' : 'Inactivo'}', style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la información completa del emprendedor.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, Entrepreneur entrepreneur) async {
    // First check for internet connectivity
    final isConnected = await ConnectivityChecker.isConnected();
    if (!isConnected && mounted) {
      ConnectivityChecker.showConnectivitySnackBar(context, false);
      return;
    }
    
    // Show confirmation dialog
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
      // Show loading indicator
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
      
      // Perform deletion
      final entrepreneurProvider = Provider.of<EntrepreneurProvider>(context, listen: false);
      final result = await entrepreneurProvider.deleteEntrepreneur(entrepreneur.id);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show result
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

// Card animada para las secciones
class _AnimatedCard extends StatelessWidget {
  final Widget child;
  const _AnimatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.95, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: this.child,
          ),
        );
      },
      child: child,
    );
  }
}
