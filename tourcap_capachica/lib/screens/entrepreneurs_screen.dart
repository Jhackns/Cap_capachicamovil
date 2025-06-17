import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_provider.dart';
import '../models/entrepreneur.dart';
import '../models/review.dart';
import '../widgets/entrepreneur_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/no_results_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../utils/connectivity_checker.dart';
import '../blocs/entrepreneur/entrepreneur_bloc.dart';
import '../blocs/entrepreneur/entrepreneur_event.dart';
import '../blocs/entrepreneur/entrepreneur_state.dart';
import '../widgets/reviews_section.dart';

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
      context.read<EntrepreneurBloc>().add(FetchEntrepreneurs())
    );
  }

  @override
  Widget build(BuildContext context) {
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
          context.read<EntrepreneurBloc>().add(FetchEntrepreneurs());
        },
        child: BlocBuilder<EntrepreneurBloc, EntrepreneurState>(
          builder: (context, state) {
            if (state is EntrepreneurLoading) {
              return const LoadingWidget(message: 'Cargando emprendedores...');
            } else if (state is EntrepreneurError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () => context.read<EntrepreneurBloc>().add(FetchEntrepreneurs()),
              );
            } else if (state is EntrepreneurLoaded) {
              if (state.entrepreneurs.isEmpty) {
                return NoResultsWidget(
                  message: 'No hay emprendedores disponibles',
                  icon: Icons.store_mall_directory_outlined,
                  onRefresh: () => context.read<EntrepreneurBloc>().add(FetchEntrepreneurs()),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: state.entrepreneurs.length,
                itemBuilder: (context, index) {
                  final entrepreneur = state.entrepreneurs[index];
                  return EntrepreneurCard(
                    entrepreneur: entrepreneur,
                    isAdmin: isAdmin,
                    onTap: () => _showEntrepreneurDetails(context, entrepreneur),
                    onEdit: null,
                    onDelete: null,
                    showEditButton: false,
                    showDeleteButton: false
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _showEntrepreneurDetails(BuildContext context, Entrepreneur entrepreneur) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    context.read<EntrepreneurBloc>().add(GetEntrepreneurById(entrepreneur.id));

    if (mounted) Navigator.of(context).pop(); // Cierra el loading

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return BlocBuilder<EntrepreneurBloc, EntrepreneurState>(
            builder: (context, state) {
              if (state is EntrepreneurDetailLoaded) {
                final detailedEntrepreneur = state.entrepreneur;
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
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Actualizar la lista de emprendedores al cerrar
                                          context.read<EntrepreneurBloc>().add(FetchEntrepreneurs());
                                        },
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
                                    _AnimatedCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.location_on, color: Colors.redAccent),
                                            title: Text(
                                              detailedEntrepreneur.location ?? 'No especificada',
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
                                              Text('Teléfono: ${detailedEntrepreneur.contactInfo ?? 'No especificado'}', style: Theme.of(context).textTheme.bodyMedium),
                                              Text('Email: ${detailedEntrepreneur.email ?? 'No especificado'}', style: Theme.of(context).textTheme.bodyMedium),
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
                                              Text('Categoría: ${detailedEntrepreneur.categoria ?? 'No especificada'}', style: Theme.of(context).textTheme.bodyMedium),
                                              Text('Tipo de servicio: ${detailedEntrepreneur.tipoServicio ?? 'No especificado'}', style: Theme.of(context).textTheme.bodyMedium),
                                              Text('Horario de atención: ${detailedEntrepreneur.horarioAtencion ?? 'No especificado'}', style: Theme.of(context).textTheme.bodyMedium),
                                              Text('Rango de precios: ${detailedEntrepreneur.precioRango ?? 'No especificado'}', style: Theme.of(context).textTheme.bodyMedium),
                                              const SizedBox(height: 8),
                                              Text('Estado: ${detailedEntrepreneur.estado ? 'Activo' : 'Inactivo'}', style: Theme.of(context).textTheme.bodyMedium),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Sección de reseñas
                                    _AnimatedCard(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ReviewsSection(reviews: Review.getDummyReviews()),
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
              } else if (state is EntrepreneurError) {
                return Center(
                  child: Text(state.message),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      );
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
