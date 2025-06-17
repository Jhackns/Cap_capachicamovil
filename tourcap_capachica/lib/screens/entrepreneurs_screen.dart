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
