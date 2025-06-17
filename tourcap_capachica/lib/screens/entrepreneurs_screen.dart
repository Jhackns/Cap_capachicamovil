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
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen principal
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
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
                    const SizedBox(height: 16),
                    // Card: Información general
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detailedEntrepreneur.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              detailedEntrepreneur.description ?? 'Sin descripción',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Card: Ubicación y mapa
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 20, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    detailedEntrepreneur.location,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap(
                                  initialCameraPosition: const CameraPosition(
                                    target: LatLng(-15.6532, -69.6966), // Coordenadas de Capachica
                                    zoom: 12,
                                  ),
                                  markers: {
                                    const Marker(
                                      markerId: MarkerId('capachica'),
                                      position: LatLng(-15.6532, -69.6966),
                                      infoWindow: InfoWindow(title: 'Capachica'),
                                    ),
                                  },
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  liteModeEnabled: true, // Para mejor rendimiento en modal
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Card: Contacto
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Información de contacto', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Teléfono: ${detailedEntrepreneur.contactInfo}', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Email: ${detailedEntrepreneur.email}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    // Card: Detalles adicionales
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Detalles', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
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
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
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
